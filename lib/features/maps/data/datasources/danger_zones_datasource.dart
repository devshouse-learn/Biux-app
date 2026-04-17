import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static Future<void> reportZone({
    required DangerType type,
    required String description,
    required double lat,
    required double lng,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final name = userDoc.data()?['name'] ?? 'Ciclista';

    // Verificar si ya existe una zona cercana (50m)
    final existing = await _db
        .collection('danger_zones')
        .where('active', isEqualTo: true)
        .get();

    for (final doc in existing.docs) {
      final data = doc.data();
      final dLat = ((data['lat'] as num).toDouble() - lat).abs();
      final dLng = ((data['lng'] as num).toDouble() - lng).abs();
      if (dLat < 0.0005 && dLng < 0.0005 && data['type'] == type.name) {
        // Zona cercana existente → incrementar contador
        await doc.reference.update({'reportCount': FieldValue.increment(1)});
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
  }

  static Future<void> confirmZone(String id) async {
    await _db.collection('danger_zones').doc(id).update({
      'reportCount': FieldValue.increment(1),
    });
  }

  static Future<void> resolveZone(String id) async {
    await _db.collection('danger_zones').doc(id).update({'active': false});
  }
}
