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
    debugPrint('ðŸ”” NotificationsProvider._init() para userId: $userId');

    // Escuchar notificaciones
    _repository
        .watchUserNotifications(userId)
        .listen(
          (notifications) {
            debugPrint(
              'ðŸ”” Notificaciones recibidas: ${notifications.length} para userId: $userId',
            );
            for (final n in notifications) {
              debugPrint(
                '   â†’ tipo=${n.type.value}, de=${n.fromUserName}, msg=${n.message}',
              );
            }
            _notifications = notifications;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('âŒ Error en stream de notificaciones: $e');
            _error = e.toString();
            notifyListeners();
          },
        );

    // Escuchar contador de no leÃ­das
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

  /// Marca una notificaciÃ³n como leÃ­da
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(userId, notificationId);
    } on Exception catch (e) {
      _error = 'notif_mark_read_error';
      notifyListeners();
    }
  }

  /// Marca todas las notificaciones como leÃ­das
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

  /// Elimina una notificaciÃ³n
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
}

