/// Entidad que representa un segmento popular de ruta entre usuarios
class RouteSegmentEntity {
  final String id;
  final String name;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final double distanceKm;
  final int totalAttempts;
  final double bestTimeSeconds;
  final String? bestUserId;

  const RouteSegmentEntity({
    required this.id,
    required this.name,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.distanceKm,
    required this.totalAttempts,
    required this.bestTimeSeconds,
    this.bestUserId,
  });

  factory RouteSegmentEntity.fromMap(Map<String, dynamic> map) {
    return RouteSegmentEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Segmento',
      startLat: (map['startLat'] as num).toDouble(),
      startLng: (map['startLng'] as num).toDouble(),
      endLat: (map['endLat'] as num).toDouble(),
      endLng: (map['endLng'] as num).toDouble(),
      distanceKm: (map['distanceKm'] as num).toDouble(),
      totalAttempts: (map['totalAttempts'] as num?)?.toInt() ?? 0,
      bestTimeSeconds: (map['bestTimeSeconds'] as num?)?.toDouble() ?? 0,
      bestUserId: map['bestUserId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'startLat': startLat,
    'startLng': startLng,
    'endLat': endLat,
    'endLng': endLng,
    'distanceKm': distanceKm,
    'totalAttempts': totalAttempts,
    'bestTimeSeconds': bestTimeSeconds,
    'bestUserId': bestUserId,
  };
}
