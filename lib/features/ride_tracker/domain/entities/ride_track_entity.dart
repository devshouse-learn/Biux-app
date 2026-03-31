class RideTrackEntity {
  final String id, userId;
  final String name;
  final List<TrackPoint> points;
  final double totalKm, avgSpeed, maxSpeed;
  final int elevationGain,
      durationMinutes,
      durationSeconds,
      calories,
      pointCount;
  final DateTime startTime, endTime;

  const RideTrackEntity({
    required this.id,
    required this.userId,
    this.name = '',
    required this.points,
    this.totalKm = 0,
    this.avgSpeed = 0,
    this.maxSpeed = 0,
    this.elevationGain = 0,
    this.durationMinutes = 0,
    this.durationSeconds = 0,
    this.calories = 0,
    this.pointCount = 0,
    required this.startTime,
    required this.endTime,
  });

  String get durationFormatted {
    if (durationSeconds > 0) {
      final h = durationSeconds ~/ 3600;
      final m = (durationSeconds % 3600) ~/ 60;
      final s = durationSeconds % 60;
      if (h > 0) return '${h}h ${m}m';
      if (m > 0) return '${m}m ${s}s';
      return '${s}s';
    }
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m';
    return '< 1m';
  }

  RideTrackEntity copyWith({String? name}) {
    return RideTrackEntity(
      id: id,
      userId: userId,
      name: name ?? this.name,
      points: points,
      totalKm: totalKm,
      avgSpeed: avgSpeed,
      maxSpeed: maxSpeed,
      elevationGain: elevationGain,
      durationMinutes: durationMinutes,
      durationSeconds: durationSeconds,
      calories: calories,
      pointCount: pointCount,
      startTime: startTime,
      endTime: endTime,
    );
  }
}

class TrackPoint {
  final double lat, lng, elevation, speed;
  final DateTime timestamp;

  const TrackPoint({
    required this.lat,
    required this.lng,
    this.elevation = 0,
    this.speed = 0,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    "lat": lat,
    "lng": lng,
    "elevation": elevation,
    "speed": speed,
    "timestamp": timestamp.millisecondsSinceEpoch,
  };

  factory TrackPoint.fromMap(Map<String, dynamic> m) => TrackPoint(
    lat: (m["lat"] as num).toDouble(),
    lng: (m["lng"] as num).toDouble(),
    elevation: (m["elevation"] as num?)?.toDouble() ?? 0,
    speed: (m["speed"] as num?)?.toDouble() ?? 0,
    timestamp: DateTime.fromMillisecondsSinceEpoch(m["timestamp"] as int),
  );
}
