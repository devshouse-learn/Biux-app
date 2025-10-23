import 'dart:async';

import '../../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:biux/shared/services/notification_service.dart';

enum AuthState { initial, loading, codeSent, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _phoneNumber;
  bool _canResendCode = false;
  int _resendSeconds = 60;
  Timer? _resendTimer;

  AuthProvider({required AuthRepository authRepository})
    : _authRepository = authRepository;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get canResendCode => _canResendCode;
  int get resendSeconds => _resendSeconds;

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
      _state = AuthState.loading;
      _errorMessage = null;
      _phoneNumber = phoneNumber;
      notifyListeners();

      await _authRepository.sendOTP(phoneNumber);
      _state = AuthState.codeSent;
      _startResendTimer();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> validateCode(String code) async {
    if (_phoneNumber == null) return;
    if (_state == AuthState.loading) return;

    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authRepository.validateOTP(
        _phoneNumber!,
        code,
      );

      print('🔑 Token recibido: ${authResponse.token.substring(0, 20)}...');

      // Autenticar con Firebase
      final userCredential = await _auth.signInWithCustomToken(
        authResponse.token,
      );
      final user = userCredential.user;

      print('✅ Usuario autenticado: ${user?.uid}');
      print('🎫 Token ID (para Realtime Database):');
      final idToken = await user?.getIdToken();
      print(idToken?.substring(0, 50));

      // Reinicializar servicio de notificaciones con el usuario autenticado
      await NotificationService().reinitializeAfterLogin();

      _state = AuthState.authenticated;
    } catch (e) {
      _state = AuthState.codeSent;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> resendCode() async {
    if (_phoneNumber != null && _canResendCode) {
      await sendCode(_phoneNumber!);
    }
  }

  Future<void> signOut() async {
    try {
      // Forzar eliminación completa de la sesión
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('🚪 Cerrando sesión de: ${currentUser.uid}');
        // Eliminar tokens cached
        await currentUser.delete().catchError((e) {
          print('⚠️ No se pudo eliminar usuario (normal si es externo): $e');
        });
      }
      await _auth.signOut();
      print('✅ Sesión cerrada completamente');
      _state = AuthState.initial;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      _errorMessage = 'Error al cerrar sesión';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
