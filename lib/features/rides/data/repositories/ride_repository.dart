import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:biux/features/rides/data/models/ride_model.dart';
import "package:flutter/foundation.dart";
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/authorization_service.dart';
import 'package:biux/core/services/app_logger.dart';

class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear una nueva rodada
  Future<String?> createRide(RideModel ride) async {
    try {
      final docRef = await _firestore
          .collection('rides')
          .add(ride.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('Error creating ride: $e');
      return null;
    }
  }

  // Obtener rodadas de un grupo específico
  Stream<List<RideModel>> getGroupRides(String groupId) {
    return _firestore
        .collection('rides')
        .where('groupId', isEqualTo: groupId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// RENDIMIENTO: getAllRides() sin límite → Cargar TODAS las rodadas
  /// SOLUCIÓN: Agregar paginación y límite
  Stream<List<RideModel>> getAllRides({int limit = 50}) {
    AppLogger.info(
      'Obtener todas las rodadas (limit: $limit)',
      tag: 'RideRepository',
    );

    return _firestore
        .collection('rides')
        .orderBy('dateTime', descending: false)
        .limit(limit) // IMPORTANTE: Agregar límite
        .snapshots()
        .map((snapshot) {
          AppLogger.debug(
            'Se obtuvieron ${snapshot.docs.length} rodadas',
            tag: 'RideRepository',
          );
          return snapshot.docs
              .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  /// Obtener próximas rodadas con paginación
  Future<List<RideModel>> getUpcomingRidesPaginated({
    int limit = 50,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      var query = _firestore
          .collection('rides')
          .where('dateTime', isGreaterThan: DateTime.now())
          .orderBy('dateTime', descending: false)
          .limit(limit);

      // Implementar cursor-based pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error obteniendo rodadas paginadas: $e',
        tag: 'RideRepository',
        error: e,
      );
      return [];
    }
  }

  // Obtener una rodada específica
  Future<RideModel?> getRideById(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists && doc.data() != null) {
        return RideModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Error getting ride: $e');
      return null;
    }
  }

  /// ALTO: Validar entrada y mejor error handling
  Future<bool> joinRide(String rideId, String userId) async {
    try {
      if (rideId.isEmpty || userId.isEmpty) {
        throw ValidationException('input', 'Ride ID y User ID son requeridos');
      }

      await _firestore.collection('rides').doc(rideId).update({
        'participants': FieldValue.arrayUnion([userId]),
        'maybeParticipants': FieldValue.arrayRemove([userId]),
      });
      AppLogger.info(
        'Usuario se unió a rodada: $rideId',
        tag: 'RideRepository',
      );
      return true;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'RideRepository',
      );
      return false;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error uniéndose a rodada: $e',
        tag: 'RideRepository',
        error: e,
      );
      return false;
    }
  }

  /// ALTO: Validar entrada y mejor error handling
  Future<bool> maybeJoinRide(String rideId, String userId) async {
    try {
      if (rideId.isEmpty || userId.isEmpty) {
        throw ValidationException('input', 'Ride ID y User ID son requeridos');
      }

      await _firestore.collection('rides').doc(rideId).update({
        'maybeParticipants': FieldValue.arrayUnion([userId]),
        'participants': FieldValue.arrayRemove([userId]),
      });
      AppLogger.info(
        'Usuario marcado como "tal vez" en rodada: $rideId',
        tag: 'RideRepository',
      );
      return true;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'RideRepository',
      );
      return false;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error marcando "tal vez": $e',
        tag: 'RideRepository',
        error: e,
      );
      return false;
    }
  }

  /// ALTO: Validar entrada y mejor error handling
  Future<bool> leaveRide(String rideId, String userId) async {
    try {
      if (rideId.isEmpty || userId.isEmpty) {
        throw ValidationException('input', 'Ride ID y User ID son requeridos');
      }

      await _firestore.collection('rides').doc(rideId).update({
        'participants': FieldValue.arrayRemove([userId]),
        'maybeParticipants': FieldValue.arrayRemove([userId]),
      });
      AppLogger.info('Usuario salió de rodada: $rideId', tag: 'RideRepository');
      return true;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'RideRepository',
      );
      return false;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error saliendo de rodada: $e',
        tag: 'RideRepository',
        error: e,
      );
      return false;
    }
  }

  /// ALTO: Validar entrada y mejor error handling
  Future<bool> updateRide(String rideId, Map<String, dynamic> updates) async {
    try {
      if (rideId.isEmpty || updates.isEmpty) {
        throw ValidationException(
          'input',
          'Ride ID y updates no pueden estar vacíos',
        );
      }

      await _firestore.collection('rides').doc(rideId).update(updates);
      AppLogger.info('Rodada actualizada: $rideId', tag: 'RideRepository');
      return true;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'RideRepository',
      );
      return false;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error actualizando rodada: $e',
        tag: 'RideRepository',
        error: e,
      );
      return false;
    }
  }

  /// ALTO: Validar entrada y mejor error handling
  Future<bool> cancelRide(String rideId) async {
    try {
      if (rideId.isEmpty) {
        throw ValidationException('rideId', 'Ride ID no puede estar vacío');
      }

      await _firestore.collection('rides').doc(rideId).update({
        'status': RideStatus.cancelled.name,
      });
      AppLogger.info('Rodada cancelada: $rideId', tag: 'RideRepository');
      return true;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'RideRepository',
      );
      return false;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error cancelando rodada: $e',
        tag: 'RideRepository',
        error: e,
      );
      return false;
    }
  }

  // Eliminar una rodada
  Future<bool> deleteRide(String rideId) async {
    try {
      final authService = AuthorizationService();
      final currentUserId = authService.getCurrentUserId();

      // CRÍTICO #2: Verificar que el usuario sea el creador de la rodada
      final rideDoc = await _firestore.collection('rides').doc(rideId).get();

      if (!rideDoc.exists) {
        throw ResourceNotFoundException('Rodada');
      }

      final rideData = rideDoc.data();
      final rideCreatorId = rideData?['createdBy'] ?? rideData?['userId'];

      if (rideCreatorId != currentUserId) {
        AppLogger.warning(
          'Intento de eliminar rodada ajena - Usuario: $currentUserId, Propietario: $rideCreatorId',
        );
        throw UnauthorizedException('eliminar esta rodada');
      }

      await _firestore.collection('rides').doc(rideId).delete();
      AppLogger.info('Rodada eliminada exitosamente', tag: 'deleteRide');
      return true;
    } on UnauthorizedException catch (e) {
      AppLogger.warning('Operación no autorizada: ${e.message}');
      return false;
    } on NotAuthenticatedException catch (e) {
      AppLogger.warning('Usuario no autenticado: ${e.message}');
      return false;
    } on FirebaseException catch (e) {
      AppLogger.error('Error de Firebase eliminando rodada: ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Error inesperado eliminando rodada: $e');
      return false;
    }
  }

  // Obtener rodadas donde el usuario participa
  Stream<List<RideModel>> getUserRides(String userId) {
    return _firestore
        .collection('rides')
        .where('participants', arrayContains: userId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Obtener próximas rodadas (todas)
  Stream<List<RideModel>> getUpcomingRides() {
    final now = DateTime.now();
    return _firestore
        .collection('rides')
        .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
        .where('status', isEqualTo: RideStatus.upcoming.name)
        .orderBy('dateTime', descending: false)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
