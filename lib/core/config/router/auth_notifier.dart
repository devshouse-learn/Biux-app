import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Notificador que escucha los cambios en el estado de autenticación de Firebase
/// y los convierte en un Listenable que GoRouter puede usar
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _authSubscription;
  User? _user;

  AuthNotifier() {
    _user = FirebaseAuth.instance.currentUser;
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (_user != user) {
        _user = user;
        notifyListeners();
      }
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
