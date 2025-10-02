import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Obtener usuario por ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  // Crear o actualizar usuario
  Future<bool> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.uid).set(user.toMap());
      return true;
    } catch (e) {
      print('Error guardando usuario: $e');
      return false;
    }
  }

  // Actualizar usuario
  Future<bool> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(uid).update(updates);
      return true;
    } catch (e) {
      print('Error actualizando usuario: $e');
      return false;
    }
  }

  // Verificar si el usuario existe
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error verificando usuario: $e');
      return false;
    }
  }

  // Obtener múltiples usuarios por IDs
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    try {
      List<UserModel> users = [];

      // Firestore permite máximo 30 elementos en whereIn
      List<List<String>> chunks = [];
      for (int i = 0; i < uids.length; i += 30) {
        chunks
            .add(uids.sublist(i, i + 30 > uids.length ? uids.length : i + 30));
      }

      for (List<String> chunk in chunks) {
        final snapshot = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        users.addAll(snapshot.docs.map((doc) => UserModel.fromMap(doc.data())));
      }

      return users;
    } catch (e) {
      print('Error obteniendo usuarios múltiples: $e');
      return [];
    }
  }
}
