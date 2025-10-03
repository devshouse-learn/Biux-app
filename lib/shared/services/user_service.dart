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
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String uid,
    String? name,
    String? email,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;

      await _firestore
          .collection('users')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));

      // Firebase Auth maneja automáticamente la información del usuario
      // No es necesario actualizar manualmente el email en Auth

      return true;
    } catch (e) {
      print('Error actualizando perfil: $e');
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
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        UserModel newUser = UserModel(
          uid: uid,
          phoneNumber: phoneNumber,
        );
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
      }
      return true;
    } catch (e) {
      print('Error creando usuario: $e');
      return false;
    }
  }
}
