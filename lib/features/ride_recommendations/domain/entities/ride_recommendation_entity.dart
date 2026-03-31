enum RecommendationType {
  touristSpot('tourist_spot'),
  organizedRoute('organized_route'),
  scenic('scenic'),
  technical('technical'),
  family('family');

  final String value;
  const RecommendationType(this.value);

  String get label {
    switch (this) {
      case RecommendationType.touristSpot: return '🏛️ Sitio turístico';
      case RecommendationType.organizedRoute: return '🚴 Vía organizada';
      case RecommendationType.scenic: return '🌄 Ruta panorámica';
      case RecommendationType.technical: return '⚙️ Ruta técnica';
      case RecommendationType.family: return '👨‍👩‍👧 Apta para familia';
    }
  }

  static RecommendationType fromString(String v) =>
      RecommendationType.values.firstWhere((e) => e.value == v,
          orElse: () => RecommendationType.organizedRoute);
}

class RideRecommendationEntity {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhoto;
  final String toUserId;
  final String trackId;
  final String routeName;
  final String description;
  final RecommendationType type;
  final double totalKm;
  final int estimatedMinutes;
  final double avgSpeed;
  final int calories;
  final List<String> highlights;
  final String? coverImageUrl;
  final double startLat;
  final double startLng;
  final bool isRead;
  final DateTime createdAt;

  const RideRecommendationEntity({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhoto,
    required this.toUserId,
    required this.trackId,
    required this.routeName,
    required this.description,
    required this.type,
    required this.totalKm,
    required this.estimatedMinutes,
    required this.avgSpeed,
    required this.calories,
    required this.highlights,
    this.coverImageUrl,
    required this.startLat,
    required this.startLng,
    this.isRead = false,
    required this.createdAt,
  });

  String get estimatedTimeFormatted {
    if (estimatedMinutes >= 60) {
      final h = estimatedMinutes ~/ 60;
      final m = estimatedMinutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${estimatedMinutes}m';
  }

  RideRecommendationEntity copyWith({bool? isRead}) => RideRecommendationEntity(
    id: id, fromUserId: fromUserId, fromUserName: fromUserName,
    fromUserPhoto: fromUserPhoto, toUserId: toUserId, trackId: trackId,
    routeName: routeName, description: description, type: type,
    totalKm: totalKm, estimatedMinutes: estimatedMinutes, avgSpeed: avgSpeed,
    calories: calories, highlights: highlights, coverImageUrl: coverImageUrl,
    startLat: startLat, startLng: startLng,
    isRead: isRead ?? this.isRead, createdAt: createdAt,
  );
}
