import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/models/user_model.dart';
import '../data/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _setLoading(true);
    _error = null;

    try {
      UserModel? userData = await _userService.getUserData(uid);
      _user = userData;
    } catch (e) {
      _error = 'Error cargando datos del usuario';
      print('Error en loadUserData: $e');
    }

    _setLoading(false);
  }

  Future<bool> updateProfile({String? name, String? email}) async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.updateUserProfile(
        uid: _user!.uid,
        name: name,
        email: email,
      );

      if (success) {
        // Actualizar datos locales
        _user = _user!.copyWith(name: name, email: email);
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _error = 'Error actualizando perfil';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> uploadProfileImage() async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      String? imageUrl = await _userService.uploadProfileImage(_user!.uid);

      if (imageUrl != null) {
        _user = _user!.copyWith(photoUrl: imageUrl);
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Error subiendo imagen';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> requestAccountDeletion() async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.requestAccountDeletion(_user!.uid);

      if (success) {
        _user = _user!
            .copyWith(isDeleting: true, deletionRequestDate: DateTime.now());
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _error = 'Error solicitando eliminación';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _userService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> createUserIfNotExists(String uid, String phoneNumber) async {
    await _userService.createUserIfNotExists(uid, phoneNumber);
    await loadUserData();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
