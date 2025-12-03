import 'dart:async';

import '../../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:biux/shared/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthState { initial, loading, codeSent, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _phoneNumber;
  bool _canResendCode = false;
  int _resendSeconds = 60;
  Timer? _resendTimer;
  int _sendAttempts = 0;
  static const int _maxSendAttempts = 3;
  bool _needsProfileSetup = false; // Nueva bandera para perfil incompleto

  AuthProvider({required AuthRepository authRepository})
    : _authRepository = authRepository;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get canResendCode => _canResendCode;
  int get resendSeconds => _resendSeconds;
  bool get needsProfileSetup => _needsProfileSetup;

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendSeconds = 60;
    _canResendCode = false;

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _resendSeconds--;
      if (_resendSeconds <= 0) {
        _canResendCode = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void clearError() {
    if (_state == AuthState.error) {
      _state = AuthState.codeSent;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> sendCode(String phoneNumber) async {
    try {
      print('📲 [AuthProvider] Iniciando proceso de envío de código');
      print('   Teléfono: $phoneNumber');
      print('   Intento: ${_sendAttempts + 1}/$_maxSendAttempts');

      _state = AuthState.loading;
      _errorMessage = null;
      _phoneNumber = phoneNumber;
      notifyListeners();

      // Si es reintento, incrementar contador
      if (_sendAttempts > 0) {
        print('   ⚠️ Este es reintento #${_sendAttempts}');
      }

      print('📤 Enviando request a N8N...');
      await _authRepository.sendOTP(phoneNumber);

      _sendAttempts = 0; // Reset en caso de éxito
      _state = AuthState.codeSent;
      print('✅ [AuthProvider] Código enviado - Esperando validación');
      _startResendTimer();
    } catch (e) {
      _sendAttempts++;
      _state = AuthState.error;
      _errorMessage = e.toString();

      print('❌ [AuthProvider] Error al enviar código:');
      print('   Mensaje: $_errorMessage');
      print('   Intentos realizados: $_sendAttempts/$_maxSendAttempts');

      // Limpiar el mensaje de excepción si empieza con "Exception: "
      if (_errorMessage?.startsWith('Exception: ') ?? false) {
        _errorMessage = _errorMessage?.replaceFirst('Exception: ', '');
      }

      if (_sendAttempts >= _maxSendAttempts) {
        _errorMessage =
            '$_errorMessage\n\n⚠️ Se alcanzó el máximo de intentos. Por favor intenta en unos minutos.';
      }
    }
    notifyListeners();
  }

  Future<void> validateCode(String code) async {
    if (_phoneNumber == null) {
      print('❌ [AuthProvider] No hay número de teléfono registrado');
      _state = AuthState.error;
      _errorMessage = 'Error: No se encontró número de teléfono';
      notifyListeners();
      return;
    }

    if (_state == AuthState.loading) {
      print('⏳ [AuthProvider] Ya hay una validación en proceso');
      return;
    }

    try {
      print('🔐 [AuthProvider] Iniciando validación de código');
      print('   Teléfono: $_phoneNumber');
      print('   Código: ${code.replaceAll(RegExp(r'.'), '*')}');

      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      print('📤 Enviando validación a N8N...');
      final authResponse = await _authRepository.validateOTP(
        _phoneNumber!,
        code,
      );

      print('✅ [AuthProvider] Código validado correctamente');
      print('🔑 Token recibido: ${authResponse.token.substring(0, 20)}...');

      // Autenticar con Firebase
      print('🔐 Autenticando con Firebase...');
      final userCredential = await _auth.signInWithCustomToken(
        authResponse.token,
      );
      final user = userCredential.user;

      print('✅ [AuthProvider] Usuario autenticado en Firebase');
      print('   UID: ${user?.uid}');

      // Obtener token ID para base de datos
      final idToken = await user?.getIdToken();
      print('🎫 Token ID obtenido: ${idToken?.substring(0, 50)}...');

      // Reinicializar servicio de notificaciones con el usuario autenticado
      print('📢 Reinicializando servicio de notificaciones...');
      await NotificationService().reinitializeAfterLogin();

      // Verificar si el usuario necesita completar su perfil
      await _checkProfileSetup(user!.uid);

      _state = AuthState.authenticated;
      print('✅ [AuthProvider] ¡Autenticación completada exitosamente!');
    } catch (e) {
      _state = AuthState.codeSent;
      _errorMessage = e.toString();

      print('❌ [AuthProvider] Error en validación:');
      print('   Mensaje: $_errorMessage');

      // Limpiar el mensaje de excepción si empieza con "Exception: "
      if (_errorMessage?.startsWith('Exception: ') ?? false) {
        _errorMessage = _errorMessage?.replaceFirst('Exception: ', '');
      }
    }
    notifyListeners();
  }

  Future<void> resendCode() async {
    if (_phoneNumber != null && _canResendCode) {
      print('🔄 [AuthProvider] Reenviando código a: $_phoneNumber');
      await sendCode(_phoneNumber!);
    }
  }

  Future<void> signInAsGuest() async {
    try {
      print('👤 [AuthProvider] Iniciando sesión como invitado');
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      // Usar Firebase Auth anónima
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      print('👤 Usuario invitado autenticado: ${user?.uid}');

      // Reinicializar servicio de notificaciones
      await NotificationService().reinitializeAfterLogin();

      _state = AuthState.authenticated;
      print('✅ Sesión de invitado iniciada correctamente');
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Error al iniciar como invitado: $e';
      print('❌ Error en sesión de invitado: $_errorMessage');
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      print('🚪 [AuthProvider] Cerrando sesión...');
      // Forzar eliminación completa de la sesión
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('   Usuario: ${currentUser.uid}');
        // Eliminar tokens cached
        await currentUser.delete().catchError((e) {
          print('⚠️ No se pudo eliminar usuario (normal si es externo): $e');
        });
      }
      await _auth.signOut();
      print('✅ Sesión cerrada completamente');
      _state = AuthState.initial;
      _sendAttempts = 0;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      _errorMessage = 'Error al cerrar sesión';
      notifyListeners();
    }
  }

  /// Verifica si el usuario necesita completar su perfil
  Future<void> _checkProfileSetup(String uid) async {
    try {
      print('🔍 Verificando perfil del usuario: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data();
        final userName = data?['userName'] as String?;
        final name = data?['name'] as String?;
        
        // Si no tiene userName o name, necesita completar perfil
        if ((userName == null || userName.isEmpty) && 
            (name == null || name.isEmpty)) {
          _needsProfileSetup = true;
          print('⚠️ Usuario necesita completar perfil');
        } else {
          _needsProfileSetup = false;
          print('✅ Usuario tiene perfil completo');
        }
      } else {
        // Si el documento no existe, necesita crear perfil
        _needsProfileSetup = true;
        print('⚠️ Documento de usuario no existe, necesita crear perfil');
      }
    } catch (e) {
      print('❌ Error verificando perfil: $e');
      _needsProfileSetup = false; // En caso de error, no bloquear
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
