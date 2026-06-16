import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

enum DangerType { accident, theft, poorRoad, badLighting, traffic, other }

class DangerZoneEntity {
  final String id;
  final String reportedBy;
  final String reportedByName;
  final DangerType type;
  final String description;
  final double lat;
  final double lng;
  final int reportCount;
  final DateTime createdAt;
  final bool active;

  const DangerZoneEntity({
    required this.id,
    required this.reportedBy,
    required this.reportedByName,
    required this.type,
    required this.description,
    required this.lat,
    required this.lng,
    required this.reportCount,
    required this.createdAt,
    this.active = true,
  });

  factory DangerZoneEntity.fromMap(String id, Map<String, dynamic> map) =>
      DangerZoneEntity(
        id: id,
        reportedBy: map['reportedBy'] ?? '',
        reportedByName: map['reportedByName'] ?? '',
        type: DangerType.values.firstWhere(
          (t) => t.name == (map['type'] ?? 'other'),
          orElse: () => DangerType.other,
        ),
        description: map['description'] ?? '',
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        reportCount: map['reportCount'] ?? 1,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        active: map['active'] ?? true,
      );

  Map<String, dynamic> toMap() => {
    'reportedBy': reportedBy,
    'reportedByName': reportedByName,
    'type': type.name,
    'description': description,
    'lat': lat,
    'lng': lng,
    'reportCount': reportCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'active': active,
  };

  String get typeLabel {
    switch (type) {
      case DangerType.accident:
        return '🚨 Zona de accidentes';
      case DangerType.theft:
        return '🔒 Zona de robos';
      case DangerType.poorRoad:
        return '🕳️ Camino en mal estado';
      case DangerType.badLighting:
        return '💡 Mala iluminación';
      case DangerType.traffic:
        return '🚗 Tráfico peligroso';
      case DangerType.other:
        return '⚠️ Zona peligrosa';
    }
  }
}

class DangerZonesDatasource {
  static final _db = FirebaseFirestore.instance;

  /// ALTO: Validar coordenadas GPS (lat ±90, lng ±180)
  static void _validateCoordinates(double lat, double lng) {
    if (lat < -90 || lat > 90) {
      throw ValidationException('lat', 'Latitud debe estar entre -90 y 90');
    }
    if (lng < -180 || lng > 180) {
      throw ValidationException('lng', 'Longitud debe estar entre -180 y 180');
    }
  }

  static Stream<List<DangerZoneEntity>> zonesStream() {
    return _db
        .collection('danger_zones')
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => DangerZoneEntity.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// ALTO: Validar entrada, coordenadas, autorización y agregar logging
  static Future<void> reportZone({
    required DangerType type,
    required String description,
    required double lat,
    required double lng,
  }) async {
    try {
      // ALTO: Validar descripción
      if (description.isEmpty || description.length > 500) {
        throw ValidationException(
          'description',
          'Descripción debe tener entre 1 y 500 caracteres',
        );
      }

      // ALTO: Validar coordenadas GPS
      _validateCoordinates(lat, lng);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw NotAuthenticatedException();
      }

      final userDoc = await _db.collection('users').doc(user.uid).get();
      final name = userDoc.data()?['name'] ?? 'Ciclista';

      // ALTO: Verificar si ya existe una zona cercana con límite de búsqueda
      final existing = await _db
          .collection('danger_zones')
          .where('active', isEqualTo: true)
          .limit(100)
          .get();

      for (final doc in existing.docs) {
        final data = doc.data();
        final dLat = ((data['lat'] as num).toDouble() - lat).abs();
        final dLng = ((data['lng'] as num).toDouble() - lng).abs();
        if (dLat < 0.0005 && dLng < 0.0005 && data['type'] == type.name) {
          await doc.reference.update({'reportCount': FieldValue.increment(1)});
          AppLogger.info(
            'Zona peligrosa confirmada: ${data['type']}',
            tag: 'DangerZonesDatasource',
          );
          return;
        }
      }

      await _db.collection('danger_zones').add({
        'reportedBy': user.uid,
        'reportedByName': name,
        'type': type.name,
        'description': description,
        'lat': lat,
        'lng': lng,
        'reportCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'active': true,
      });

      AppLogger.info(
        'Nueva zona peligrosa reportada: ${type.name}',
        tag: 'DangerZonesDatasource',
      );
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'DangerZonesDatasource',
      );
      rethrow;
    } on NotAuthenticatedException catch (e) {
      AppLogger.warning(
        'Usuario no autenticado: ${e.message}',
        tag: 'DangerZonesDatasource',
      );
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error reportando zona peligrosa: $e',
        tag: 'DangerZonesDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  static Future<void> confirmZone(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('id', 'Zone ID no puede estar vacío');
      }

      await _db.collection('danger_zones').doc(id).update({
        'reportCount': FieldValue.increment(1),
      });

      AppLogger.info(
        'Zona peligrosa confirmada: $id',
        tag: 'DangerZonesDatasource',
      );
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'DangerZonesDatasource',
      );
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error confirmando zona: $e',
        tag: 'DangerZonesDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  static Future<void> resolveZone(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('id', 'Zone ID no puede estar vacío');
      }

      await _db.collection('danger_zones').doc(id).update({'active': false});

      AppLogger.info(
        'Zona peligrosa resuelta: $id',
        tag: 'DangerZonesDatasource',
      );
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'DangerZonesDatasource',
      );
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error resolviendo zona: $e',
        tag: 'DangerZonesDatasource',
        error: e,
      );
      rethrow;
    }
  }
}
