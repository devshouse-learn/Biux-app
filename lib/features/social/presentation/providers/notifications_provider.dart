import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:biux/features/social/domain/entities/notification_entity.dart';
import 'package:biux/features/social/domain/repositories/notifications_repository.dart';

/// Provider para gestionar notificaciones
class NotificationsProvider extends ChangeNotifier {
  static const _kMarkReadError = 'notif_mark_read_error';
  static const _kMarkAllReadError = 'notif_mark_all_read_error';
  static const _kDeleteError = 'notif_delete_error';
  static const _kDeleteAllError = 'notif_delete_all_error';

  final NotificationsRepository _repository;
  final String userId;

  // Estado estático que sobrevive a recreaciones del provider
  static final Set<String> _readIds = {};
  static final Set<String> _deletedIds = {};
  static final Map<String, String> _updatedMessages = {};
  static final Map<String, NotificationType> _updatedTypes = {};
  static String? _lastUserId;

  NotificationsProvider({
    required NotificationsRepository repository,
    required this.userId,
  }) : _repository = repository {
    // Limpiar estado estático si cambió el usuario
    if (_lastUserId != null && _lastUserId != userId) {
      _readIds.clear();
      _deletedIds.clear();
      _updatedMessages.clear();
      _updatedTypes.clear();
    }
    _lastUserId = userId;
    _init();
  }

  List<NotificationEntity> _notifications = [];
  final List<NotificationEntity> _localNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<NotificationEntity>>? _notificationsSub;
  StreamSubscription<int>? _unreadCountSub;

  List<NotificationEntity> get notifications {
    // Combinar notificaciones locales + Firebase, sin duplicados
    final combined = <NotificationEntity>[..._localNotifications];
    for (final n in _notifications) {
      if (!combined.any((local) => local.id == n.id)) {
        combined.add(n);
      }
    }
    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return combined;
  }

  int get unreadCount =>
      _unreadCount + _localNotifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => unreadCount > 0;

  void _init() {
    if (kDebugMode) {
      debugPrint('=== NotificationsProvider INICIADO con userId: $userId ===');
    }

    // Escuchar notificaciones
    _notificationsSub = _repository
        .watchUserNotifications(userId)
        .listen(
          (notifications) {
            if (kDebugMode) {
              debugPrint(
                '🔗 EVENTO DEL STREAM: ${notifications.length} notificaciones recibidas',
              );
            }

            _notifications = notifications;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            if (kDebugMode) {
              debugPrint('ERROR EN STREAM: $e');
            }
            _error = e.toString();
            notifyListeners();
          },
        );

    // Escuchar contador de no leidas
    _unreadCountSub = _repository
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

    _isLoading = true;
    notifyListeners();
  }

  /// Marca una notificacion como leida
  Future<void> markAsRead(String notificationId) async {
    // Guardar en estado estático para persistencia
    _readIds.add(notificationId);

    // Si es local, actualizarla en memoria
    final localIdx = _localNotifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (localIdx != -1) {
      _localNotifications[localIdx] = _localNotifications[localIdx].copyWith(
        isRead: true,
      );
      notifyListeners();
      return;
    }
    try {
      await _repository.markAsRead(userId, notificationId);
    } on Exception catch (e) {
      _error = _kMarkReadError;
      notifyListeners();
    }
  }

  /// Marca todas las notificaciones como leidas
  Future<void> markAllAsRead() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Marcar notificaciones locales como leídas
      for (var i = 0; i < _localNotifications.length; i++) {
        if (!_localNotifications[i].isRead) {
          _readIds.add(_localNotifications[i].id);
          _localNotifications[i] = _localNotifications[i].copyWith(
            isRead: true,
          );
        }
      }

      await _repository.markAllAsRead(userId);

      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _error = _kMarkAllReadError;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Elimina una notificacion
  Future<void> deleteNotification(String notificationId) async {
    // Si es una notificación local, eliminarla del estado local
    if (_localNotifications.any((n) => n.id == notificationId)) {
      _removeLocalNotification(notificationId);
      return;
    }
    try {
      await _repository.deleteNotification(userId, notificationId);
    } on Exception catch (e) {
      _error = _kDeleteError;
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
      _error = _kDeleteAllError;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Elimina una notificación local por ID
  void _removeLocalNotification(String id) {
    _deletedIds.add(id);
    _localNotifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Actualiza una notificación local (para cambiar mensaje/tipo tras aceptar/rechazar)
  void updateLocalNotification(
    String id, {
    String? message,
    NotificationType? type,
    bool? isRead,
  }) {
    // Persistir en estado estático
    if (message != null) _updatedMessages[id] = message;
    if (type != null) _updatedTypes[id] = type;
    if (isRead == true) _readIds.add(id);

    final idx = _localNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _localNotifications[idx] = _localNotifications[idx].copyWith(
        message: message,
        type: type,
        isRead: isRead,
      );
      notifyListeners();
    }
  }

  /// Verifica si una notificación es local (de prueba)
  bool isLocalNotification(String id) {
    return _localNotifications.any((n) => n.id == id);
  }

  @override
  void dispose() {
    _notificationsSub?.cancel();
    _unreadCountSub?.cancel();
    super.dispose();
  }
}
