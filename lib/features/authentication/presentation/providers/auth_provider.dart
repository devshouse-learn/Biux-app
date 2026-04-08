import 'package:biux/core/services/biometric_service.dart';
import 'package:biux/core/services/rate_limiter.dart';
import 'dart:async';

import '../../data/repositories/auth_repository.dart';
import 'package:biux/core/services/app_logger.dart';
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
    // Validar formato de teléfono
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    final cleanPhone = phoneNumber.trim().replaceAll(' ', '');
    if (cleanPhone.isEmpty || !phoneRegex.hasMatch(cleanPhone)) {
      _errorMessage = 'Número de teléfono inválido';
      _state = AuthState.error;
      notifyListeners();
      return;
    }
    try {
      AppLogger.debug('📲 [AuthProvider] Iniciando proceso de envío de código');
      AppLogger.debug('   Teléfono: $phoneNumber');
      AppLogger.debug('   Intento: ${_sendAttempts + 1}/$_maxSendAttempts');

      _state = AuthState.loading;
      _errorMessage = null;
      _phoneNumber = phoneNumber;
      notifyListeners();

      // Si es reintento, incrementar contador
      if (_sendAttempts > 0) {
        AppLogger.debug('   ⚠️ Este es reintento #${_sendAttempts}');
      }

      AppLogger.debug('📤 Enviando request a N8N...');
      await _authRepository.sendOTP(phoneNumber);

      _sendAttempts = 0; // Reset en caso de éxito
      _state = AuthState.codeSent;
      AppLogger.info('✅ [AuthProvider] Código enviado - Esperando validación');
      _startResendTimer();
    } catch (e) {
      _sendAttempts++;
      _state = AuthState.error;
      _errorMessage = e.toString();

      AppLogger.error('❌ [AuthProvider] Error al enviar código:');
      AppLogger.debug('   Mensaje: $_errorMessage');
      AppLogger.debug('   Intentos realizados: $_sendAttempts/$_maxSendAttempts');

      // Limpiar el mensaje de excepción si empieza con "Exception: "
      if (_errorMessage?.startsWith('Exception: ') ?? false) {
        _errorMessage = _errorMessage?.replaceFirst('Exception: ', '');
      }

      if (_sendAttempts >= _maxSendAttempts) {
        _errorMessage = 'err_max_attempts';
      }
    }
    notifyListeners();
  }

  Future<void> validateCode(String code) async {
    if (_phoneNumber == null) {
      AppLogger.error('❌ [AuthProvider] No hay número de teléfono registrado');
      _state = AuthState.error;
      _errorMessage = 'err_no_phone_found';
      notifyListeners();
      return;
    }

    if (_state == AuthState.loading) {
      AppLogger.debug('⏳ [AuthProvider] Ya hay una validación en proceso');
      return;
    }

    try {
      AppLogger.debug('🔐 [AuthProvider] Iniciando validación de código');
      AppLogger.debug('   Teléfono: $_phoneNumber');
      AppLogger.debug('   Código: ${code.replaceAll(RegExp(r'.'), '*')}');

      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      AppLogger.debug('📤 Enviando validación a N8N...');
      final authResponse = await _authRepository.validateOTP(
        _phoneNumber!,
        code,
      );

      AppLogger.info('✅ [AuthProvider] Código validado correctamente');
      AppLogger.debug(
        '🔑 Token recibido: ${authResponse.token.substring(0, 20)}...',
      );

      // Autenticar con Firebase
      AppLogger.debug('🔐 Autenticando con Firebase...');
      final userCredential = await _auth.signInWithCustomToken(
        authResponse.token,
      );
      final user = userCredential.user;

      AppLogger.info('✅ [AuthProvider] Usuario autenticado en Firebase');
      AppLogger.debug('   UID: ${user?.uid}');

      // Obtener token ID para base de datos
      final idToken = await user?.getIdToken();
      AppLogger.debug('🎫 Token ID obtenido: ${idToken?.substring(0, 50)}...');

      // Reinicializar servicio de notificaciones con el usuario autenticado
      AppLogger.debug('📢 Reinicializando servicio de notificaciones...');
      await NotificationService().reinitializeAfterLogin();

      // Verificar si el usuario necesita completar su perfil
      await _checkProfileSetup(user!.uid);

      _state = AuthState.authenticated;
      AppLogger.info('✅ [AuthProvider] ¡Autenticación completada exitosamente!');
    } catch (e) {
      _state = AuthState.codeSent;
      _errorMessage = e.toString();

      AppLogger.error('❌ [AuthProvider] Error en validación:');
      AppLogger.debug('   Mensaje: $_errorMessage');

      // Limpiar el mensaje de excepción si empieza con "Exception: "
      if (_errorMessage?.startsWith('Exception: ') ?? false) {
        _errorMessage = _errorMessage?.replaceFirst('Exception: ', '');
      }
    }
    notifyListeners();
  }

  Future<void> resendCode() async {
    if (_phoneNumber != null && _canResendCode) {
      AppLogger.debug('🔄 [AuthProvider] Reenviando código a: $_phoneNumber');
      await sendCode(_phoneNumber!);
    }
  }

  Future<void> signInAsGuest() async {
    try {
      AppLogger.debug('👤 [AuthProvider] Iniciando sesión como invitado');
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      // Usar Firebase Auth anónima
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      AppLogger.debug('👤 Usuario invitado autenticado: ${user?.uid}');

      // Reinicializar servicio de notificaciones
      await NotificationService().reinitializeAfterLogin();

      _state = AuthState.authenticated;
      AppLogger.info('✅ Sesión de invitado iniciada correctamente');
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'err_guest_login';
      AppLogger.error('❌ Error en sesión de invitado: $e');
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      AppLogger.debug('🚪 [AuthProvider] Cerrando sesión...');
      // Forzar eliminación completa de la sesión
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        AppLogger.debug('   Usuario: ${currentUser.uid}');
        // Eliminar tokens cached
        await currentUser.delete().catchError((e) {
          AppLogger.debug(
            '⚠️ No se pudo eliminar usuario (normal si es externo): $e',
          );
        });
      }
      await _auth.signOut();
      AppLogger.info('✅ Sesión cerrada completamente');
      _state = AuthState.initial;
      _sendAttempts = 0;
      notifyListeners();
    } catch (e) {
      AppLogger.error('❌ Error al cerrar sesión: $e');
      _errorMessage = 'err_sign_out';
      notifyListeners();
    }
  }

  /// Verifica si el usuario necesita completar su perfil
  Future<void> _checkProfileSetup(String uid) async {
    try {
      AppLogger.debug('🔍 Verificando perfil del usuario: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        final userName = data?['userName'] as String?;
        final name = data?['name'] as String?;

        // Si no tiene userName o name, necesita completar perfil
        if ((userName == null || userName.isEmpty) &&
            (name == null || name.isEmpty)) {
          _needsProfileSetup = true;
          AppLogger.warning('⚠️ Usuario necesita completar perfil');
        } else {
          _needsProfileSetup = false;
          AppLogger.info('✅ Usuario tiene perfil completo');
        }
      } else {
        // Si el documento no existe, necesita crear perfil
        _needsProfileSetup = true;
        AppLogger.warning('⚠️ Documento de usuario no existe, necesita crear perfil');
      }
    } catch (e) {
      AppLogger.error('❌ Error verificando perfil: $e');
      _needsProfileSetup = false; // En caso de error, no bloquear
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
