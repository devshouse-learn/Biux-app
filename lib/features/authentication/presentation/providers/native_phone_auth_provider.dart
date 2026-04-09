import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/notification_service.dart';
import 'package:biux/core/services/remote_config_service.dart';
import 'package:biux/core/services/app_logger.dart';

enum AuthState { initial, loading, codeSent, authenticated, error }

/// Provider NUEVO con Firebase Phone Auth NATIVO
/// ✅ Soporte para login automático de admin sin código
class NativePhoneAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _phoneNumber;
  String? _verificationId;
  int? _resendToken;
  int _resendSeconds = 60;
  Timer? _resendTimer;
  bool _needsProfileSetup = false;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;
  bool get canResendCode => true; // SIEMPRE permitir reenvío
  int get resendSeconds => _resendSeconds;
  bool get needsProfileSetup => _needsProfileSetup;

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendSeconds = 60;

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _resendSeconds--;
      if (_resendSeconds <= 0) {
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

  /// ENVIAR CÓDIGO SMS usando Firebase Phone Authentication
  /// Admin bypass controlado por configuración remota en Firestore
  Future<void> sendCode(String phoneNumber) async {
    try {
      // Verificar si es admin desde configuración remota (Firestore)
      final isAdmin = RemoteConfigService().isAdminPhone(phoneNumber);

      if (isAdmin) {
        AppLogger.info('Admin login solicitado', tag: 'Auth');

        _state = AuthState.loading;
        notifyListeners();

        await _loginAdminDirecto(phoneNumber);
        return;
      }

      AppLogger.info('Enviando SMS a: $phoneNumber', tag: 'Auth');

      _state = AuthState.loading;
      _errorMessage = null;
      _phoneNumber = phoneNumber;
      notifyListeners();

      // FIREBASE PHONE AUTHENTICATION NATIVO
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // Verificación automática (solo Android)
        verificationCompleted: (PhoneAuthCredential credential) async {
          AppLogger.info('Verificación automática completada', tag: 'Auth');
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            await _handleSuccessfulAuth(userCredential.user);
          } catch (e) {
            AppLogger.error(
              'Error en verificación automática',
              tag: 'Auth',
              error: e,
            );
          }
        },

        // Error al enviar
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.error(
            'Firebase verification failed',
            tag: 'Auth',
            error: e,
          );
          _state = AuthState.error;

          if (e.code == 'invalid-phone-number') {
            _errorMessage = 'err_invalid_phone_format';
          } else if (e.code == 'too-many-requests') {
            _errorMessage = 'err_too_many_requests';
          } else {
            _errorMessage = e.message ?? 'err_send_code';
          }
          notifyListeners();
        },

        // Código enviado correctamente
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.info('SMS enviado correctamente', tag: 'Auth');

          _verificationId = verificationId;
          _resendToken = resendToken;
          _state = AuthState.codeSent;
          _startResendTimer();
          notifyListeners();
        },

        // Timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.debug('Auto-retrieval timeout', tag: 'Auth');
          _verificationId = verificationId;
        },

        // Token para reenviar
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      AppLogger.error('Error enviando código', tag: 'Auth', error: e);
      _state = AuthState.error;
      _errorMessage = 'err_send_code';
      notifyListeners();
    }
  }

  /// VALIDAR CÓDIGO SMS
  Future<void> validateCode(String code) async {
    if (_verificationId == null) {
      _state = AuthState.error;
      _errorMessage = 'err_request_new_code';
      notifyListeners();
      return;
    }

    try {
      AppLogger.info('Verificando código SMS', tag: 'Auth');

      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      // Crear credencial
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      // Autenticar
      final userCredential = await _auth.signInWithCredential(credential);
      await _handleSuccessfulAuth(userCredential.user);
    } catch (e) {
      AppLogger.error('Error verificando código', tag: 'Auth', error: e);
      _state = AuthState.error;

      if (e.toString().contains('invalid-verification-code')) {
        _errorMessage = 'err_invalid_code';
      } else if (e.toString().contains('session-expired')) {
        _errorMessage = 'err_code_expired_request_new';
      } else {
        _errorMessage = 'err_verify_code';
      }
      notifyListeners();
    }
  }

  /// Login directo para admin (controlado por Remote Config)
  Future<void> _loginAdminDirecto(String phoneNumber) async {
    try {
      AppLogger.info('Iniciando login admin', tag: 'Auth');

      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      if (user == null) {
        throw Exception('err_create_session');
      }

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'phone': phoneNumber,
        'phoneNumber': phoneNumber,
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'loginMethod': 'admin_directo',
      }, SetOptions(merge: true));

      AppLogger.info('Admin autenticado: ${user.uid}', tag: 'Auth');

      await _handleSuccessfulAuth(user);
    } catch (e) {
      AppLogger.error('Error login admin', tag: 'Auth', error: e);
      _state = AuthState.error;
      _errorMessage = 'err_admin_login';
      notifyListeners();
    }
  }

  Future<void> _handleSuccessfulAuth(User? user) async {
    AppLogger.info('Auth exitosa: ${user?.uid}', tag: 'Auth');

    final userDoc = await _firestore.collection('users').doc(user?.uid).get();

    _needsProfileSetup = !userDoc.exists || userDoc.data()?['name'] == null;

    // Guardar el phoneNumber si no está en el documento
    if (user != null && _phoneNumber != null && _phoneNumber!.isNotEmpty) {
      final existingPhone = userDoc.data()?['phoneNumber'] ?? '';
      if (existingPhone.toString().isEmpty) {
        await _firestore.collection('users').doc(user.uid).set({
          'phoneNumber': _phoneNumber,
        }, SetOptions(merge: true));
      }
    }

    try {
      await NotificationService().initialize();
    } catch (e) {
      AppLogger.warning(
        'Error inicializando notificaciones',
        tag: 'Auth',
        error: e,
      );
    }

    // Registrar la sesión del dispositivo actual
    if (user != null) {
      try {
        final platform = Platform.isIOS ? 'ios' : 'android';
        final now = DateTime.now();
        final sessionEntry = {
          'deviceName': Platform.isIOS ? 'iPhone' : 'Android',
          'platform': platform,
          'phoneNumber': _phoneNumber ?? '',
          'lastActive': now.toIso8601String(),
          'timestamp': now.millisecondsSinceEpoch,
        };
        await _firestore.collection('users').doc(user.uid).set({
          'sessions': FieldValue.arrayUnion([sessionEntry]),
        }, SetOptions(merge: true));
      } catch (e) {
        AppLogger.warning('Error registrando sesión', tag: 'Auth', error: e);
      }
    }

    _state = AuthState.authenticated;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _state = AuthState.initial;
      _verificationId = null;
      _phoneNumber = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'err_sign_out';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
