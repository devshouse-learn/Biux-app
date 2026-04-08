import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio centralizado de analytics con eventos tipados.
///
/// Uso en GoRouter:
/// ```dart
/// GoRouter(observers: [AnalyticsService.observer])
/// ```
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ══════════════════════════════════════════
  // Autenticación
  // ══════════════════════════════════════════

  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
    await _logEvent('user_login', {'method': method});
  }

  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
    await _logEvent('user_signup', {'method': method});
  }

  static Future<void> logLogout() async {
    await _logEvent('user_logout', {});
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ══════════════════════════════════════════
  // Rodadas (Rides)
  // ══════════════════════════════════════════

  static Future<void> logRideCreated(String rideId) async {
    await _logEvent('ride_created', {'ride_id': rideId});
  }

  static Future<void> logRideJoined(String rideId) async {
    await _logEvent('ride_joined', {'ride_id': rideId});
  }

  static Future<void> logRideLeft(String rideId) async {
    await _logEvent('ride_left', {'ride_id': rideId});
  }

  static Future<void> logRideCompleted({
    required String rideId,
    required double distanceKm,
    required int durationMinutes,
  }) async {
    await _logEvent('ride_completed', {
      'ride_id': rideId,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
    });
  }

  // ══════════════════════════════════════════
  // Grupos
  // ══════════════════════════════════════════

  static Future<void> logGroupCreated(String groupId) async {
    await _logEvent('group_created', {'group_id': groupId});
  }

  static Future<void> logGroupJoined(String groupId) async {
    await _logEvent('group_joined', {'group_id': groupId});
  }

  static Future<void> logGroupLeft(String groupId) async {
    await _logEvent('group_left', {'group_id': groupId});
  }

  // ══════════════════════════════════════════
  // Social
  // ══════════════════════════════════════════

  static Future<void> logPostCreated(String postId) async {
    await _logEvent('post_created', {'post_id': postId});
  }

  static Future<void> logPostLiked(String postId) async {
    await _logEvent('post_liked', {'post_id': postId});
  }

  static Future<void> logCommentCreated(String postId) async {
    await _logEvent('comment_created', {'post_id': postId});
  }

  static Future<void> logStoryCreated() async {
    await _logEvent('story_created', {});
  }

  static Future<void> logStoryViewed(String storyId) async {
    await _logEvent('story_viewed', {'story_id': storyId});
  }

  static Future<void> logUserFollowed(String userId) async {
    await _logEvent('user_followed', {'target_user_id': userId});
  }

  // ══════════════════════════════════════════
  // Bicicletas
  // ══════════════════════════════════════════

  static Future<void> logBikeRegistered(String bikeId) async {
    await _logEvent('bike_registered', {'bike_id': bikeId});
  }

  static Future<void> logBikeTheftReported(String bikeId) async {
    await _logEvent('bike_theft_reported', {'bike_id': bikeId});
  }

  // ══════════════════════════════════════════
  // Mapas y Rutas
  // ══════════════════════════════════════════

  static Future<void> logRouteCreated(String routeId) async {
    await _logEvent('route_created', {'route_id': routeId});
  }

  static Future<void> logMapOpened() async {
    await _logEvent('map_opened', {});
  }

  static Future<void> logDangerZoneReported() async {
    await _logEvent('danger_zone_reported', {});
  }

  // ══════════════════════════════════════════
  // Emergencia
  // ══════════════════════════════════════════

  static Future<void> logEmergencyTriggered(String type) async {
    await _logEvent('emergency_triggered', {'type': type});
  }

  // ══════════════════════════════════════════
  // Tienda
  // ══════════════════════════════════════════

  static Future<void> logProductViewed(String productId) async {
    await _logEvent('product_viewed', {'product_id': productId});
  }

  static Future<void> logAddToCart(String productId) async {
    await _logEvent('add_to_cart', {'product_id': productId});
  }

  static Future<void> logPurchaseCompleted(double amount) async {
    await _logEvent('purchase_completed', {'amount': amount});
  }

  // ══════════════════════════════════════════
  // Logros
  // ══════════════════════════════════════════

  static Future<void> logAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {
    await _logEvent('unlock_achievement', {
      'achievement_id': achievementId,
      'achievement_name': achievementName,
    });
  }

  // ══════════════════════════════════════════
  // Pantallas y navegación
  // ══════════════════════════════════════════

  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  static Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  static Future<void> logShare({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: 'app',
    );
  }

  // ══════════════════════════════════════════
  // Helper interno
  // ══════════════════════════════════════════

  static Future<void> _logEvent(
    String name,
    Map<String, Object> parameters,
  ) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      AppLogger.error('Error logging analytics event: $name', error: e, tag: 'Analytics');
    }
  }
}
