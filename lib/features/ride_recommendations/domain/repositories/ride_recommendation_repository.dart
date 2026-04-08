import 'package:biux/features/ride_recommendations/domain/entities/ride_recommendation_entity.dart';

abstract class RideRecommendationRepository {
  Future<void> sendRecommendation(RideRecommendationEntity recommendation);
  Future<List<RideRecommendationEntity>> getMyRecommendations(String userId);
  Future<List<RideRecommendationEntity>> getSentRecommendations(String userId);
  Future<void> markAsRead(String recommendationId);
  Future<void> deleteRecommendation(String recommendationId);
}
