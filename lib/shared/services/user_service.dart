import "package:flutter/foundation.dart";
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:biux/features/users/data/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<UserModel?> getUserData(String uid) async {
    try {
      debugPrint('🐛 DEBUG - Obteniendo datos del usuario: $uid');
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('🐛 DEBUG - Datos obtenidos: $data');

        try {
          return UserModel.fromMap(data);
        } catch (parseError) {
          debugPrint('⚠️ Error parseando datos del usuario: $parseError');
          // Retornar un UserModel básico con los datos disponibles
          return UserModel(
            uid: uid,
            phoneNumber: data['phoneNumber'] ?? uid,
            name: data['name'],
            email: data['email'],
            photoUrl: data['photoUrl'],
            isAdmin: data['isAdmin'] ?? false, // Leer desde Firebase
          );
        }
      }
      debugPrint('🐛 DEBUG - Documento de usuario no existe');
      return null;
    } catch (e) {
      debugPrint('❌ Error obteniendo datos del usuario: $e');
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
                  debugPrint(
                    '🔄 Datos del usuario actualizados en tiempo real: $uid',
                  );
                } catch (parseError) {
                  debugPrint('⚠️ Error parseando datos en listener: $parseError');
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
              debugPrint('Error en listener de usuario: $error');
            },
          );
    } catch (e) {
      debugPrint('❌ Error configurando listener: $e');
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
    debugPrint('🔍 ====== USER SERVICE: updateUserProfile ======');
    debugPrint('🆔 UID: $uid');
    debugPrint('📝 Nombre: "$name"');
    debugPrint('📧 Email: "$email"');
    debugPrint('📋 Descripción: "$description"');
    debugPrint('👤 Username: "$username"');
    debugPrint('🖼️ Foto de perfil: "$photoUrl"');
    debugPrint('🏞️ Foto de portada: "$coverPhotoUrl"');

    try {
      // Validar UID
      if (uid.isEmpty) {
        debugPrint('❌ ERROR: UID vacío');
        return false;
      }

      Map<String, dynamic> updateData = {};

      if (name != null) {
        updateData['name'] = name.trim();
        debugPrint('✅ Nombre agregado a updateData: "${name.trim()}"');
      }
      if (email != null) {
        updateData['email'] = email.trim();
        debugPrint('✅ Email agregado a updateData: "${email.trim()}"');
      }
      if (description != null) {
        // Permitir descripciones vacías (cadena vacía después de trim)
        updateData['description'] = description.trim();
        debugPrint('✅ Descripción agregada a updateData: "${description.trim()}"');
      }
      if (username != null) {
        updateData['username'] = username.trim();
        debugPrint('✅ Username agregado a updateData: "${username.trim()}"');
      }
      // Detectar eliminación de fotos (cadena vacía)
      if (photoUrl != null) {
        if (photoUrl.isEmpty) {
          // Eliminar foto: establecer como null
          updateData['photoUrl'] = null;
          debugPrint('✅ Foto de perfil establecida para eliminación (null)');
        } else {
          updateData['photoUrl'] = photoUrl.trim();
          debugPrint('✅ Foto de perfil agregada a updateData');
        }
      }
      if (coverPhotoUrl != null) {
        if (coverPhotoUrl.isEmpty) {
          // Eliminar foto: establecer como null
          updateData['coverPhotoUrl'] = null;
          debugPrint('✅ Foto de portada establecida para eliminación (null)');
        } else {
          updateData['coverPhotoUrl'] = coverPhotoUrl.trim();
          debugPrint('✅ Foto de portada agregada a updateData');
        }
      }

      // Si no hay datos para actualizar, retornar false
      if (updateData.isEmpty) {
        debugPrint('❌ ERROR: updateData vacío después de procesar');
        return false;
      }

      // Agregar timestamp de última actualización
      updateData['updatedAt'] = DateTime.now().toIso8601String();
      debugPrint('⏰ Timestamp agregado: ${updateData['updatedAt']}');

      debugPrint('📦 Datos a guardar en Firestore: $updateData');
      debugPrint('🗄️ Colección: users, Documento: $uid');

      await _firestore
          .collection('users')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));

      debugPrint('✅ Actualización guardada exitosamente en Firestore');
      debugPrint('🔍 ====== FIN DE ACTUALIZACIÓN ======\n');
      return true;
    } catch (e) {
      debugPrint('❌ EXCEPCIÓN en updateUserProfile: $e');
      debugPrint('   Tipo: ${e.runtimeType}');
      debugPrint('   Stack trace:');
      debugPrint(StackTrace.current.toString());
      debugPrint('🔍 ====== FIN DE ACTUALIZACIÓN (ERROR) ======\n');
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
      debugPrint('Error subiendo imagen: $e');
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
      debugPrint('Error solicitando eliminación: $e');
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
        debugPrint('🔐 Creando usuario: $uid');
        debugPrint('👤 Teléfono: $phoneNumber');

        UserModel newUser = UserModel(uid: uid, phoneNumber: phoneNumber);
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        debugPrint('✅ Usuario creado');
      }
      return true;
    } catch (e) {
      debugPrint('Error creando usuario: $e');
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
      debugPrint('Error actualizando permiso de vendedor: $e');
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
      debugPrint('Error obteniendo usuarios: $e');
      return [];
    }
  }

  /// Seguir a un usuario
  Future<bool> followUser({
    required String currentUserId,
    required String userIdToFollow,
  }) async {
    try {
      debugPrint('📱 Iniciando seguimiento de $userIdToFollow por $currentUserId');

      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final userToFollowRef = _firestore
          .collection('users')
          .doc(userIdToFollow);

      // Obtener los documentos actuales
      debugPrint('🔍 Buscando usuario actual: $currentUserId');
      final currentUserDoc = await currentUserRef.get();
      debugPrint('🔍 Usuario actual existe: ${currentUserDoc.exists}');

      debugPrint('🔍 Buscando usuario a seguir: $userIdToFollow');
      final userToFollowDoc = await userToFollowRef.get();
      debugPrint('🔍 Usuario a seguir existe: ${userToFollowDoc.exists}');

      if (!currentUserDoc.exists || !userToFollowDoc.exists) {
        debugPrint('❌ Usuario no encontrado');
        return false;
      }

      debugPrint('📋 Extrayendo datos del usuario actual...');
      final currentUserData = currentUserDoc.data();
      if (currentUserData == null) {
        debugPrint('❌ Datos del usuario actual son null');
        return false;
      }
      debugPrint('✅ Datos del usuario actual obtenidos');

      debugPrint('📋 Extrayendo datos del usuario a seguir...');
      final userToFollowData = userToFollowDoc.data();
      if (userToFollowData == null) {
        debugPrint('❌ Datos del usuario a seguir son null');
        return false;
      }
      debugPrint('✅ Datos del usuario a seguir obtenidos');

      // Actualizar 'following' del usuario actual
      debugPrint('🔄 Actualizando "following" del usuario actual...');
      Map<String, dynamic> following = Map<String, dynamic>.from(
        currentUserData['following'] ?? {},
      );
      debugPrint('   Following actual: $following');
      following[userIdToFollow] = true;
      debugPrint('   Following nuevo: $following');
      int newFollowingCount = following.length;

      // Actualizar 'followers' del usuario a seguir
      debugPrint('🔄 Actualizando "followers" del usuario a seguir...');
      Map<String, dynamic> followers = Map<String, dynamic>.from(
        userToFollowData['followers'] ?? {},
      );
      debugPrint('   Followers actual: $followers');
      followers[currentUserId] = true;
      debugPrint('   Followers nuevo: $followers');
      int newFollowerSCount = followers.length;

      // Guardar los cambios
      debugPrint('💾 Guardando cambios en usuario actual...');
      await currentUserRef.update({
        'following': following,
        'followingCount': newFollowingCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Cambios guardados en usuario actual');

      debugPrint('💾 Guardando cambios en usuario a seguir...');
      await userToFollowRef.update({
        'followers': followers,
        'followerS': newFollowerSCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Cambios guardados en usuario a seguir');

      debugPrint('✅ Ahora sigues a $userIdToFollow');
      return true;
    } catch (e, st) {
      debugPrint('❌ Error siguiendo usuario: $e');
      debugPrint('   Stack trace: $st');
      return false;
    }
  }

  /// Dejar de seguir a un usuario
  Future<bool> unfollowUser({
    required String currentUserId,
    required String userIdToUnfollow,
  }) async {
    try {
      debugPrint('📱 Dejando de seguir a $userIdToUnfollow por $currentUserId');

      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final userToUnfollowRef = _firestore
          .collection('users')
          .doc(userIdToUnfollow);

      // Obtener los documentos actuales
      final currentUserDoc = await currentUserRef.get();
      final userToUnfollowDoc = await userToUnfollowRef.get();

      if (!currentUserDoc.exists || !userToUnfollowDoc.exists) {
        debugPrint('❌ Usuario no encontrado');
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
      debugPrint('   Following actual: $following');
      following.remove(userIdToUnfollow);
      debugPrint('   Following nuevo: $following');
      int newFollowingCount = following.length;

      // Actualizar 'followers' del usuario
      Map<String, dynamic> followers = Map<String, dynamic>.from(
        userToUnfollowData['followers'] ?? {},
      );
      debugPrint('   Followers actual: $followers');
      followers.remove(currentUserId);
      debugPrint('   Followers nuevo: $followers');
      int newFollowerSCount = followers.length;

      // Validación: asegurar que el contador no sea negativo
      debugPrint('⚠️ Validación: newFollowerSCount = $newFollowerSCount');
      if (newFollowerSCount < 0) {
        debugPrint('🚨 ERROR: Contador negativo detectado! Fijando a 0');
        newFollowerSCount = 0;
      }
      if (newFollowingCount < 0) {
        debugPrint('🚨 ERROR: Contador de following negativo! Fijando a 0');
        newFollowingCount = 0;
      }

      // Guardar los cambios
      debugPrint('💾 Guardando cambios en usuario actual...');
      await currentUserRef.update({
        'following': following,
        'followingCount': newFollowingCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Cambios guardados en usuario actual');

      debugPrint('💾 Guardando cambios en usuario a seguir...');
      await userToUnfollowRef.update({
        'followers': followers,
        'followerS': newFollowerSCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Cambios guardados en usuario a seguir');

      debugPrint('✅ Dejaste de seguir a $userIdToUnfollow');
      return true;
    } catch (e) {
      debugPrint('❌ Error dejando de seguir: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      return false;
    }
  }
}

// Resolución de conflictos: Mantener la lógica más reciente y relevante para el proyecto.
