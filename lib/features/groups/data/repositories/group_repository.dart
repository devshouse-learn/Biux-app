import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:biux/features/groups/data/models/group_model.dart';

import 'package:biux/features/groups/domain/repositories/group_repository_interface.dart';

class GroupRepository implements GroupRepositoryInterface {
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
      AppLogger.info('✅ Grupo creado exitosamente: ${docRef.id}');
      AppLogger.debug('📋 Datos del grupo: ${group.toFirestore()}');

      return docRef.id;
    } catch (e) {
      AppLogger.error('❌ Error creando grupo: $e');
      return null;
    }
  }

  // NUEVO: Obtener grupos por ciudad
  // No filtramos isActive en query para incluir docs antiguos sin ese campo
  Stream<List<GroupModel>> getGroupsByCity(String cityId) {
    AppLogger.debug('🔍 Obteniendo grupos de la ciudad: $cityId');

    return _firestore
        .collection(_collection)
        .where('cityId', isEqualTo: cityId)
        .snapshots()
        .map((snapshot) {
          AppLogger.debug(
            '📊 Grupos encontrados en la ciudad: ${snapshot.docs.length}',
          );

          final groups = snapshot.docs
              .map((doc) {
                try {
                  return GroupModel.fromFirestore(doc);
                } catch (e) {
                  AppLogger.error('❌ Error parseando grupo ${doc.id}: $e');
                  return null;
                }
              })
              .where((group) => group != null)
              .cast<GroupModel>()
              .where((group) => group.isActive) // Filtrar en memoria
              .toList();

          // Ordenar por fecha en memoria
          groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          AppLogger.info('✅ Grupos procesados correctamente: ${groups.length}');
          return groups;
        });
  }

  // Obtener todos los grupos activos - MANTENER PARA COMPATIBILIDAD
  // NOTA: No filtramos por 'isActive' en la query de Firestore porque
  // documentos antiguos pueden no tener ese campo y serían excluidos.
  // En su lugar, filtramos en memoria tratando ausencia como true.
  Stream<List<GroupModel>> getGroups() {
    AppLogger.debug('🔍 Obteniendo todos los grupos...');

    return _firestore.collection(_collection).snapshots().map((snapshot) {
      AppLogger.debug('📊 Grupos encontrados: ${snapshot.docs.length}');

      final groups = snapshot.docs
          .map((doc) {
            try {
              return GroupModel.fromFirestore(doc);
            } catch (e) {
              AppLogger.error('❌ Error parseando grupo ${doc.id}: $e');
              return null;
            }
          })
          .where((group) => group != null)
          .cast<GroupModel>()
          .where((group) => group.isActive) // Filtrar en memoria
          .toList();

      // Ordenar por fecha en memoria
      groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      AppLogger.info('✅ Grupos procesados correctamente: ${groups.length}');
      return groups;
    });
  }

  // Obtener grupos donde el usuario es miembro
  // No filtramos isActive en query para incluir docs antiguos sin ese campo
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _firestore
        .collection(_collection)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final groups = snapshot.docs
              .map((doc) => GroupModel.fromFirestore(doc))
              .where((group) => group.isActive)
              .toList();
          groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return groups;
        });
  }

  // Obtener grupos administrados por el usuario
  // No filtramos isActive en query para incluir docs antiguos sin ese campo
  Stream<List<GroupModel>> getAdminGroups(String userId) {
    return _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final groups = snapshot.docs
              .map((doc) => GroupModel.fromFirestore(doc))
              .where((group) => group.isActive)
              .toList();
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
      AppLogger.debug('Error obteniendo grupo: $e');
      return null;
    }
  }

  // Solicitar unirse a un grupo
  Future<bool> requestJoinGroup(String groupId, String userId) async {
    try {
      // Actualizar grupo con solicitud pendiente
      await _firestore.collection(_collection).doc(groupId).update({
        'pendingRequestIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Obtener datos del grupo y usuario para crear notificación
      try {
        final groupDoc = await _firestore
            .collection(_collection)
            .doc(groupId)
            .get();
        final groupData = groupDoc.data();

        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data();

        if (groupData != null && userData != null) {
          final adminId = groupData['adminId'] as String?;

          if (adminId != null && adminId.isNotEmpty) {
            // Crear notificación para el admin del grupo
            await _firestore
                .collection('users')
                .doc(adminId)
                .collection('notifications')
                .add({
                  'type': 'group_join_request',
                  'fromUserId': userId,
                  'fromUserName':
                      userData['fullName'] ?? userData['userName'] ?? 'Usuario',
                  'fromUserPhoto': userData['photo'],
                  'targetType': 'group',
                  'targetId': groupId,
                  'targetPreview': groupData['name'] ?? 'Grupo',
                  'message':
                      'solicita unirse a tu grupo ${groupData['name'] ?? ""}',
                  'isRead': false,
                  'createdAt': FieldValue.serverTimestamp(),
                  'metadata': {
                    'groupName': groupData['name'],
                    'groupLogo': groupData['logo'],
                  },
                });
          }
        }
      } catch (notifError) {
        AppLogger.debug(
          'Error creando notificación de solicitud de ingreso: $notifError',
        );
        // No fallar la operación si la notificación falla
      }

      return true;
    } catch (e) {
      AppLogger.debug('Error solicitando unirse al grupo: $e');
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
      AppLogger.debug('Error aprobando solicitud: $e');
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
      AppLogger.debug('Error rechazando solicitud: $e');
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
      AppLogger.debug('Error cancelando solicitud: $e');
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
      AppLogger.debug('Error saliendo del grupo: $e');
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
      AppLogger.debug('Error actualizando grupo: $e');
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
      AppLogger.debug('Error eliminando grupo: $e');
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
      AppLogger.debug('Error subiendo imagen: $e');
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
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      return snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
    } catch (e) {
      AppLogger.debug('Error buscando grupos: $e');
      return [];
    }
  }
}
