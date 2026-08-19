import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:biux/core/services/app_logger.dart';

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
    } else {}

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!_isWebPlatform) {
        // Solo en mobile actualizar el estado de autenticación
        if (_user != user) {
          _user = user;
          AppLogger.debug(
            'Estado de autenticación cambió: ${user?.uid ?? "null"}',
            tag: 'AuthNotifier',
          );
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
