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

  // Lista de UIDs de administradores (solo para simuladores móviles)
  // Agrega aquí los UIDs de los usuarios que deben ser administradores
  static const List<String> ADMIN_UIDS = [
    // Ejemplo: 'phone_573132332038', // Tu número de teléfono
    // Los UIDs aquí son SOLO para simuladores móviles
    // Chrome web tiene su propio admin automático
  ];

  // ⚠️ MODO DE PRUEBA DESACTIVADO - Permisos reales desde Firebase
  static const bool ADMIN_TEST_MODE = false;

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

        // Verificar si el usuario está en la lista de admins
        final isInAdminList = ADMIN_UIDS.contains(uid);
        final currentIsAdmin = data['isAdmin'] ?? false;

        // Solo promover si está en la lista ADMIN_UIDS (no por modo de prueba)
        if (isInAdminList && !currentIsAdmin) {
          print('🔄 Auto-promoviendo a ADMINISTRADOR desde lista: $uid');
          await _firestore.collection('users').doc(uid).update({
            'isAdmin': true,
            'updatedAt': DateTime.now().toIso8601String(),
          });
          data['isAdmin'] = true;
          print('✅ Usuario promovido a ADMINISTRADOR');
        }

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
  }) async {
    print('🔍 ====== USER SERVICE: updateUserProfile ======');
    print('🆔 UID: $uid');
    print('📝 Nombre: "$name"');
    print('📧 Email: "$email"');

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
        // Verificar si el UID está en la lista de administradores o modo prueba
        final isAdmin = ADMIN_TEST_MODE || ADMIN_UIDS.contains(uid);

        print('🔐 Creando usuario: $uid');
        print('👤 Teléfono: $phoneNumber');
        print('🛡️ Es admin: $isAdmin');
        if (ADMIN_TEST_MODE) {
          print('⚠️ MODO DE PRUEBA ACTIVO - Usuario creado como admin');
        }

        UserModel newUser = UserModel(
          uid: uid,
          phoneNumber: phoneNumber,
          isAdmin:
              isAdmin, // Asignar rol de admin si está en la lista o modo prueba
        );
        await _firestore.collection('users').doc(uid).set(newUser.toMap());

        if (isAdmin) {
          print('✅ Usuario creado como ADMINISTRADOR');
        } else {
          print('✅ Usuario creado como usuario regular');
        }
      } else {
        // Si el usuario ya existe, verificar si necesita ser promovido a admin
        final isAdmin = ADMIN_TEST_MODE || ADMIN_UIDS.contains(uid);
        final userData = doc.data() as Map<String, dynamic>?;
        final currentIsAdmin = userData?['isAdmin'] ?? false;

        if (isAdmin && !currentIsAdmin) {
          print('🔄 Promoviendo usuario $uid a ADMINISTRADOR');
          if (ADMIN_TEST_MODE) {
            print('⚠️ MODO DE PRUEBA ACTIVO');
          }
          await _firestore.collection('users').doc(uid).update({
            'isAdmin': true,
            'updatedAt': DateTime.now().toIso8601String(),
          });
          print('✅ Usuario promovido a ADMINISTRADOR');
        }
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
}
