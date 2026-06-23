import 'package:firebase_database/firebase_database.dart';
import 'package:biux/features/social/data/models/notification_model.dart';
import "package:flutter/foundation.dart";

/// Datasource para notificaciones en Firebase Realtime Database
class NotificationsRealtimeDatasource {
  final FirebaseDatabase _database;

  /// Límite máximo de notificaciones a cargar
  static const int _maxNotifications = 100;

  NotificationsRealtimeDatasource({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Stream de notificaciones del usuario (limitado a las más recientes)
  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    final ref = _database.ref('notifications/$userId');
    final query = ref.orderByChild('createdAt').limitToLast(_maxNotifications);

    return query.onValue.map((event) {
      if (event.snapshot.value == null) {
        return <NotificationModel>[];
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;

      final notifications = <NotificationModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          notifications.add(NotificationModel.fromJson(key, value));
        }
      });

      // Ordenar por timestamp descendente (más recientes primero)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return notifications;
    });
  }

  /// Stream del conteo de notificaciones no leídas
  Stream<int> watchUnreadCount(String userId) {
    final ref = _database.ref('notifications/unread/$userId');

    return ref.onValue
        .map((event) {
          if (event.snapshot.value == null) {
            return 0;
          }

          // ⚠️ Las reglas esperan estructura {count: number, lastUpdated: number}
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          final count = data?['count'] as int? ?? 0;
          return count;
        })
        .handleError(
          (error) {
            debugPrint('Error en watchUnreadCount: $error');
          },
          test: (error) => false, // No consumir el error, dejarlo pasar como 0
        );
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String userId, String notificationId) async {
    final notificationRef = _database.ref(
      'notifications/$userId/$notificationId',
    );
    final unreadRef = _database.ref('notifications/unread/$userId');

    await notificationRef.update({'isRead': true});

    // Decrementar contador de no leídas con transacción atómica
    await unreadRef.runTransaction((currentData) {
      if (currentData == null) return Transaction.success(currentData);
      final data = Map<String, dynamic>.from(currentData as Map);
      final currentCount = (data['count'] as int?) ?? 0;
      if (currentCount > 0) {
        data['count'] = currentCount - 1;
        data['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;
      }
      return Transaction.success(data);
    });
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead(String userId) async {
    final notificationsRef = _database.ref('notifications/$userId');
    final unreadRef = _database.ref('notifications/unread/$userId');

    // Obtener todas las notificaciones
    final snapshot = await notificationsRef.get();
    if (snapshot.value == null) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final updates = <String, dynamic>{};

    // Marcar todas como leídas
    data.forEach((key, value) {
      updates['$key/isRead'] = true;
    });

    await notificationsRef.update(updates);

    // ⚠️ Las reglas esperan estructura {count: number, lastUpdated: number}
    await unreadRef.set({
      'count': 0,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Crea una nueva notificación
  /// Si se provee [notificationId], usa ese ID determinístico (para likes).
  /// Esto evita duplicados: un segundo set() en el mismo path pisa la anterior
  /// y no incrementa el contador.
  Future<void> createNotification({
    required String userId,
    required NotificationModel notification,
    String? notificationId,
  }) async {
    final DatabaseReference notificationRef;
    final String resolvedId;

    if (notificationId != null) {
      notificationRef = _database.ref('notifications/$userId/$notificationId');
      resolvedId = notificationId;
    } else {
      notificationRef = _database.ref('notifications/$userId').push();
      resolvedId = notificationRef.key!;
    }

    // Para IDs determinísticos verificar si ya existe antes de incrementar contador
    bool isNewNotification = true;
    if (notificationId != null) {
      final existing = await notificationRef.get();
      isNewNotification = !existing.exists;
    }

    final notificationWithId = NotificationModel(
      id: resolvedId,
      type: notification.type,
      fromUserId: notification.fromUserId,
      fromUserName: notification.fromUserName,
      fromUserPhoto: notification.fromUserPhoto,
      targetType: notification.targetType,
      targetId: notification.targetId,
      targetPreview: notification.targetPreview,
      message: notification.message,
      isRead: notification.isRead,
      timestamp: notification.timestamp,
      metadata: notification.metadata,
    );

    await notificationRef.set(notificationWithId.toJson());

    // Solo incrementar contador para notificaciones realmente nuevas (con transacción)
    if (isNewNotification) {
      final unreadRef = _database.ref('notifications/unread/$userId');
      await unreadRef.runTransaction((currentData) {
        if (currentData == null) {
          return Transaction.success({
            'count': 1,
            'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          });
        }
        final data = Map<String, dynamic>.from(currentData as Map);
        final currentCount = (data['count'] as int?) ?? 0;
        data['count'] = currentCount + 1;
        data['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;
        return Transaction.success(data);
      });
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(String userId, String notificationId) async {
    final notificationRef = _database.ref(
      'notifications/$userId/$notificationId',
    );

    // Verificar si está sin leer para decrementar contador
    final snapshot = await notificationRef.get();
    if (snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final isRead = data['isRead'] as bool? ?? false;

      await notificationRef.remove();

      if (!isRead) {
        final unreadRef = _database.ref('notifications/unread/$userId');
        await unreadRef.runTransaction((currentData) {
          if (currentData == null) return Transaction.success(currentData);
          final mapData = Map<String, dynamic>.from(currentData as Map);
          final currentCount = (mapData['count'] as int?) ?? 0;
          if (currentCount > 0) {
            mapData['count'] = currentCount - 1;
            mapData['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;
          }
          return Transaction.success(mapData);
        });
      }
    }
  }

  /// Elimina todas las notificaciones del usuario
  Future<void> deleteAllNotifications(String userId) async {
    final notificationsRef = _database.ref('notifications/$userId');
    final unreadRef = _database.ref('notifications/unread/$userId');

    await notificationsRef.remove();

    // ⚠️ Las reglas esperan estructura {count: number, lastUpdated: number}
    await unreadRef.set({
      'count': 0,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
