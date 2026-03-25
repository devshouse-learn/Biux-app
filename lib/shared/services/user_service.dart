import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:biux/features/users/data/models/user_model.dart';

/// Servicio para operaciones de usuario (perfil, follow, etc.).
class UserService {
  final _firestore = FirebaseFirestore.instance;

  UserService();

  /// Obtiene datos de un usuario por UID.
  Future<UserModel?> getUserData(String uid) async {
    debugPrint('⚠️ UserService.getUserData() — STUB: sin implementar');
    return null;
  }

  /// Escucha cambios en tiempo real de un usuario.
  void listenToUser(String uid, void Function(UserModel?) callback) {
    _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              try {
                callback(
                  UserModel.fromMap({'id': snapshot.id, ...snapshot.data()!}),
                );
              } catch (e) {
                debugPrint('⚠️ UserService.listenToUser() parse error: $e');
                callback(null);
              }
            } else {
              callback(null);
            }
          },
          onError: (error) {
            debugPrint('⚠️ UserService.listenToUser() stream error: $error');
            callback(null);
          },
        );
  }

  /// Actualiza el perfil de un usuario.
  Future<bool> updateUserProfile({
    required String uid,
    String? name,
    String? email,
    String? description,
    String? username,
    String? photoUrl,
    String? coverPhotoUrl,
  }) async {
    debugPrint('⚠️ UserService.updateUserProfile() — STUB: sin implementar');
    return false;
  }

  /// Sube una imagen de perfil y retorna la URL.
  Future<String?> uploadProfileImage(String uid) async {
    debugPrint('⚠️ UserService.uploadProfileImage() — STUB: sin implementar');
    return null;
  }

  /// Solicita la eliminación de la cuenta.
  Future<bool> requestAccountDeletion(String uid) async {
    debugPrint(
      '⚠️ UserService.requestAccountDeletion() — STUB: sin implementar',
    );
    return false;
  }

  /// Cierra la sesión del usuario.
  Future<void> signOut() async {
    debugPrint('⚠️ UserService.signOut() — STUB: sin implementar');
  }

  /// Crea un usuario en Firestore si no existe.
  Future<void> createUserIfNotExists(String uid, String phoneNumber) async {
    debugPrint(
      '⚠️ UserService.createUserIfNotExists() — STUB: sin implementar',
    );
  }

  /// Actualiza permiso de vendedor para un usuario.
  Future<bool> updateSellerPermission(String userId, bool canSell) async {
    debugPrint(
      '⚠️ UserService.updateSellerPermission() — STUB: sin implementar',
    );
    return false;
  }

  /// Obtiene todos los usuarios.
  Future<List<UserModel>> getAllUsers() async {
    debugPrint('⚠️ UserService.getAllUsers() — STUB: sin implementar');
    return [];
  }

  /// Sigue a un usuario.
  Future<bool> followUser({
    required String currentUserId,
    required String userIdToFollow,
  }) async {
    debugPrint('⚠️ UserService.followUser() — STUB: sin implementar');
    return false;
  }

  /// Deja de seguir a un usuario.
  Future<bool> unfollowUser({
    required String currentUserId,
    required String userIdToUnfollow,
  }) async {
    debugPrint('⚠️ UserService.unfollowUser() — STUB: sin implementar');
    return false;
  }
}
