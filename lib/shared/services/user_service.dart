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
      print('🐛 DEBUG - Obteniendo datos del usuario: $uid');
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('🐛 DEBUG - Datos obtenidos: $data');

        try {
          return UserModel.fromMap(data);
        } catch (parseError) {
          print('⚠️ Error parseando datos del usuario: $parseError');
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
      print('🐛 DEBUG - Documento de usuario no existe');
      return null;
    } catch (e) {
      print('❌ Error obteniendo datos del usuario: $e');
      return null;
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
    print('🔍 ====== USER SERVICE: updateUserProfile ======');
    print('🆔 UID: $uid');
    print('📝 Nombre: "$name"');
    print('📧 Email: "$email"');
    print('📋 Descripción: "$description"');
    print('👤 Username: "$username"');
    print('🖼️ Foto de perfil: "$photoUrl"');
    print('🏞️ Foto de portada: "$coverPhotoUrl"');

    try {
      // Validar UID
      if (uid.isEmpty) {
        print('❌ ERROR: UID vacío');
        return false;
      }

      Map<String, dynamic> updateData = {};

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name.trim();
        print('✅ Nombre agregado a updateData');
      }
      if (email != null && email.isNotEmpty) {
        updateData['email'] = email.trim();
        print('✅ Email agregado a updateData');
      }
      if (description != null && description.isNotEmpty) {
        updateData['description'] = description.trim();
        print('✅ Descripción agregada a updateData');
      }
      if (username != null && username.isNotEmpty) {
        updateData['username'] = username.trim();
        print('✅ Username agregado a updateData');
      }
      if (photoUrl != null && photoUrl.isNotEmpty) {
        updateData['photoUrl'] = photoUrl.trim();
        print('✅ Foto de perfil agregada a updateData');
      }
      if (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty) {
        updateData['coverPhotoUrl'] = coverPhotoUrl.trim();
        print('✅ Foto de portada agregada a updateData');
      }

      // Si no hay datos para actualizar, retornar false
      if (updateData.isEmpty) {
        print('❌ ERROR: updateData vacío después de procesar');
        return false;
      }

      // Agregar timestamp de última actualización
      updateData['updatedAt'] = DateTime.now().toIso8601String();
      print('⏰ Timestamp agregado: ${updateData['updatedAt']}');

      print('📦 Datos a guardar en Firestore: $updateData');
      print('🗄️ Colección: users, Documento: $uid');

      await _firestore
          .collection('users')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));

      print('✅ Actualización guardada exitosamente en Firestore');
      print('🔍 ====== FIN DE ACTUALIZACIÓN ======\n');
      return true;
    } catch (e) {
      print('❌ EXCEPCIÓN en updateUserProfile: $e');
      print('   Tipo: ${e.runtimeType}');
      print('   Stack trace:');
      print(StackTrace.current);
      print('🔍 ====== FIN DE ACTUALIZACIÓN (ERROR) ======\n');
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
      print('Error subiendo imagen: $e');
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
      print('Error solicitando eliminación: $e');
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
        print('🔐 Creando usuario: $uid');
        print('👤 Teléfono: $phoneNumber');

        UserModel newUser = UserModel(uid: uid, phoneNumber: phoneNumber);
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        print('✅ Usuario creado');
      }
      return true;
    } catch (e) {
      print('Error creando usuario: $e');
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
      print('Error actualizando permiso de vendedor: $e');
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
      print('Error obteniendo usuarios: $e');
      return [];
    }
  }

  /// Seguir a un usuario
  Future<bool> followUser({
    required String currentUserId,
    required String userIdToFollow,
  }) async {
    try {
      print('📱 Iniciando seguimiento de $userIdToFollow por $currentUserId');

      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final userToFollowRef = _firestore.collection('users').doc(userIdToFollow);

      // Obtener los documentos actuales
      print('🔍 Buscando usuario actual: $currentUserId');
      final currentUserDoc = await currentUserRef.get();
      print('🔍 Usuario actual existe: ${currentUserDoc.exists}');
      
      print('🔍 Buscando usuario a seguir: $userIdToFollow');
      final userToFollowDoc = await userToFollowRef.get();
      print('🔍 Usuario a seguir existe: ${userToFollowDoc.exists}');

      if (!currentUserDoc.exists || !userToFollowDoc.exists) {
        print('❌ Usuario no encontrado');
        return false;
      }

      print('📋 Extrayendo datos del usuario actual...');
      final currentUserData = currentUserDoc.data();
      if (currentUserData == null) {
        print('❌ Datos del usuario actual son null');
        return false;
      }
      print('✅ Datos del usuario actual obtenidos');

      print('📋 Extrayendo datos del usuario a seguir...');
      final userToFollowData = userToFollowDoc.data();
      if (userToFollowData == null) {
        print('❌ Datos del usuario a seguir son null');
        return false;
      }
      print('✅ Datos del usuario a seguir obtenidos');

      // Actualizar 'following' del usuario actual
      print('🔄 Actualizando "following" del usuario actual...');
      Map<String, dynamic> following = Map<String, dynamic>.from(currentUserData['following'] ?? {});
      print('   Following actual: $following');
      following[userIdToFollow] = true;
      print('   Following nuevo: $following');
      int newFollowingCount = following.length;

      // Actualizar 'followers' del usuario a seguir
      print('🔄 Actualizando "followers" del usuario a seguir...');
      Map<String, dynamic> followers = Map<String, dynamic>.from(userToFollowData['followers'] ?? {});
      print('   Followers actual: $followers');
      followers[currentUserId] = true;
      print('   Followers nuevo: $followers');
      int newFollowerSCount = followers.length;

      // Guardar los cambios
      print('💾 Guardando cambios en usuario actual...');
      await currentUserRef.update({
        'following': following,
        'followingCount': newFollowingCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ Cambios guardados en usuario actual');

      print('💾 Guardando cambios en usuario a seguir...');
      await userToFollowRef.update({
        'followers': followers,
        'followerS': newFollowerSCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ Cambios guardados en usuario a seguir');

      print('✅ Ahora sigues a $userIdToFollow');
      return true;
    } catch (e, st) {
      print('❌ Error siguiendo usuario: $e');
      print('   Stack trace: $st');
      return false;
    }
  }

  /// Dejar de seguir a un usuario
  Future<bool> unfollowUser({
    required String currentUserId,
    required String userIdToUnfollow,
  }) async {
    try {
      print('📱 Dejando de seguir a $userIdToUnfollow por $currentUserId');

      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final userToUnfollowRef = _firestore.collection('users').doc(userIdToUnfollow);

      // Obtener los documentos actuales
      final currentUserDoc = await currentUserRef.get();
      final userToUnfollowDoc = await userToUnfollowRef.get();

      if (!currentUserDoc.exists || !userToUnfollowDoc.exists) {
        print('❌ Usuario no encontrado');
        return false;
      }

      Map<String, dynamic> currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> userToUnfollowData = userToUnfollowDoc.data() as Map<String, dynamic>;

      // Actualizar 'following' del usuario actual
      Map<String, dynamic> following = Map<String, dynamic>.from(currentUserData['following'] ?? {});
      print('   Following actual: $following');
      following.remove(userIdToUnfollow);
      print('   Following nuevo: $following');
      int newFollowingCount = following.length;

      // Actualizar 'followers' del usuario
      Map<String, dynamic> followers = Map<String, dynamic>.from(userToUnfollowData['followers'] ?? {});
      print('   Followers actual: $followers');
      followers.remove(currentUserId);
      print('   Followers nuevo: $followers');
      int newFollowerSCount = followers.length;

      // Guardar los cambios
      print('💾 Guardando cambios en usuario actual...');
      await currentUserRef.update({
        'following': following,
        'followingCount': newFollowingCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ Cambios guardados en usuario actual');

      print('💾 Guardando cambios en usuario a seguir...');
      await userToUnfollowRef.update({
        'followers': followers,
        'followerS': newFollowerSCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ Cambios guardados en usuario a seguir');

      print('✅ Dejaste de seguir a $userIdToUnfollow');
      return true;
    } catch (e) {
      print('❌ Error dejando de seguir: $e');
      print('   Stack trace: ${StackTrace.current}');
      return false;
    }
  }
}
