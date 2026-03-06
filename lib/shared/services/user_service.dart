import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:biux/features/users/data/models/user_model.dart';
import 'package:biux/core/services/app_logger.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<UserModel?> getUserData(String uid) async {
    try {
      AppLogger.debug('Obteniendo datos del usuario: $uid', tag: 'UserService');
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        try {
          return UserModel.fromMap(data);
        } catch (parseError) {
          AppLogger.warning(
            'Error parseando datos del usuario',
            tag: 'UserService',
            error: parseError,
          );
          return UserModel(
            uid: uid,
            phoneNumber: data['phoneNumber'] ?? uid,
            name: data['name'],
            email: data['email'],
            photoUrl: data['photoUrl'],
            isAdmin: data['isAdmin'] ?? false,
          );
        }
      }
      AppLogger.debug(
        'Documento de usuario no existe: $uid',
        tag: 'UserService',
      );
      return null;
    } catch (e) {
      AppLogger.error(
        'Error obteniendo datos del usuario',
        tag: 'UserService',
        error: e,
      );
      return null;
    }
  }

  // Escuchar cambios en tiempo real del usuario
  void listenToUser(String uid, Function(UserModel?) onDataChanged) {
    try {
      _firestore
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen(
            (doc) {
              if (doc.exists) {
                final data = doc.data() as Map<String, dynamic>;
                try {
                  final userData = UserModel.fromMap(data);
                  onDataChanged(userData);
                } catch (parseError) {
                  AppLogger.warning(
                    'Error parseando datos en listener',
                    tag: 'UserService',
                    error: parseError,
                  );
                  final userData = UserModel(
                    uid: uid,
                    phoneNumber: data['phoneNumber'] ?? uid,
                    name: data['name'],
                    email: data['email'],
                    photoUrl: data['photoUrl'],
                    isAdmin: data['isAdmin'] ?? false,
                  );
                  onDataChanged(userData);
                }
              } else {
                onDataChanged(null);
              }
            },
            onError: (error) {
              AppLogger.error(
                'Error en listener de usuario',
                tag: 'UserService',
                error: error,
              );
            },
          );
    } catch (e) {
      AppLogger.error(
        'Error configurando listener',
        tag: 'UserService',
        error: e,
      );
    }
  }

  Future<bool> updateUserProfile({
    required String uid,
    String? name,
    String? email,
    String? description,
    String? username,
    String? photoUrl,
    String? coverPhotoUrl,
  }) async {
    AppLogger.debug('updateUserProfile: $uid', tag: 'UserService');

    try {
      if (uid.isEmpty) {
        AppLogger.warning('UID vacío en updateUserProfile', tag: 'UserService');
        return false;
      }

      Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name.trim();
      if (email != null) updateData['email'] = email.trim();
      if (description != null) updateData['description'] = description.trim();
      if (username != null) updateData['username'] = username.trim();
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl.isEmpty ? null : photoUrl.trim();
      }
      if (coverPhotoUrl != null) {
        updateData['coverPhotoUrl'] = coverPhotoUrl.isEmpty
            ? null
            : coverPhotoUrl.trim();
      }

      if (updateData.isEmpty) {
        AppLogger.debug('No hay datos para actualizar', tag: 'UserService');
        return false;
      }

      updateData['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection('users')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));

      AppLogger.info('Perfil actualizado: $uid', tag: 'UserService');
      return true;
    } catch (e) {
      AppLogger.error(
        'Error en updateUserProfile',
        tag: 'UserService',
        error: e,
      );
      return false;
    }
  }

  Future<String?> uploadProfileImage(String uid) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        File file = File(image.path);

        Reference ref = _storage.ref().child('profile_images/$uid.jpg');
        UploadTask uploadTask = ref.putFile(file);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Actualizar URL en Firestore
        await _firestore.collection('users').doc(uid).update({
          'photoUrl': downloadUrl,
        });

        return downloadUrl;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error subiendo imagen', tag: 'UserService', error: e);
      return null;
    }
  }

  Future<bool> requestAccountDeletion(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isDeleting': true,
        'deletionRequestDate': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      AppLogger.error(
        'Error solicitando eliminación',
        tag: 'UserService',
        error: e,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> createUserIfNotExists(String uid, String phoneNumber) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (!doc.exists) {
        AppLogger.info('Creando usuario: $uid', tag: 'UserService');

        UserModel newUser = UserModel(uid: uid, phoneNumber: phoneNumber);
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
      }
      return true;
    } catch (e) {
      AppLogger.error('Error creando usuario', tag: 'UserService', error: e);
      return false;
    }
  }

  /// Actualizar permiso de vendedor (solo administradores)
  Future<bool> updateSellerPermission(String userId, bool canSell) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'canSellProducts': canSell,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      AppLogger.error(
        'Error actualizando permiso de vendedor',
        tag: 'UserService',
        error: e,
      );
      return false;
    }
  }

  /// Obtener todos los usuarios (solo administradores)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Error obteniendo usuarios',
        tag: 'UserService',
        error: e,
      );
      return [];
    }
  }

  /// Seguir a un usuario
  Future<bool> followUser({
    required String currentUserId,
    required String userIdToFollow,
  }) async {
    try {
      AppLogger.debug('Siguiendo a $userIdToFollow', tag: 'UserService');

      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final userToFollowRef = _firestore
          .collection('users')
          .doc(userIdToFollow);

      final currentUserDoc = await currentUserRef.get();
      final userToFollowDoc = await userToFollowRef.get();

      if (!currentUserDoc.exists || !userToFollowDoc.exists) {
        AppLogger.warning(
          'Usuario no encontrado para follow',
          tag: 'UserService',
        );
        return false;
      }

      final currentUserData = currentUserDoc.data();
      if (currentUserData == null) return false;

      final userToFollowData = userToFollowDoc.data();
      if (userToFollowData == null) return false;

      // Actualizar 'following' del usuario actual
      Map<String, dynamic> following = Map<String, dynamic>.from(
        currentUserData['following'] ?? {},
      );
      following[userIdToFollow] = true;
      int newFollowingCount = following.length;

      // Actualizar 'followers' del usuario a seguir
      Map<String, dynamic> followers = Map<String, dynamic>.from(
        userToFollowData['followers'] ?? {},
      );
      followers[currentUserId] = true;
      int newFollowerSCount = followers.length;

      await currentUserRef.update({
        'following': following,
        'followingCount': newFollowingCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await userToFollowRef.update({
        'followers': followers,
        'followerS': newFollowerSCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      AppLogger.info('Ahora sigues a $userIdToFollow', tag: 'UserService');
      return true;
    } catch (e) {
      AppLogger.error('Error siguiendo usuario', tag: 'UserService', error: e);
      return false;
    }
  }

  /// Dejar de seguir a un usuario
  Future<bool> unfollowUser({
    required String currentUserId,
    required String userIdToUnfollow,
  }) async {
    try {
      AppLogger.debug(
        'Dejando de seguir a $userIdToUnfollow',
        tag: 'UserService',
      );

      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final userToUnfollowRef = _firestore
          .collection('users')
          .doc(userIdToUnfollow);

      final currentUserDoc = await currentUserRef.get();
      final userToUnfollowDoc = await userToUnfollowRef.get();

      if (!currentUserDoc.exists || !userToUnfollowDoc.exists) {
        AppLogger.warning(
          'Usuario no encontrado para unfollow',
          tag: 'UserService',
        );
        return false;
      }

      Map<String, dynamic> currentUserData =
          currentUserDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> userToUnfollowData =
          userToUnfollowDoc.data() as Map<String, dynamic>;

      // Actualizar 'following' del usuario actual
      Map<String, dynamic> following = Map<String, dynamic>.from(
        currentUserData['following'] ?? {},
      );
      following.remove(userIdToUnfollow);
      int newFollowingCount = following.length;

      // Actualizar 'followers' del usuario
      Map<String, dynamic> followers = Map<String, dynamic>.from(
        userToUnfollowData['followers'] ?? {},
      );
      followers.remove(currentUserId);
      int newFollowerSCount = followers.length;

      // Validación: asegurar que el contador no sea negativo
      if (newFollowerSCount < 0) newFollowerSCount = 0;
      if (newFollowingCount < 0) newFollowingCount = 0;

      await currentUserRef.update({
        'following': following,
        'followingCount': newFollowingCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await userToUnfollowRef.update({
        'followers': followers,
        'followerS': newFollowerSCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      AppLogger.info(
        'Dejaste de seguir a $userIdToUnfollow',
        tag: 'UserService',
      );
      return true;
    } catch (e) {
      AppLogger.error('Error dejando de seguir', tag: 'UserService', error: e);
      return false;
    }
  }
}
