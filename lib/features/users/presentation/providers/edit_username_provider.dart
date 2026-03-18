import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider para manejar la edición del nombre de usuario
class EditUsernameProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentUsername = '';
  bool? _usernameAvailable;
  bool _isCheckingAvailability = false;
  bool _isUpdating = false;
  String _availabilityMessage = '';
  String? _error;
  Timer? _debounceTimer;

  // Getters
  String get currentUsername => _currentUsername;
  bool? get usernameAvailable => _usernameAvailable;
  bool get isCheckingAvailability => _isCheckingAvailability;
  bool get isUpdating => _isUpdating;
  String get availabilityMessage => _availabilityMessage;
  String? get error => _error;

  /// Cargar el username actual del usuario
  Future<void> loadCurrentUsername() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        _currentUsername = data?['username'] ?? '';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error cargando username actual: $e');
    }
  }

  /// Verificar disponibilidad de username con debounce
  void checkUsernameAvailability(String username) {
    // Cancelar timer anterior
    _debounceTimer?.cancel();

    // Limpiar estado si el username está vacío
    if (username.isEmpty) {
      _usernameAvailable = null;
      _availabilityMessage = '';
      notifyListeners();
      return;
    }

    // Si es el mismo username actual, no verificar
    if (username == _currentUsername) {
      _usernameAvailable = true;
      _availabilityMessage = 'username_current';
      notifyListeners();
      return;
    }

    // Validar formato antes de verificar disponibilidad
    if (!_isValidUsernameFormat(username)) {
      _usernameAvailable = false;
      _availabilityMessage = 'username_invalid_format';
      notifyListeners();
      return;
    }

    // Configurar debounce de 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performUsernameCheck(username);
    });
  }

  /// Validar formato de username
  bool _isValidUsernameFormat(String username) {
    if (username.length < 3 || username.length > 30) return false;
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    return regex.hasMatch(username);
  }

  /// Realizar verificación real en Firestore
  Future<void> _performUsernameCheck(String username) async {
    _isCheckingAvailability = true;
    _availabilityMessage = 'username_checking';
    notifyListeners();

    try {
      // Buscar en Firestore si el username ya existe
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _usernameAvailable = true;
        _availabilityMessage = 'username_available';
      } else {
        _usernameAvailable = false;
        _availabilityMessage = 'username_not_available';
      }
    } catch (e) {
      debugPrint('Error verificando disponibilidad: $e');
      _usernameAvailable = null;
      _availabilityMessage = 'username_check_error';
    } finally {
      _isCheckingAvailability = false;
      notifyListeners();
    }
  }

  /// Actualizar username en Firestore
  Future<bool> updateUsername(String newUsername) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _error = 'username_not_authenticated';
        return false;
      }

      // Verificar una vez más que está disponible
      if (newUsername != _currentUsername) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: newUsername)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          _error = 'username_already_taken';
          return false;
        }
      }

      // Actualizar en Firestore
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
      });

      _currentUsername = newUsername;
      return true;
    } catch (e) {
      debugPrint('Error actualizando username: $e');
      _error = 'username_update_error';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
