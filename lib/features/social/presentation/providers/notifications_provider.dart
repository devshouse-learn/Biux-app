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
    // Escuchar notificaciones
    _repository
        .watchUserNotifications(userId)
        .listen(
          (notifications) {
            _notifications = notifications;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );

    // Escuchar contador de no leídas
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

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(userId, notificationId);
    } catch (e) {
      _error = 'notif_mark_read_error';
      notifyListeners();
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.markAllAsRead(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'notif_mark_all_read_error';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(userId, notificationId);
    } catch (e) {
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
    } catch (e) {
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
