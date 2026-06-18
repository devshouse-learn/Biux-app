import 'package:firebase_database/firebase_database.dart';
import 'package:biux/features/social/data/models/notification_model.dart';
import "package:flutter/foundation.dart";

/// Datasource para notificaciones en Firebase Realtime Database
class NotificationsRealtimeDatasource {
  final FirebaseDatabase _database;

  NotificationsRealtimeDatasource({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Stream de notificaciones del usuario
  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    final ref = _database.ref('notifications/$userId');
    debugPrint('📡 DATASOURCE: Escuchando notificaciones para userId=$userId');

    return ref.orderByChild('timestamp').limitToLast(100).onValue.map((event) {
      debugPrint('📡 DATASOURCE: onValue EVENT RECIBIDO');

      if (event.snapshot.value == null) {
        debugPrint(
          '📡 DATASOURCE: snapshot.value es NULL - retornando lista vacia',
        );
        return <NotificationModel>[];
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      debugPrint('📡 DATASOURCE: Firebase devuelve ${data.length} items');

      final notifications = <NotificationModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          debugPrint('📡 DATASOURCE: Parseando item key=$key');
          notifications.add(NotificationModel.fromJson(key, value));
        }
      });

      // Ordenar por timestamp descendente (más recientes primero)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '📡 DATASOURCE: Retornando ${notifications.length} notificaciones parseadas',
      );
      for (final n in notifications) {
        debugPrint('📡 DATASOURCE:   - ${n.id} (${n.type})');
      }

      return notifications;
    });
  }

  /// Stream del conteo de notificaciones no leídas
  Stream<int> watchUnreadCount(String userId) {
    final ref = _database.ref('notifications/unread/$userId');

    return ref.onValue
        .map((event) {
          if (event.snapshot.value == null) {
            debugPrint('   Contador: 0 (null)');
            return 0;
          }

          // ⚠️ Las reglas esperan estructura {count: number, lastUpdated: number}
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          final count = data?['count'] as int? ?? 0;
          debugPrint('   Contador: $count');
          return count;
        })
        .handleError((error) {
          // Retornar 0 en caso de error en vez de fallar
          return 0;
        });
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String userId, String notificationId) async {
    final notificationRef = _database.ref(
      'notifications/$userId/$notificationId',
    );
    final unreadRef = _database.ref('notifications/unread/$userId');

    await notificationRef.update({'isRead': true});

    // Decrementar contador de no leídas
    final snapshot = await unreadRef.get();

    // ⚠️ Las reglas esperan estructura {count: number, lastUpdated: number}
    final currentData = snapshot.value as Map<dynamic, dynamic>?;
    final currentCount = currentData?['count'] as int? ?? 0;

    if (currentCount > 0) {
      await unreadRef.set({
        'count': currentCount - 1,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    }
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

    // Solo incrementar contador para notificaciones realmente nuevas
    if (isNewNotification) {
      final unreadRef = _database.ref('notifications/unread/$userId');
      final snapshot = await unreadRef.get();

      final currentData = snapshot.value as Map<dynamic, dynamic>?;
      final currentCount = currentData?['count'] as int? ?? 0;

      await unreadRef.set({
        'count': currentCount + 1,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
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
        final unreadSnapshot = await unreadRef.get();

        // ⚠️ Las reglas esperan estructura {count: number, lastUpdated: number}
        final currentData = unreadSnapshot.value as Map<dynamic, dynamic>?;
        final currentCount = currentData?['count'] as int? ?? 0;

        if (currentCount > 0) {
          await unreadRef.set({
            'count': currentCount - 1,
            'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          });
        }
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
