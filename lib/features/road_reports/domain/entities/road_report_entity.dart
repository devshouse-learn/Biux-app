class RoadReportEntity {
  final String id;
  final String userId;
  final String userName;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final int confirmations;
  final List<String> confirmedBy;
  final DateTime createdAt;
  final bool isActive;

  const RoadReportEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.confirmations = 0,
    this.confirmedBy = const [],
    required this.createdAt,
    this.isActive = true,
  });

  bool hasConfirmed(String uid) => confirmedBy.contains(uid);

  String get typeIcon => const {
    'pothole': '🕳️',
    'obstacle': '⚠️',
    'danger': '🚨',
    'construction': '🚧',
    'flooding': '🌊',
  }[type] ?? '📍';

  String get typeName => const {
    'pothole': 'Hueco',
    'obstacle': 'Obstáculo',
    'danger': 'Zona peligrosa',
    'construction': 'Construcción',
    'flooding': 'Inundación',
  }[type] ?? 'Otro';
}
