import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/users/data/models/user_model.dart';

/// Servicio para operaciones de usuario (perfil, follow, etc.).
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtiene los datos del usuario actual desde Firestore.
  Future<UserModel?> getUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap({'id': doc.id, ...doc.data()!});
    } catch (e) {
      debugPrint('⚠️ UserService.getUserData() error: $e');
      return null;
    }
  }

  /// Escucha cambios en tiempo real de un usuario.
  /// Implementa el listener de Firestore con snapshots() para
  /// sincronización automática cada vez que el documento cambia en el servidor.
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
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
    String? description,
    String? coverPhotoUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (displayName != null) updates['fullName'] = displayName;
      if (photoUrl != null) updates['photo'] = photoUrl;
      if (description != null) updates['description'] = description;
      if (coverPhotoUrl != null) updates['coverPhoto'] = coverPhotoUrl;
      if (updates.isEmpty) return;
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      debugPrint('⚠️ UserService.updateUserProfile() error: $e');
      rethrow;
    }
  }

  /// Sube una imagen de perfil (URL ya procesada) y la guarda en Firestore.
  Future<void> uploadProfileImage({
    required String uid,
    required String photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({'photo': photoUrl});
    } catch (e) {
      debugPrint('⚠️ UserService.uploadProfileImage() error: $e');
      rethrow;
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('⚠️ UserService.signOut() error: $e');
      rethrow;
    }
  }

  /// Obtiene todos los usuarios (paginado).
  Future<List<UserModel>> getAllUsers({int limit = 50}) async {
    try {
      final query = await _firestore.collection('users').limit(limit).get();
      return query.docs
          .map((doc) => UserModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('⚠️ UserService.getAllUsers() error: $e');
      return [];
    }
  }

  /// Sigue a un usuario: actualiza arrays followers/following en ambos usuarios
  /// y los contadores usando una escritura batch atómica.
  Future<void> followUser({
    required String currentUid,
    required String targetUid,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.update(_firestore.collection('users').doc(currentUid), {
        'following': FieldValue.arrayUnion([targetUid]),
        'followingCount': FieldValue.increment(1),
      });
      batch.update(_firestore.collection('users').doc(targetUid), {
        'followers': FieldValue.arrayUnion([currentUid]),
        'followersCount': FieldValue.increment(1),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('⚠️ UserService.followUser() error: $e');
      rethrow;
    }
  }

  /// Deja de seguir a un usuario.
  Future<void> unfollowUser({
    required String currentUid,
    required String targetUid,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.update(_firestore.collection('users').doc(currentUid), {
        'following': FieldValue.arrayRemove([targetUid]),
        'followingCount': FieldValue.increment(-1),
      });
      batch.update(_firestore.collection('users').doc(targetUid), {
        'followers': FieldValue.arrayRemove([currentUid]),
        'followersCount': FieldValue.increment(-1),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('⚠️ UserService.unfollowUser() error: $e');
      rethrow;
    }
  }
}
