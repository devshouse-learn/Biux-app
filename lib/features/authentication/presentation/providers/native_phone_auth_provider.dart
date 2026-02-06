import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/shared/services/notification_service.dart';

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
  /// ✅ ADMIN BYPASS: Si es el número admin (3132332038), login automático
  Future<void> sendCode(String phoneNumber) async {
    try {
      // ✅ VERIFICAR SI ES EL NÚMERO DE ADMIN (sin código)
      // Detectar: 3132332038, +573132332038, 573132332038
      final phoneClean = phoneNumber.replaceAll('+', '').replaceAll(' ', '').trim();
      final isAdmin = phoneClean == '3132332038' || 
                     phoneClean == '573132332038' ||
                     phoneNumber.contains('3132332038');
      
      if (isAdmin) {
        print('👑👑👑 ADMIN DETECTADO: $phoneNumber 👑👑👑');
        print('✅ ENTRANDO SIN CÓDIGO...');
        
        _state = AuthState.loading;
        notifyListeners();
        
        // Login DIRECTO sin Firebase
        await _loginAdminDirecto(phoneNumber);
        return;
      }
      
      print('');
      print('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');
      print('📲 FIREBASE PHONE AUTH - SMS REAL');
      print('📞 Enviando código a: $phoneNumber');
      print('🔥 Firebase enviará SMS automáticamente');
      print('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');
      print('');

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
          print('✅ Verificación automática completada');
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            await _handleSuccessfulAuth(userCredential.user);
          } catch (e) {
            print('❌ Error en verificación automática: $e');
          }
        },
        
        // Error al enviar
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Firebase Error: ${e.code} - ${e.message}');
          _state = AuthState.error;
          
          if (e.code == 'invalid-phone-number') {
            _errorMessage = 'Número inválido. Verifica el formato (+57XXXXXXXXXX)';
          } else if (e.code == 'too-many-requests') {
            _errorMessage = 'Demasiados intentos. Espera unos minutos.';
          } else {
            _errorMessage = e.message ?? 'Error al enviar código';
          }
          notifyListeners();
        },
        
        // Código enviado correctamente ✅
        codeSent: (String verificationId, int? resendToken) {
          print('');
          print('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅');
          print('✅ SMS ENVIADO POR FIREBASE');
          print('✅ Número: $phoneNumber');
          print('✅ Revisa tu teléfono');
          print('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅');
          print('');
          
          _verificationId = verificationId;
          _resendToken = resendToken;
          _state = AuthState.codeSent;
          _startResendTimer();
          notifyListeners();
        },
        
        // Timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Timeout');
          _verificationId = verificationId;
        },
        
        // Token para reenviar
        forceResendingToken: _resendToken,
      );
      
    } catch (e) {
      print('❌ Error: $e');
      _state = AuthState.error;
      _errorMessage = 'Error al enviar código: $e';
      notifyListeners();
    }
  }

  /// VALIDAR CÓDIGO SMS
  Future<void> validateCode(String code) async {
    if (_verificationId == null) {
      _state = AuthState.error;
      _errorMessage = 'Error: Solicita un nuevo código';
      notifyListeners();
      return;
    }

    try {
      print('🔐 Verificando código: ${code.replaceAll(RegExp(r'.'), '*')}');

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
      print('❌ Error: $e');
      _state = AuthState.error;
      
      if (e.toString().contains('invalid-verification-code')) {
        _errorMessage = 'Código inválido';
      } else if (e.toString().contains('session-expired')) {
        _errorMessage = 'Código expirado. Solicita uno nuevo';
      } else {
        _errorMessage = 'Error al verificar código';
      }
      notifyListeners();
    }
  }

  /// ✅ LOGIN DIRECTO PARA ADMIN (sin código SMS, sin Firebase Phone Auth)
  Future<void> _loginAdminDirecto(String phoneNumber) async {
    try {
      print('👑 Iniciando login directo admin...');

      // Crear sesión anónima (no requiere verificación)
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      
      if (user == null) {
        throw Exception('No se pudo crear sesión');
      }

      print('✅ Sesión creada: ${user.uid}');

      // Guardar perfil admin en Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'phone': phoneNumber,
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'loginMethod': 'admin_directo',
      }, SetOptions(merge: true));

      print('👑👑👑 ADMIN ENTRÓ SIN CÓDIGO 👑👑👑');
      print('👑 UID: ${user.uid}');
      print('👑 Phone: $phoneNumber');
      print('👑👑👑👑👑👑👑👑👑👑👑👑👑👑👑👑👑👑👑👑');

      // Navegar directo al inicio
      await _handleSuccessfulAuth(user);
      
    } catch (e) {
      print('❌ Error en login automático admin: $e');
      _state = AuthState.error;
      _errorMessage = 'Error al iniciar sesión como admin: $e';
      notifyListeners();
    }
  }

  Future<void> _handleSuccessfulAuth(User? user) async {
    print('✅ Usuario autenticado');
    print('   UID: ${user?.uid}');

    // Verificar perfil
    final userDoc = await _firestore.collection('users').doc(user?.uid).get();
    
    _needsProfileSetup = !userDoc.exists || userDoc.data()?['name'] == null;

    // Notificaciones
    try {
      await NotificationService().initialize();
    } catch (e) {
      print('⚠️ Error notificaciones: $e');
    }

    _state = AuthState.authenticated;
    notifyListeners();
    
    print('✅ AUTENTICACIÓN EXITOSA');
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _state = AuthState.initial;
      _verificationId = null;
      _phoneNumber = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión';
      notifyListeners();
    }
  }
}
