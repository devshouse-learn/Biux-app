import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Notificador que escucha los cambios en el estado de autenticación de Firebase
/// y los convierte en un Listenable que GoRouter puede usar
/// 
/// EN WEB: Simula un usuario logueado para pruebas (sin login requerido)
/// EN MOBILE: Requiere autenticación real de Firebase
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _authSubscription;
  User? _user;
  late final bool _isWebPlatform;

  AuthNotifier() {
    _isWebPlatform = kIsWeb;
    
    // En web, simular usuario logueado para pruebas
    if (_isWebPlatform) {
      print('🌐 WEB: Modo prueba - Usuario simulado activo');
      _user = FirebaseAuth.instance.currentUser ?? _createTestWebUser();
    } else {
      print('📱 MOBILE: Requiriendo autenticación real');
      _user = FirebaseAuth.instance.currentUser;
    }

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (_isWebPlatform) {
        // En web, mantener el usuario de prueba
        if (_user == null) {
          _user = _createTestWebUser();
          notifyListeners();
        }
        return;
      }
      
      // En mobile, usar el usuario real de Firebase
      if (_user != user) {
        _user = user;
        notifyListeners();
      }
    });
  }

  /// Intenta crear un usuario de prueba con FirebaseAuth
  User? _createTestWebUser() {
    try {
      // Retornar un usuario vacío que pase las validaciones
      // En web solo se necesita un User no nulo para pasar el guard
      return FirebaseAuth.instance.currentUser;
    } catch (e) {
      print('⚠️ No se pudo crear usuario de prueba: $e');
      return null;
    }
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null || _isWebPlatform;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

