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
    _user = FirebaseAuth.instance.currentUser;

    if (_isWebPlatform) {
      print('🌐 WEB: Modo desarrollo - Saltando autenticación');
    } else {
      print('📱 MOBILE: Requiriendo autenticación real');
    }

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!_isWebPlatform) {
        // Solo en mobile actualizar el estado de autenticación
        if (_user != user) {
          _user = user;
          print('🔄 Estado de autenticación cambió: ${user?.uid ?? "null"}');
          notifyListeners();
        }
      }
    });
  }

  User? get user => _user;

  // En web, siempre retornar true para saltear autenticación
  // En mobile, verificar si hay usuario
  bool get isLoggedIn => _isWebPlatform ? true : _user != null;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
