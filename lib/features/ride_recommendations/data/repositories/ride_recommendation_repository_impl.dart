import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/ride_recommendations/domain/entities/ride_recommendation_entity.dart';
import 'package:biux/features/ride_recommendations/domain/repositories/ride_recommendation_repository.dart';
import 'package:biux/features/ride_recommendations/data/models/ride_recommendation_model.dart';

class RideRecommendationRepositoryImpl implements RideRecommendationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _col = 'ride_recommendations';

  @override
  Future<void> sendRecommendation(RideRecommendationEntity r) async {
    final model = RideRecommendationModel(
      id: r.id,
      fromUserId: r.fromUserId,
      fromUserName: r.fromUserName,
      fromUserPhoto: r.fromUserPhoto,
      toUserId: r.toUserId,
      trackId: r.trackId,
      routeName: r.routeName,
      description: r.description,
      type: r.type,
      totalKm: r.totalKm,
      estimatedMinutes: r.estimatedMinutes,
      avgSpeed: r.avgSpeed,
      calories: r.calories,
      highlights: r.highlights,
      coverImageUrl: r.coverImageUrl,
      startLat: r.startLat,
      startLng: r.startLng,
      isRead: r.isRead,
      createdAt: r.createdAt,
    );
    await _db.collection(_col).add(model.toFirestore());
  }

  @override
  Future<List<RideRecommendationEntity>> getMyRecommendations(
    String userId,
  ) async {
    final snap = await _db
        .collection(_col)
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => RideRecommendationModel.fromFirestore(d))
        .toList();
  }

  @override
  Future<List<RideRecommendationEntity>> getSentRecommendations(
    String userId,
  ) async {
    final snap = await _db
        .collection(_col)
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => RideRecommendationModel.fromFirestore(d))
        .toList();
  }

  @override
  Future<void> markAsRead(String recommendationId) async {
    await _db.collection(_col).doc(recommendationId).update({'isRead': true});
  }

  @override
  Future<void> deleteRecommendation(String recommendationId) async {
    await _db.collection(_col).doc(recommendationId).delete();
  }
}
