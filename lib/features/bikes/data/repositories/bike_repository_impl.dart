import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/features/bikes/domain/entities/bike_theft_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_transfer_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_sighting_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_verification_entity.dart';
import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';
import 'package:biux/features/bikes/data/models/bike_model.dart';
import 'package:biux/features/bikes/data/models/bike_theft_model.dart';
import 'package:biux/features/bikes/data/models/bike_transfer_model.dart';
import "package:flutter/foundation.dart";
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/exceptions/backend_exceptions.dart';

/// Implementación del repositorio de bicicletas con Firebase Firestore
class BikeRepositoryImpl implements BikeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _bikesCollection = 'bikes';
  static const String _theftsCollection = 'bike_thefts';
  static const String _transfersCollection = 'bike_transfers';
  static const String _sightingsCollection = 'bike_sightings';
  static const String _verificationsCollection = 'bike_verifications';

  /// ALTO: Mejor error handling con logging
  @override
  Future<BikeEntity> registerBike(BikeEntity bike) async {
    try {
      final bikeModel = BikeModel.fromEntity(bike);
      final docRef = _firestore.collection(_bikesCollection).doc();

      final bikeWithId = bikeModel.copyWith(id: docRef.id);
      await docRef.set(bikeWithId.toJson());

      AppLogger.info(
        'Bicicleta registrada: ${bikeWithId.id}',
        tag: 'BikeRepository',
      );
      return bikeWithId.toEntity();
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error registrando bicicleta: $e',
        tag: 'BikeRepository',
        error: e,
      );
      throw RepositoryException(
        'BikeRepository',
        'registerBike',
        'No se pudo registrar la bicicleta: ${e.code}',
      );
    }
  }

  @override
  Future<List<BikeEntity>> getUserBikes(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_bikesCollection)
          .where('ownerId', isEqualTo: userId)
          .orderBy('registrationDate', descending: true)
          .get();

      AppLogger.debug(
        'Repository: Query devolvió ${querySnapshot.docs.length} documentos',
        tag: 'BikeRepositoryImpl',
      );

      // TEMPORAL: Verificar si hay bicis con ownerId "current-user-id"
      final allBikesSnapshot = await _firestore
          .collection(_bikesCollection)
          .limit(20)
          .get();

      AppLogger.debug(
        'Total de bicis en Firestore: ${allBikesSnapshot.docs.length}',
        tag: 'BikeRepositoryImpl',
      );

      int placeholderCount = 0;
      for (var doc in allBikesSnapshot.docs) {
        final data = doc.data();
        if (data['ownerId'] == 'current-user-id') {
          placeholderCount++;
          AppLogger.warning(
            'Encontrada bici con placeholder - ID: ${doc.id}, Marca: ${data['brand']} ${data['model']}',
            tag: 'BikeRepositoryImpl',
          );
        }
      }

      if (placeholderCount > 0) {
        AppLogger.warning(
          'TOTAL de bicis con placeholder "current-user-id": $placeholderCount',
          tag: 'BikeRepositoryImpl',
        );
        AppLogger.warning(
          'Estas bicis necesitan actualizar su ownerId a: "$userId"',
          tag: 'BikeRepositoryImpl',
        );
      }

      return querySnapshot.docs
          .map((doc) => BikeModel.fromJson(doc.data()).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Repository: Error obteniendo bicicletas',
        error: e,
        tag: 'BikeRepositoryImpl',
      );
      throw RepositoryException(
        'BikeRepository',
        'getUserBikes',
        'No se pudo obtener las bicicletas: ${e.code}',
      );
    }
  }

  @override
  Future<BikeEntity?> getBikeById(String bikeId) async {
    try {
      final doc = await _firestore
          .collection(_bikesCollection)
          .doc(bikeId)
          .get();

      if (!doc.exists) return null;

      return BikeModel.fromJson(doc.data()!).toEntity();
    } on FirebaseException catch (e) {
      throw ResourceNotFoundException('Bicicleta');
    }
  }

  @override
  Future<BikeEntity?> getBikeByQR(String qrCode) async {
    try {
      final querySnapshot = await _firestore
          .collection(_bikesCollection)
          .where('qrCode', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return BikeModel.fromJson(querySnapshot.docs.first.data()).toEntity();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'BikeRepository',
        'getBikeByQR',
        'No se pudo buscar bicicleta por QR: ${e.code}',
      );
    }
  }

  @override
  Future<BikeEntity> updateBike(BikeEntity bike) async {
    try {
      final bikeModel = BikeModel.fromEntity(bike);
      await _firestore
          .collection(_bikesCollection)
          .doc(bike.id)
          .update(bikeModel.toJson());

      return bike;
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'BikeRepository',
        'updateBike',
        'No se pudo actualizar la bicicleta: ${e.code}',
      );
    }
  }

  @override
  Future<void> deleteBike(String bikeId) async {
    try {
      await _firestore.collection(_bikesCollection).doc(bikeId).delete();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'BikeRepository',
        'deleteBike',
        'No se pudo eliminar la bicicleta: ${e.code}',
      );
    }
  }

  @override
  Future<String> generateUniqueQR() async {
    // Generar código QR Ãºnico basado en timestamp y random
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'BIUX-$timestamp-$random';
  }

  @override
  Future<BikeTheftEntity> reportTheft(BikeTheftEntity theft) async {
    try {
      final docRef = _firestore.collection(_theftsCollection).doc();

      // Crear modelo con ID
      final theftData = BikeTheftModel.fromEntity(theft).toJson();
      theftData['id'] = docRef.id;

      await docRef.set(theftData);

      // Actualizar estado de la bicicleta
      await _firestore.collection(_bikesCollection).doc(theft.bikeId).update({
        'status': 'stolen',
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      return BikeTheftModel.fromJson(theftData).toEntity();
    } on FirebaseException catch (e) {
      throw Exception('Error al reportar robo: $e');
    }
  }

  @override
  Future<BikeEntity> markAsRecovered(String bikeId, String userId) async {
    try {
      await _firestore.collection(_bikesCollection).doc(bikeId).update({
        'status': 'active',
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      final bike = await getBikeById(bikeId);
      if (bike == null) throw Exception('Bicicleta no encontrada');

      return bike;
    } on FirebaseException catch (e) {
      throw Exception('Error al marcar como recuperada: $e');
    }
  }

  @override
  Future<List<BikeTheftEntity>> getTheftReports(String bikeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_theftsCollection)
          .where('bikeId', isEqualTo: bikeId)
          .orderBy('reportDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BikeTheftModel.fromJson(doc.data()).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener reportes de robo: $e');
    }
  }

  @override
  Future<List<BikeEntity>> getStolenBikes(String city) async {
    try {
      final querySnapshot = await _firestore
          .collection(_bikesCollection)
          .where('city', isEqualTo: city)
          .where('status', isEqualTo: 'stolen')
          .get();

      return querySnapshot.docs
          .map((doc) => BikeModel.fromJson(doc.data()).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener bicicletas robadas: $e');
    }
  }

  @override
  Future<BikeTransferEntity> requestTransfer(
    BikeTransferEntity transfer,
  ) async {
    try {
      final docRef = _firestore.collection(_transfersCollection).doc();

      // Crear modelo con ID
      final transferData = BikeTransferModel.fromEntity(transfer).toJson();
      transferData['id'] = docRef.id;

      await docRef.set(transferData);

      return BikeTransferModel.fromJson(transferData).toEntity();
    } on FirebaseException catch (e) {
      throw Exception('Error al solicitar transferencia: $e');
    }
  }

  @override
  Future<BikeTransferEntity> acceptTransfer(
    String transferId,
    String userId,
  ) async {
    try {
      await _firestore.collection(_transfersCollection).doc(transferId).update({
        'status': 'accepted',
        'completedDate': DateTime.now().toIso8601String(),
      });

      // Obtener la transferencia
      final doc = await _firestore
          .collection(_transfersCollection)
          .doc(transferId)
          .get();
      final transfer = BikeTransferModel.fromJson(doc.data()!);

      // Actualizar el dueño de la bicicleta
      await _firestore
          .collection(_bikesCollection)
          .doc(transfer.bikeId)
          .update({
            'ownerId': transfer.toUserId,
            'lastUpdated': DateTime.now().toIso8601String(),
          });

      return transfer.toEntity();
    } on FirebaseException catch (e) {
      throw Exception('Error al aceptar transferencia: $e');
    }
  }

  @override
  Future<BikeTransferEntity> rejectTransfer(
    String transferId,
    String userId,
    String reason,
  ) async {
    try {
      await _firestore.collection(_transfersCollection).doc(transferId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'completedDate': DateTime.now().toIso8601String(),
      });

      final doc = await _firestore
          .collection(_transfersCollection)
          .doc(transferId)
          .get();
      return BikeTransferModel.fromJson(doc.data()!).toEntity();
    } on FirebaseException catch (e) {
      throw Exception('Error al rechazar transferencia: $e');
    }
  }

  @override
  Future<BikeTransferEntity> cancelTransfer(
    String transferId,
    String userId,
  ) async {
    try {
      await _firestore.collection(_transfersCollection).doc(transferId).update({
        'status': 'cancelled',
        'completedDate': DateTime.now().toIso8601String(),
      });

      final doc = await _firestore
          .collection(_transfersCollection)
          .doc(transferId)
          .get();
      return BikeTransferModel.fromJson(doc.data()!).toEntity();
    } on FirebaseException catch (e) {
      throw Exception('Error al cancelar transferencia: $e');
    }
  }

  @override
  Future<List<BikeTransferEntity>> getPendingTransfers(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_transfersCollection)
          .where('newOwnerId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('requestDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BikeTransferModel.fromJson(doc.data()).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener transferencias pendientes: $e');
    }
  }

  @override
  Future<List<BikeTransferEntity>> getBikeTransferHistory(String bikeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_transfersCollection)
          .where('bikeId', isEqualTo: bikeId)
          .orderBy('requestDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BikeTransferModel.fromJson(doc.data()).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener historial de transferencias: $e');
    }
  }

  @override
  Future<BikeVerificationEntity> verifyBike(
    BikeVerificationEntity verification,
  ) async {
    try {
      final docRef = _firestore.collection(_verificationsCollection).doc();

      await docRef.set({
        'id': docRef.id,
        'bikeId': verification.bikeId,
        'storeId': verification.storeId,
        'storeName': verification.storeName,
        'verifierId': verification.verifierId,
        'verifierName': verification.verifierName,
        'verificationDate': DateTime.now().toIso8601String(),
        'notes': verification.notes,
        'verificationPhotos': verification.verificationPhotos,
        'isActive': verification.isActive,
      });

      return verification;
    } on FirebaseException catch (e) {
      throw Exception('Error al verificar bicicleta: $e');
    }
  }

  @override
  Future<List<BikeVerificationEntity>> getBikeVerifications(
    String bikeId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_verificationsCollection)
          .where('bikeId', isEqualTo: bikeId)
          .orderBy('verificationDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return BikeVerificationEntity(
          id: data['id'],
          bikeId: data['bikeId'],
          storeId: data['storeId'],
          storeName: data['storeName'],
          verifierId: data['verifierId'],
          verifierName: data['verifierName'],
          verificationDate: DateTime.parse(data['verificationDate']),
          notes: data['notes'],
          verificationPhotos: data['verificationPhotos'] != null
              ? List<String>.from(data['verificationPhotos'])
              : null,
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener verificaciones: $e');
    }
  }

  @override
  Future<BikeSightingEntity> reportSighting(BikeSightingEntity sighting) async {
    try {
      final docRef = _firestore.collection(_sightingsCollection).doc();

      await docRef.set({
        'id': docRef.id,
        'bikeId': sighting.bikeId,
        'reporterId': sighting.reporterId,
        'location': sighting.location,
        'description': sighting.description,
        'latitude': sighting.latitude,
        'longitude': sighting.longitude,
        'photos': sighting.photos,
        'ownerNotified': sighting.ownerNotified,
        'sightingDate': DateTime.now().toIso8601String(),
      });

      return sighting;
    } on FirebaseException catch (e) {
      throw Exception('Error al reportar avistamiento: $e');
    }
  }

  @override
  Future<List<BikeSightingEntity>> getBikeSightings(String bikeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_sightingsCollection)
          .where('bikeId', isEqualTo: bikeId)
          .orderBy('sightingDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return BikeSightingEntity(
          id: data['id'],
          bikeId: data['bikeId'],
          reporterId: data['reporterId'],
          location: data['location'],
          description: data['description'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          photos: data['photos'] != null
              ? List<String>.from(data['photos'])
              : null,
          ownerNotified: data['ownerNotified'] ?? false,
          sightingDate: DateTime.parse(data['sightingDate']),
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener avistamientos: $e');
    }
  }

  @override
  Future<BikeSightingEntity> markSightingAsNotified(String sightingId) async {
    try {
      await _firestore.collection(_sightingsCollection).doc(sightingId).update({
        'notified': true,
        'notifiedDate': DateTime.now().toIso8601String(),
      });

      final doc = await _firestore
          .collection(_sightingsCollection)
          .doc(sightingId)
          .get();
      final data = doc.data()!;

      return BikeSightingEntity(
        id: data['id'],
        bikeId: data['bikeId'],
        reporterId: data['reporterId'],
        location: data['location'],
        description: data['description'],
        sightingDate: DateTime.parse(data['sightingDate']),
      );
    } on FirebaseException catch (e) {
      throw Exception('Error al marcar avistamiento como notificado: $e');
    }
  }

  @override
  Future<List<BikeEntity>> getStoreVerifiedBikes(String storeId) async {
    try {
      // Obtener verificaciones de la tienda
      final verificationsSnapshot = await _firestore
          .collection(_verificationsCollection)
          .where('verifierId', isEqualTo: storeId)
          .get();

      // Obtener IDs Ãºnicos de bicicletas verificadas
      final bikeIds = verificationsSnapshot.docs
          .map((doc) => doc.data()['bikeId'] as String)
          .toSet()
          .toList();

      if (bikeIds.isEmpty) return [];

      // Obtener las bicicletas
      final bikes = <BikeEntity>[];
      for (final bikeId in bikeIds) {
        final bike = await getBikeById(bikeId);
        if (bike != null) bikes.add(bike);
      }

      return bikes;
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener bicicletas verificadas: $e');
    }
  }

  @override
  Future<Map<String, int>> getUserBikeStats(String userId) async {
    try {
      final bikes = await getUserBikes(userId);

      final stats = {
        'total': bikes.length,
        'active': 0,
        'stolen': 0,
        'verified': 0,
      };

      for (final bike in bikes) {
        if (bike.status == BikeStatus.active) {
          stats['active'] = (stats['active'] ?? 0) + 1;
        } else if (bike.status == BikeStatus.stolen) {
          stats['stolen'] = (stats['stolen'] ?? 0) + 1;
        }

        if (bike.verifiedBy != null && bike.verifiedBy!.isNotEmpty) {
          stats['verified'] = (stats['verified'] ?? 0) + 1;
        }
      }

      return stats;
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener estadísticas de usuario: $e');
    }
  }

  @override
  Future<List<BikeEntity>> searchBikes({
    String? brand,
    String? model,
    String? color,
    String? city,
    String? frameSerial,
  }) async {
    try {
      Query query = _firestore.collection(_bikesCollection);

      // Aplicar filtros
      if (brand != null && brand.isNotEmpty) {
        query = query.where('brand', isEqualTo: brand);
      }
      if (model != null && model.isNotEmpty) {
        query = query.where('model', isEqualTo: model);
      }
      if (color != null && color.isNotEmpty) {
        query = query.where('color', isEqualTo: color);
      }
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      if (frameSerial != null && frameSerial.isNotEmpty) {
        query = query.where('frameSerial', isEqualTo: frameSerial);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map(
            (doc) => BikeModel.fromJson(
              doc.data() as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al buscar bicicletas: $e');
    }
  }
}
