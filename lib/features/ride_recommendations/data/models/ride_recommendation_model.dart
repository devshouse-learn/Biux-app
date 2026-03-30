import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ride_recommendation_entity.dart';

class RideRecommendationModel extends RideRecommendationEntity {
  const RideRecommendationModel({
    required super.id,
    required super.fromUserId,
    required super.fromUserName,
    super.fromUserPhoto,
    required super.toUserId,
    required super.trackId,
    required super.routeName,
    required super.description,
    required super.type,
    required super.totalKm,
    required super.estimatedMinutes,
    required super.avgSpeed,
    required super.calories,
    required super.highlights,
    super.coverImageUrl,
    required super.startLat,
    required super.startLng,
    super.isRead,
    required super.createdAt,
  });

  factory RideRecommendationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RideRecommendationModel(
      id: doc.id,
      fromUserId: d['fromUserId'] ?? '',
      fromUserName: d['fromUserName'] ?? '',
      fromUserPhoto: d['fromUserPhoto'],
      toUserId: d['toUserId'] ?? '',
      trackId: d['trackId'] ?? '',
      routeName: d['routeName'] ?? '',
      description: d['description'] ?? '',
      type: RecommendationType.fromString(d['type'] ?? ''),
      totalKm: (d['totalKm'] as num?)?.toDouble() ?? 0,
      estimatedMinutes: (d['estimatedMinutes'] as num?)?.toInt() ?? 0,
      avgSpeed: (d['avgSpeed'] as num?)?.toDouble() ?? 0,
      calories: (d['calories'] as num?)?.toInt() ?? 0,
      highlights: List<String>.from(d['highlights'] ?? []),
      coverImageUrl: d['coverImageUrl'],
      startLat: (d['startLat'] as num?)?.toDouble() ?? 0,
      startLng: (d['startLng'] as num?)?.toDouble() ?? 0,
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'fromUserId': fromUserId,
    'fromUserName': fromUserName,
    'fromUserPhoto': fromUserPhoto,
    'toUserId': toUserId,
    'trackId': trackId,
    'routeName': routeName,
    'description': description,
    'type': type.value,
    'totalKm': totalKm,
    'estimatedMinutes': estimatedMinutes,
    'avgSpeed': avgSpeed,
    'calories': calories,
    'highlights': highlights,
    'coverImageUrl': coverImageUrl,
    'startLat': startLat,
    'startLng': startLng,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
