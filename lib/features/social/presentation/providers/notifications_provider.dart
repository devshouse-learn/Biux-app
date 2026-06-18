import 'package:flutter/foundation.dart';
import 'package:biux/features/social/domain/entities/notification_entity.dart';
import 'package:biux/features/social/domain/repositories/notifications_repository.dart';

/// Provider para gestionar notificaciones
class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository _repository;
  final String userId;

  NotificationsProvider({
    required NotificationsRepository repository,
    required this.userId,
  }) : _repository = repository {
    _init();
  }

  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  void _init() {
    debugPrint('=== NotificationsProvider INICIADO con userId: $userId ===');
    // Escuchar notificaciones
    _repository
        .watchUserNotifications(userId)
        .listen(
          (notifications) {
            debugPrint(
              '═══════════════════════════════════════════════════════════',
            );
            debugPrint(
              '🔗 EVENTO DEL STREAM: ${notifications.length} notificaciones recibidas',
            );

            if (notifications.isEmpty) {
              debugPrint('⚠️  ADVERTENCIA: STREAM VACIO (0 notificaciones)');
            }

            for (int i = 0; i < notifications.length; i++) {
              final n = notifications[i];
              debugPrint(
                '[$i] ID="${n.id}" | tipo=${n.type.value} | de=${n.fromUserName} | msg="${n.message}"',
              );
            }

            debugPrint(
              '═══════════════════════════════════════════════════════════',
            );

            _notifications = notifications;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('ERROR EN STREAM: $e');
            _error = e.toString();
            notifyListeners();
          },
        );

    // Escuchar contador de no leidas
    _repository
        .watchUnreadCount(userId)
        .listen(
          (count) {
            _unreadCount = count;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  /// Marca una notificacion como leida
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(userId, notificationId);
    } on Exception catch (e) {
      _error = 'notif_mark_read_error';
      notifyListeners();
    }
  }

  /// Marca todas las notificaciones como leidas
  Future<void> markAllAsRead() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.markAllAsRead(userId);

      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = 'notif_mark_all_read_error';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Elimina una notificacion
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(userId, notificationId);
    } on Exception catch (e) {
      _error = 'notif_delete_error';
      notifyListeners();
    }
  }

  /// Elimina todas las notificaciones
  Future<void> deleteAllNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteAllNotifications(userId);

      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = 'notif_delete_all_error';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Elimina notificaciones antiguas de prueba con formato incorrecto
  Future<void> cleanOldTestNotifications() async {
    try {
      final toDelete = _notifications
          .where(
            (n) =>
                n.message.contains('(cuenta privada)') ||
                n.message.contains('(cuenta pública)') ||
                (n.fromUserPhoto != null &&
                    n.fromUserPhoto!.isNotEmpty &&
                    n.fromUserPhoto!.contains('test')),
          )
          .toList();

      for (final notif in toDelete) {
        await deleteNotification(notif.id);
      }

      if (toDelete.isNotEmpty) {
        debugPrint('🧹 Limpiadas ${toDelete.length} notificaciones antiguas');
      }
    } catch (e) {
      debugPrint('Error limpiando notificaciones: $e');
    }
  }
}
