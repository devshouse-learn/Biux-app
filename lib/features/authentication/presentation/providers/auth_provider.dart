import 'dart:async';

import 'package:biux/features/authentication/domain/repositories/auth_repository_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:biux/core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthState { initial, loading, codeSent, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepositoryInterface _authRepository;
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

  AuthProvider({required AuthRepositoryInterface authRepository})
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
      _errorMessage = 'NÃºmero de teléfono inválido';
      _state = AuthState.error;
      notifyListeners();
      return;
    }
    try {
      AppLogger.debug('“² [AuthProvider] Iniciando proceso de envío de código');
      AppLogger.debug('   Teléfono: $phoneNumber');
      AppLogger.debug('   Intento: ${_sendAttempts + 1}/$_maxSendAttempts');

      _state = AuthState.loading;
      _errorMessage = null;
      _phoneNumber = phoneNumber;
      notifyListeners();

      // Si es reintento, incrementar contador
      if (_sendAttempts > 0) {
        AppLogger.debug('   âš ï¸ Este es reintento #${_sendAttempts}');
      }

      AppLogger.debug('“¤ Enviando request a N8N...');
      await _authRepository.sendOTP(phoneNumber);

      _sendAttempts = 0; // Reset en caso de éxito
      _state = AuthState.codeSent;
      AppLogger.info('✓ [AuthProvider] Código enviado - Esperando validación');
      _startResendTimer();
    } on FirebaseException catch (e) {
      _sendAttempts++;
      _state = AuthState.error;
      _errorMessage = e.toString();

      AppLogger.error('âŒ [AuthProvider] Error al enviar código:');
      AppLogger.debug('   Mensaje: $_errorMessage');
      AppLogger.debug(
        '   Intentos realizados: $_sendAttempts/$_maxSendAttempts',
      );

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
      AppLogger.error('âŒ [AuthProvider] No hay nÃºmero de teléfono registrado');
      _state = AuthState.error;
      _errorMessage = 'err_no_phone_found';
      notifyListeners();
      return;
    }

    if (_state == AuthState.loading) {
      AppLogger.debug('â³ [AuthProvider] Ya hay una validación en proceso');
      return;
    }

    try {
      AppLogger.debug('” [AuthProvider] Iniciando validación de código');
      AppLogger.debug('   Teléfono: $_phoneNumber');
      AppLogger.debug('   Código: ${code.replaceAll(RegExp(r'.'), '*')}');

      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      AppLogger.debug('“¤ Enviando validación a N8N...');
      final authResponse = await _authRepository.validateOTP(
        _phoneNumber!,
        code,
      );

      AppLogger.info('✓ [AuthProvider] Código validado correctamente');

      if (authResponse.token == null || authResponse.token!.isEmpty) {
        _state = AuthState.error;
        _errorMessage = 'err_invalid_token';
        notifyListeners();
        return;
      }

      AppLogger.debug(
        '”‘ Token recibido: ${authResponse.token!.substring(0, 20)}...',
      );

      // Autenticar con Firebase
      AppLogger.debug('” Autenticando con Firebase...');
      final userCredential = await _auth.signInWithCustomToken(
        authResponse.token!,
      );
      final user = userCredential.user;

      AppLogger.info('✓ [AuthProvider] Usuario autenticado en Firebase');
      AppLogger.debug('   UID: ${user?.uid}');

      // Obtener token ID para base de datos
      final idToken = await user?.getIdToken();
      AppLogger.debug('Ž« Token ID obtenido: ${idToken?.substring(0, 50)}...');

      // Reinicializar servicio de notificaciones con el usuario autenticado
      AppLogger.debug('“¢ Reinicializando servicio de notificaciones...');
      await NotificationService().reinitializeAfterLogin();

      // Verificar si el usuario necesita completar su perfil
      await _checkProfileSetup(user!.uid);

      _state = AuthState.authenticated;
      AppLogger.info(
        '✓ [AuthProvider] ¡Autenticación completada exitosamente!',
      );
    } on FirebaseException catch (e) {
      _state = AuthState.codeSent;
      _errorMessage = e.toString();

      AppLogger.error('âŒ [AuthProvider] Error en validación:');
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
      AppLogger.debug('”„ [AuthProvider] Reenviando código a: $_phoneNumber');
      await sendCode(_phoneNumber!);
    }
  }

  Future<void> signInAsGuest() async {
    try {
      AppLogger.debug('‘¤ [AuthProvider] Iniciando sesión como invitado');
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      // Usar Firebase Auth anónima
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      AppLogger.debug('‘¤ Usuario invitado autenticado: ${user?.uid}');

      // Reinicializar servicio de notificaciones
      await NotificationService().reinitializeAfterLogin();

      _state = AuthState.authenticated;
      AppLogger.info('✓ Sesión de invitado iniciada correctamente');
    } on FirebaseException catch (e) {
      _state = AuthState.error;
      _errorMessage = 'err_guest_login';
      AppLogger.error('âŒ Error en sesión de invitado: $e');
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      AppLogger.debug('šª [AuthProvider] Cerrando sesión...');
      // Forzar eliminación completa de la sesión
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        AppLogger.debug('   Usuario: ${currentUser.uid}');
        // Eliminar tokens cached
        await currentUser.delete().catchError((e) {
          AppLogger.debug(
            'âš ï¸ No se pudo eliminar usuario (normal si es externo): $e',
          );
        });
      }
      await _auth.signOut();
      AppLogger.info('✓ Sesión cerrada completamente');
      _state = AuthState.initial;
      _sendAttempts = 0;
      notifyListeners();
    } on FirebaseException catch (e) {
      AppLogger.error('âŒ Error al cerrar sesión: $e');
      _errorMessage = 'err_sign_out';
      notifyListeners();
    }
  }

  /// Verifica si el usuario necesita completar su perfil
  Future<void> _checkProfileSetup(String uid) async {
    try {
      AppLogger.debug('” Verificando perfil del usuario: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        final userName = data?['userName'] as String?;
        final name = data?['name'] as String?;

        // Si no tiene userName o name, necesita completar perfil
        if ((userName == null || userName.isEmpty) &&
            (name == null || name.isEmpty)) {
          _needsProfileSetup = true;
          AppLogger.warning('âš ï¸ Usuario necesita completar perfil');
        } else {
          _needsProfileSetup = false;
          AppLogger.info('✓ Usuario tiene perfil completo');
        }
      } else {
        // Si el documento no existe, necesita crear perfil
        _needsProfileSetup = true;
        AppLogger.warning(
          'âš ï¸ Documento de usuario no existe, necesita crear perfil',
        );
      }
    } on FirebaseException catch (e) {
      AppLogger.error('âŒ Error verificando perfil: $e');
      _needsProfileSetup = false; // En caso de error, no bloquear
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      AppLogger.debug('📧 [AuthProvider] Iniciando login con email');
      AppLogger.debug('   Email: $email');

      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      AppLogger.debug('🔤 Autenticando con Firebase Auth...');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        _state = AuthState.error;
        _errorMessage = 'err_login_failed';
        AppLogger.error('❌ Usuario nulo después del login');
        notifyListeners();
        return;
      }

      AppLogger.debug('✅ Usuario autenticado: ${user.uid}');

      // Reinicializar servicio de notificaciones
      await NotificationService().reinitializeAfterLogin();

      // Verificar si perfil está completo
      await _checkProfileSetup(user.uid);

      _state = AuthState.authenticated;
      AppLogger.info('✅ Login con email completado');
    } on FirebaseException catch (e) {
      _state = AuthState.error;
      if (e.code == 'user-not-found') {
        _errorMessage = 'err_user_not_found';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'err_wrong_password';
      } else {
        _errorMessage = e.message ?? 'err_login_failed';
      }
      AppLogger.error('❌ Error en login: $e');
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'err_login_failed';
      AppLogger.error('❌ Error inesperado en login: $e');
    }
    notifyListeners();
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      AppLogger.debug('📧 [AuthProvider] Iniciando registro con email');
      AppLogger.debug('   Email: $email');

      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      AppLogger.debug('🔤 Registrando nuevo usuario en Firebase Auth...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        _state = AuthState.error;
        _errorMessage = 'err_register_failed';
        AppLogger.error('❌ Usuario nulo después del registro');
        notifyListeners();
        return;
      }

      AppLogger.debug('✅ Usuario registrado: ${user.uid}');

      // Crear documento básico de usuario
      AppLogger.debug('📝 Creando documento de usuario en Firestore...');
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));

      AppLogger.debug('✅ Documento de usuario creado');

      // Reinicializar servicio de notificaciones
      await NotificationService().reinitializeAfterLogin();

      // Marcar que necesita completar perfil
      _needsProfileSetup = true;

      _state = AuthState.authenticated;
      AppLogger.info('✅ Registro completado, usuario necesita completar perfil');
    } on FirebaseException catch (e) {
      _state = AuthState.error;
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'err_email_exists';
      } else if (e.code == 'weak-password') {
        _errorMessage = 'err_weak_password';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'err_invalid_email';
      } else {
        _errorMessage = e.message ?? 'err_register_failed';
      }
      AppLogger.error('❌ Error en registro: $e');
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'err_register_failed';
      AppLogger.error('❌ Error inesperado en registro: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}

