import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/group_model.dart';

class GroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'groups';

  // Crear un nuevo grupo
  Future<String?> createGroup({
    required String name,
    required String description,
    required String adminId,
    required String cityId, // NUEVO PARÁMETRO REQUERIDO
    XFile? logoFile,
    XFile? coverFile,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();

      String? logoUrl;
      String? coverUrl;

      // Subir logo si se proporciona
      if (logoFile != null) {
        logoUrl = await _uploadImage(logoFile, 'groups/${docRef.id}/logo');
      }

      // Subir portada si se proporciona
      if (coverFile != null) {
        coverUrl = await _uploadImage(coverFile, 'groups/${docRef.id}/cover');
      }

      final group = GroupModel(
        id: docRef.id,
        name: name,
        description: description,
        logoUrl: logoUrl,
        coverUrl: coverUrl,
        adminId: adminId,
        cityId: cityId, // NUEVO CAMPO
        memberIds: [adminId], // El admin se agrega automáticamente como miembro
        pendingRequestIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true, // Asegurar que se establece como activo
      );

      await docRef.set(group.toFirestore());

      // Log para debug
      print('✅ Grupo creado exitosamente: ${docRef.id}');
      print('📋 Datos del grupo: ${group.toFirestore()}');

      return docRef.id;
    } catch (e) {
      print('❌ Error creando grupo: $e');
      return null;
    }
  }

  // NUEVO: Obtener grupos por ciudad
  Stream<List<GroupModel>> getGroupsByCity(String cityId) {
    print('🔍 Obteniendo grupos de la ciudad: $cityId');

    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('cityId', isEqualTo: cityId)
        .snapshots()
        .map((snapshot) {
      print('📊 Grupos encontrados en la ciudad: ${snapshot.docs.length}');

      final groups = snapshot.docs
          .map((doc) {
            try {
              return GroupModel.fromFirestore(doc);
            } catch (e) {
              print('❌ Error parseando grupo ${doc.id}: $e');
              return null;
            }
          })
          .where((group) => group != null)
          .cast<GroupModel>()
          .toList();

      // Ordenar por fecha en memoria
      groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('✅ Grupos procesados correctamente: ${groups.length}');
      return groups;
    });
  }

  // Obtener todos los grupos activos - MANTENER PARA COMPATIBILIDAD
  Stream<List<GroupModel>> getGroups() {
    print('🔍 Obteniendo todos los grupos...');

    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      print('📊 Grupos encontrados: ${snapshot.docs.length}');

      final groups = snapshot.docs
          .map((doc) {
            try {
              return GroupModel.fromFirestore(doc);
            } catch (e) {
              print('❌ Error parseando grupo ${doc.id}: $e');
              return null;
            }
          })
          .where((group) => group != null)
          .cast<GroupModel>()
          .toList();

      // Ordenar por fecha en memoria
      groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('✅ Grupos procesados correctamente: ${groups.length}');
      return groups;
    });
  }

  // Obtener grupos donde el usuario es miembro
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _firestore
        .collection(_collection)
        .where('memberIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final groups =
          snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
      groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return groups;
    });
  }

  // Obtener grupos administrados por el usuario
  Stream<List<GroupModel>> getAdminGroups(String userId) {
    return _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final groups =
          snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
      groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return groups;
    });
  }

  // Obtener un grupo específico
  Future<GroupModel?> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(groupId).get();
      if (doc.exists) {
        return GroupModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo grupo: $e');
      return null;
    }
  }

  // Solicitar unirse a un grupo
  Future<bool> requestJoinGroup(String groupId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'pendingRequestIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error solicitando unirse al grupo: $e');
      return false;
    }
  }

  // Aprobar solicitud de ingreso
  Future<bool> approveJoinRequest(String groupId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'pendingRequestIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error aprobando solicitud: $e');
      return false;
    }
  }

  // Rechazar solicitud de ingreso
  Future<bool> rejectJoinRequest(String groupId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'pendingRequestIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error rechazando solicitud: $e');
      return false;
    }
  }

  // Cancelar solicitud de ingreso
  Future<bool> cancelJoinRequest(String groupId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'pendingRequestIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error cancelando solicitud: $e');
      return false;
    }
  }

  // Salir de un grupo
  Future<bool> leaveGroup(String groupId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error saliendo del grupo: $e');
      return false;
    }
  }

  // Actualizar grupo (solo admin)
  Future<bool> updateGroup({
    required String groupId,
    String? name,
    String? description,
    XFile? logoFile,
    XFile? coverFile,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;

      // Actualizar logo si se proporciona
      if (logoFile != null) {
        final logoUrl = await _uploadImage(logoFile, 'groups/$groupId/logo');
        updates['logoUrl'] = logoUrl;
      }

      // Actualizar portada si se proporciona
      if (coverFile != null) {
        final coverUrl = await _uploadImage(coverFile, 'groups/$groupId/cover');
        updates['coverUrl'] = coverUrl;
      }

      await _firestore.collection(_collection).doc(groupId).update(updates);
      return true;
    } catch (e) {
      print('Error actualizando grupo: $e');
      return false;
    }
  }

  // Eliminar grupo (solo admin)
  Future<bool> deleteGroup(String groupId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error eliminando grupo: $e');
      return false;
    }
  }

  // Subir imagen a Firebase Storage
  Future<String?> _uploadImage(XFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(File(file.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error subiendo imagen: $e');
      return null;
    }
  }

  // Buscar grupos por nombre
  Future<List<GroupModel>> searchGroups(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .startAt([query]).endAt([query + '\uf8ff']).get();

      return snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error buscando grupos: $e');
      return [];
    }
  }
}
