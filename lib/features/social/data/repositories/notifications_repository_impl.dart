import "package:flutter/foundation.dart";
import 'package:biux/features/social/domain/entities/notification_entity.dart';
import 'package:biux/features/social/domain/repositories/notifications_repository.dart';
import 'package:biux/features/social/data/datasources/notifications_realtime_datasource.dart';
import 'package:biux/features/social/data/models/notification_model.dart';

/// Implementación del repositorio de notificaciones
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRealtimeDatasource _datasource;

  NotificationsRepositoryImpl({NotificationsRealtimeDatasource? datasource})
    : _datasource = datasource ?? NotificationsRealtimeDatasource();

  @override
  Stream<List<NotificationEntity>> watchUserNotifications(String userId) {
    return _datasource
        .watchUserNotifications(userId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _datasource.watchUnreadCount(userId);
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) {
    return _datasource.markAsRead(userId, notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) {
    return _datasource.markAllAsRead(userId);
  }

  @override
  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    NotificationTargetType? targetType,
    String? targetId,
    String? targetPreview,
    Map<String, dynamic>? metadata,
    String? notificationId,
  }) {
    final message = _buildNotificationMessage(
      type: type,
      fromUserName: fromUserName,
      targetType: targetType,
    );

    final notification = NotificationModel(
      id: '', // Se generará automáticamente en el datasource
      type: type.value,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserPhoto: fromUserPhoto,
      targetType: targetType?.value,
      targetId: targetId,
      targetPreview: targetPreview,
      message: message,
      isRead: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      metadata: metadata,
    );

    debugPrint('🔍 DEBUG - Creando notificación en repository:');
    debugPrint('   Para userId: $userId');
    debugPrint('   De: $fromUserName ($fromUserId)');
    debugPrint('   Tipo: ${type.value}');
    debugPrint('   isRead: false');
    debugPrint('   timestamp: ${notification.timestamp}');

    return _datasource.createNotification(
      userId: userId,
      notification: notification,
      notificationId: notificationId,
    );
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) {
    return _datasource.deleteNotification(userId, notificationId);
  }

  @override
  Future<void> deleteAllNotifications(String userId) {
    return _datasource.deleteAllNotifications(userId);
  }

  /// Construye el mensaje de notificación según el tipo
  String _buildNotificationMessage({
    required NotificationType type,
    required String fromUserName,
    NotificationTargetType? targetType,
  }) {
    switch (type) {
      case NotificationType.likePost:
        return '$fromUserName le dio me gusta a tu publicación';
      case NotificationType.likeComment:
        return '$fromUserName le dio me gusta a tu comentario';
      case NotificationType.likeStory:
        return '$fromUserName le dio me gusta a tu historia';
      case NotificationType.commentPost:
        return '$fromUserName comentó tu publicación';
      case NotificationType.commentRide:
        return '$fromUserName comentó tu rodada';
      case NotificationType.replyComment:
        return '$fromUserName respondió a tu comentario';
      case NotificationType.rideJoin:
        return '$fromUserName se unió a tu rodada';
      case NotificationType.mention:
        return '$fromUserName te mencionó';
      case NotificationType.follow:
        return '$fromUserName comenzó a seguirte';
      case NotificationType.followRequest:
        return '$fromUserName quiere seguirte';
    }
  }
}
