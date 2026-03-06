
class AccidentEntity {
  final String id;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String description;
  final String severity; // 'minor', 'moderate', 'severe'
  final List<String> imageUrls;
  final DateTime createdAt;
  final bool resolved;

  const AccidentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.severity,
    this.imageUrls = const [],
    required this.createdAt,
    this.resolved = false,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'latitude': latitude,
    'longitude': longitude,
    'description': description,
    'severity': severity,
    'imageUrls': imageUrls,
    'createdAt': createdAt.toIso8601String(),
    'resolved': resolved,
  };

  factory AccidentEntity.fromMap(String id, Map<String, dynamic> map) => AccidentEntity(
    id: id,
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
    longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
    description: map['description'] ?? '',
    severity: map['severity'] ?? 'minor',
    imageUrls: List<String>.from(map['imageUrls'] ?? []),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    resolved: map['resolved'] ?? false,
  );
}
