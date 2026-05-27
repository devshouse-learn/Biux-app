import 'dart:async';

import 'package:biux/features/authentication/domain/repositories/auth_repository_interface.dart';
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
    // Validar formato de telÃ©fono
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    final cleanPhone = phoneNumber.trim().replaceAll(' ', '');
    if (cleanPhone.isEmpty || !phoneRegex.hasMatch(cleanPhone)) {
      _errorMessage = 'NÃºmero de telÃ©fono invÃ¡lido';
      _state = AuthState.error;
      notifyListeners();
      return;
    }
    try {
      AppLogger.debug('ðŸ“² [AuthProvider] Iniciando proceso de envÃ­o de cÃ³digo');
      AppLogger.debug('   TelÃ©fono: $phoneNumber');
      AppLogger.debug('   Intento: ${_sendAttempts + 1}/$_maxSendAttempts');

      _state = AuthState.loading;
      _errorMessage = null;
      _phoneNumber = phoneNumber;
      notifyListeners();

      // Si es reintento, incrementar contador
      if (_sendAttempts > 0) {
        AppLogger.debug('   âš ï¸ Este es reintento #${_sendAttempts}');
      }

      AppLogger.debug('ðŸ“¤ Enviando request a N8N...');
      await _authRepository.sendOTP(phoneNumber);

      _sendAttempts = 0; // Reset en caso de Ã©xito
      _state = AuthState.codeSent;
      AppLogger.info('âœ… [AuthProvider] CÃ³digo enviado - Esperando validaciÃ³n');
      _startResendTimer();
    } on FirebaseException catch (e) {
      _sendAttempts++;
      _state = AuthState.error;
      _errorMessage = e.toString();

      AppLogger.error('âŒ [AuthProvider] Error al enviar cÃ³digo:');
      AppLogger.debug('   Mensaje: $_errorMessage');
      AppLogger.debug(
        '   Intentos realizados: $_sendAttempts/$_maxSendAttempts',
      );

      // Limpiar el mensaje de excepciÃ³n si empieza con "Exception: "
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
      AppLogger.error('âŒ [AuthProvider] No hay nÃºmero de telÃ©fono registrado');
      _state = AuthState.error;
      _errorMessage = 'err_no_phone_found';
      notifyListeners();
      return;
    }

    if (_state == AuthState.loading) {
      AppLogger.debug('â³ [AuthProvider] Ya hay una validaciÃ³n en proceso');
      return;
    }

    try {
      AppLogger.debug('ðŸ” [AuthProvider] Iniciando validaciÃ³n de cÃ³digo');
      AppLogger.debug('   TelÃ©fono: $_phoneNumber');
      AppLogger.debug('   CÃ³digo: ${code.replaceAll(RegExp(r'.'), '*')}');

      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      AppLogger.debug('ðŸ“¤ Enviando validaciÃ³n a N8N...');
      final authResponse = await _authRepository.validateOTP(
        _phoneNumber!,
        code,
      );

      AppLogger.info('âœ… [AuthProvider] CÃ³digo validado correctamente');

      if (authResponse.token == null || authResponse.token!.isEmpty) {
        _state = AuthState.error;
        _errorMessage = 'err_invalid_token';
        notifyListeners();
        return;
      }

      AppLogger.debug(
        'ðŸ”‘ Token recibido: ${authResponse.token!.substring(0, 20)}...',
      );

      // Autenticar con Firebase
      AppLogger.debug('ðŸ” Autenticando con Firebase...');
      final userCredential = await _auth.signInWithCustomToken(
        authResponse.token!,
      );
      final user = userCredential.user;

      AppLogger.info('âœ… [AuthProvider] Usuario autenticado en Firebase');
      AppLogger.debug('   UID: ${user?.uid}');

      // Obtener token ID para base de datos
      final idToken = await user?.getIdToken();
      AppLogger.debug('ðŸŽ« Token ID obtenido: ${idToken?.substring(0, 50)}...');

      // Reinicializar servicio de notificaciones con el usuario autenticado
      AppLogger.debug('ðŸ“¢ Reinicializando servicio de notificaciones...');
      await NotificationService().reinitializeAfterLogin();

      // Verificar si el usuario necesita completar su perfil
      await _checkProfileSetup(user!.uid);

      _state = AuthState.authenticated;
      AppLogger.info(
        'âœ… [AuthProvider] Â¡AutenticaciÃ³n completada exitosamente!',
      );
    } on FirebaseException catch (e) {
      _state = AuthState.codeSent;
      _errorMessage = e.toString();

      AppLogger.error('âŒ [AuthProvider] Error en validaciÃ³n:');
      AppLogger.debug('   Mensaje: $_errorMessage');

      // Limpiar el mensaje de excepciÃ³n si empieza con "Exception: "
      if (_errorMessage?.startsWith('Exception: ') ?? false) {
        _errorMessage = _errorMessage?.replaceFirst('Exception: ', '');
      }
    }
    notifyListeners();
  }

  Future<void> resendCode() async {
    if (_phoneNumber != null && _canResendCode) {
      AppLogger.debug('ðŸ”„ [AuthProvider] Reenviando cÃ³digo a: $_phoneNumber');
      await sendCode(_phoneNumber!);
    }
  }

  Future<void> signInAsGuest() async {
    try {
      AppLogger.debug('ðŸ‘¤ [AuthProvider] Iniciando sesiÃ³n como invitado');
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      // Usar Firebase Auth anÃ³nima
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      AppLogger.debug('ðŸ‘¤ Usuario invitado autenticado: ${user?.uid}');

      // Reinicializar servicio de notificaciones
      await NotificationService().reinitializeAfterLogin();

      _state = AuthState.authenticated;
      AppLogger.info('âœ… SesiÃ³n de invitado iniciada correctamente');
    } on FirebaseException catch (e) {
      _state = AuthState.error;
      _errorMessage = 'err_guest_login';
      AppLogger.error('âŒ Error en sesiÃ³n de invitado: $e');
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      AppLogger.debug('ðŸšª [AuthProvider] Cerrando sesiÃ³n...');
      // Forzar eliminaciÃ³n completa de la sesiÃ³n
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
      AppLogger.info('âœ… SesiÃ³n cerrada completamente');
      _state = AuthState.initial;
      _sendAttempts = 0;
      notifyListeners();
    } on FirebaseException catch (e) {
      AppLogger.error('âŒ Error al cerrar sesiÃ³n: $e');
      _errorMessage = 'err_sign_out';
      notifyListeners();
    }
  }

  /// Verifica si el usuario necesita completar su perfil
  Future<void> _checkProfileSetup(String uid) async {
    try {
      AppLogger.debug('ðŸ” Verificando perfil del usuario: $uid');
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
          AppLogger.info('âœ… Usuario tiene perfil completo');
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
      AppLogger.debug('🔓 [AuthProvider] Iniciando login con email: $email');
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      AppLogger.info('✅ [AuthProvider] Usuario autenticado con email: ${user?.uid}');

      // Reinicializar servicio de notificaciones
      await NotificationService().reinitializeAfterLogin();

      // Verificar si el usuario necesita completar su perfil
      if (user != null) {
        await _checkProfileSetup(user.uid);
      }

      _state = AuthState.authenticated;
      AppLogger.info('✅ [AuthProvider] ¡Autenticación con email completada exitosamente!');
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _mapAuthError(e.code);
      AppLogger.error('❌ [AuthProvider] Error en login con email: ${e.code}');
      AppLogger.debug('   Mensaje: ${e.message}');
    } on FirebaseException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      AppLogger.error('❌ [AuthProvider] Error en login con email: $e');
    }
    notifyListeners();
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      AppLogger.debug('📝 [AuthProvider] Iniciando registro con email: $email');
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      AppLogger.info('✅ [AuthProvider] Usuario registrado con email: ${user?.uid}');

      // Reinicializar servicio de notificaciones
      await NotificationService().reinitializeAfterLogin();

      // Verificar si el usuario necesita completar su perfil
      if (user != null) {
        await _checkProfileSetup(user.uid);
      }

      _state = AuthState.authenticated;
      AppLogger.info('✅ [AuthProvider] ¡Registro con email completado exitosamente!');
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _mapAuthError(e.code);
      AppLogger.error('❌ [AuthProvider] Error en registro con email: ${e.code}');
      AppLogger.debug('   Mensaje: ${e.message}');
    } on FirebaseException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      AppLogger.error('❌ [AuthProvider] Error en registro con email: $e');
    }
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'err_user_not_found';
      case 'wrong-password':
        return 'err_wrong_password';
      case 'user-disabled':
        return 'err_user_disabled';
      case 'too-many-requests':
        return 'err_too_many_requests';
      case 'operation-not-allowed':
        return 'err_operation_not_allowed';
      case 'email-already-in-use':
        return 'err_email_already_in_use';
      case 'invalid-email':
        return 'err_invalid_email';
      case 'weak-password':
        return 'err_weak_password';
      default:
        return 'err_auth_failed';
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}

