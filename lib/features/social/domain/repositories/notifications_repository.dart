import 'package:biux/features/social/domain/entities/notification_entity.dart';

/// Repositorio de notificaciones (interfaz)
abstract class NotificationsRepository {
  /// Stream de notificaciones del usuario actual
  Stream<List<NotificationEntity>> watchUserNotifications(String userId);

  /// Obtiene el conteo de notificaciones no leídas
  Stream<int> watchUnreadCount(String userId);

  /// Marca una notificación como leída
  Future<void> markAsRead(String userId, String notificationId);

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead(String userId);

  /// Crea una nueva notificación.
  /// [notificationId]: si se provee, usa ID determinístico (para likes sin duplicados).
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
  });

  /// Elimina una notificación
  Future<void> deleteNotification(String userId, String notificationId);

  /// Elimina todas las notificaciones del usuario
  Future<void> deleteAllNotifications(String userId);
}
