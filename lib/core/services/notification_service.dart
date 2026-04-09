import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio para manejar notificaciones push y locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<Map<String, dynamic>> _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  bool _isInitialized = false;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeLocalNotifications();
      await _requestPermissions();
      _configureFCMHandlers();
      await _saveDeviceToken();

      _isInitialized = true;
      AppLogger.info('NotificationService inicializado', tag: 'Notifications');
    } catch (e) {
      AppLogger.error(
        'Error inicializando NotificationService',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  /// Inicializa las notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Canal de notificaciones para Android
    const androidChannel = AndroidNotificationChannel(
      'biux_notifications', // id
      'Notificaciones de Biux', // nombre
      description: 'Notificaciones generales de la aplicación',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Solicita permisos para notificaciones
  Future<void> _requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    AppLogger.debug(
      'Permisos de notificación: ${settings.authorizationStatus}',
      tag: 'Notifications',
    );
  }

  /// Configura los manejadores de FCM
  void _configureFCMHandlers() {
    // Mensaje recibido cuando la app está en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensaje tocado cuando la app está en background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app se abrió desde una notificación
    _checkInitialMessage();
  }

  /// Maneja mensajes cuando la app está en primer plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.debug(
      'Notificación foreground: ${message.messageId}',
      tag: 'Notifications',
    );

    // Crear notificación en Firestore
    await _saveNotificationToFirestore(message);

    // Mostrar notificación local
    await _showLocalNotification(message);

    // Emitir evento para actualizar UI
    _notificationStreamController.add(message.data);
  }

  /// Maneja cuando el usuario toca una notificación (app en background)
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.debug(
      'Notificación tocada (background): ${message.messageId}',
      tag: 'Notifications',
    );

    // Agregar delay para asegurar que el contexto esté listo
    Future.delayed(const Duration(milliseconds: 500), () {
      _notificationStreamController.add({...message.data, 'opened': true});
    });
  }

  /// Verifica si la app se abrió desde una notificación
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.debug(
        'App abierta desde notificación (terminated)',
        tag: 'Notifications',
      );

      // Agregar delay mayor para app cerrada
      Future.delayed(const Duration(seconds: 1), () {
        _notificationStreamController.add({
          ...initialMessage.data,
          'opened': true,
        });
      });
    }
  }

  /// Guarda la notificación en Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final data = message.data;
      final notification = message.notification;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            'title':
                notification?.title ??
                data['title'] ??
                'notif_new_notification',
            'body': notification?.body ?? data['body'] ?? '',
            'type': data['type'] ?? 'general',
            'relatedId': data['relatedId'],
            'senderId': data['senderId'],
            'senderName': data['senderName'],
            'senderPhoto': data['senderPhoto'],
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
            'data': data,
          });

      AppLogger.debug(
        'Notificación guardada en Firestore',
        tag: 'Notifications',
      );
    } catch (e) {
      AppLogger.error(
        'Error guardando notificación en Firestore',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  /// Muestra una notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'biux_notifications',
      'Notificaciones de Biux',
      channelDescription: 'Notificaciones generales de la aplicación',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(data),
    );
  }

  /// Maneja cuando se toca una notificación local
  // ignore: unused_element
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _notificationStreamController.add({...data, 'opened': true});
      } catch (e) {
        AppLogger.error(
          'Error procesando payload de notificación',
          tag: 'Notifications',
          error: e,
        );
      }
    }
  }

  /// Guarda el token del dispositivo en Firestore
  Future<void> _saveDeviceToken() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final token = await _fcm.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Token FCM guardado', tag: 'Notifications');

      // Escuchar cambios de token
      _fcm.onTokenRefresh.listen((newToken) {
        _updateDeviceToken(userId, newToken);
      });
    } catch (e) {
      AppLogger.error(
        'Error guardando token FCM',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  /// Actualiza el token del dispositivo
  Future<void> _updateDeviceToken(String userId, String newToken) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([newToken]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });

      AppLogger.debug('Token FCM actualizado', tag: 'Notifications');
    } catch (e) {
      AppLogger.error(
        'Error actualizando token FCM',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  /// Reinicializa el servicio después del login (guarda token del usuario actual)
  Future<void> reinitializeAfterLogin() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        AppLogger.warning('No hay usuario autenticado', tag: 'Notifications');
        return;
      }

      // Obtener y guardar token
      await _saveDeviceToken();

      // Inicializar preferencias de notificación si no existen
      await _ensureNotificationSettings(userId);

      AppLogger.info(
        'NotificationService reinicializado',
        tag: 'Notifications',
      );
    } catch (e) {
      AppLogger.error(
        'Error reinicializando NotificationService',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  /// Asegura que el usuario tenga preferencias de notificación configuradas
  Future<void> _ensureNotificationSettings(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final data = userDoc.data();

      // Si no existen las preferencias, crear con valores por defecto
      if (data == null || !data.containsKey('notificationSettings')) {
        final defaultSettings = {
          'enablePushNotifications': true,
          'enableLikes': true,
          'enableComments': true,
          'enableFollows': true,
          'enableRideInvitations': true,
          'enableGroupInvitations': true,
          'enableStories': true,
          'enableRideReminders': true,
          'enableGroupUpdates': true,
          'enableSystemNotifications': true,
        };

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'notificationSettings': defaultSettings,
        }, SetOptions(merge: true));

        // También guardar en la subcolección
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('notifications')
            .set(defaultSettings);

        AppLogger.debug(
          'Preferencias de notificación inicializadas',
          tag: 'Notifications',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Error inicializando preferencias',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  /// Cancela todas las notificaciones locales
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancela una notificación específica
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id: id);
  }

  /// Obtiene el token FCM actual
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  /// Elimina el token FCM del dispositivo
  Future<void> deleteToken() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final token = await _fcm.getToken();

      if (userId != null && token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {
            'fcmTokens': FieldValue.arrayRemove([token]),
          },
        );
      }

      await _fcm.deleteToken();
      AppLogger.info('Token FCM eliminado', tag: 'Notifications');
    } catch (e) {
      AppLogger.error(
        'Error eliminando token FCM',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  /// Libera recursos
  void dispose() {
    _notificationStreamController.close();
  }

  // ========================================
  // NUEVAS FUNCIONALIDADES: Sistema Anti-Robo
  // ========================================

  /// Envía notificación al propietario cuando alguien intenta vender su bici robada
  Future<void> notifyStolenBikeSaleAttempt({
    required String bikeOwnerId,
    required String bikeFrameSerial,
    required String bikeBrand,
    required String bikeModel,
    required String sellerUid,
    required String sellerName,
  }) async {
    try {
      AppLogger.info(
        'Enviando alerta de robo al propietario $bikeOwnerId',
        tag: 'Notifications',
      );

      // Obtener tokens FCM del propietario
      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(bikeOwnerId)
          .get();

      if (!ownerDoc.exists) {
        AppLogger.warning(
          'Usuario propietario no encontrado',
          tag: 'Notifications',
        );
        return;
      }

      final ownerData = ownerDoc.data();
      final fcmTokens = ownerData?['fcmTokens'] as List<dynamic>?;

      if (fcmTokens == null || fcmTokens.isEmpty) {
        AppLogger.warning(
          'El propietario no tiene tokens FCM registrados',
          tag: 'Notifications',
        );
        return;
      }

      // Crear notificación en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(bikeOwnerId)
          .collection('notifications')
          .add({
            'title': 'notif_stolen_bike_alert_title',
            'body':
                'notif_stolen_bike_alert_body:$bikeBrand $bikeModel:$bikeFrameSerial',
            'type': 'theft_alert',
            'relatedId': bikeFrameSerial,
            'senderId': sellerUid,
            'senderName': sellerName,
            'bikeData': {
              'frameSerial': bikeFrameSerial,
              'brand': bikeBrand,
              'model': bikeModel,
            },
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Crear alerta en la colección de alertas de administración
      await FirebaseFirestore.instance.collection('theft_alerts').add({
        'bikeOwnerId': bikeOwnerId,
        'sellerUid': sellerUid,
        'sellerName': sellerName,
        'bikeData': {
          'frameSerial': bikeFrameSerial,
          'brand': bikeBrand,
          'model': bikeModel,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      AppLogger.info(
        'Alerta de robo guardada en Firestore',
        tag: 'Notifications',
      );
    } catch (e) {
      AppLogger.error(
        'Error enviando alerta de robo',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  /// Notifica a administradores sobre intentos de venta de bicis robadas
  Future<void> notifyAdminsAboutTheftAttempt({
    required String bikeFrameSerial,
    required String bikeBrand,
    required String bikeModel,
    required String sellerUid,
    required String sellerName,
  }) async {
    try {
      AppLogger.info(
        'Notificando a administradores sobre intento de robo',
        tag: 'Notifications',
      );

      // Obtener todos los administradores
      final adminsQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();

      for (final adminDoc in adminsQuery.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(adminDoc.id)
            .collection('notifications')
            .add({
              'title': 'notif_admin_theft_alert_title',
              'body':
                  'notif_admin_theft_alert_body:$sellerName:$bikeBrand $bikeModel:$bikeFrameSerial',
              'type': 'admin_theft_alert',
              'relatedId': bikeFrameSerial,
              'senderId': sellerUid,
              'senderName': sellerName,
              'bikeData': {
                'frameSerial': bikeFrameSerial,
                'brand': bikeBrand,
                'model': bikeModel,
              },
              'read': false,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      AppLogger.info(
        'Administradores notificados (${adminsQuery.docs.length})',
        tag: 'Notifications',
      );
    } catch (e) {
      AppLogger.error(
        'Error notificando a administradores',
        tag: 'Notifications',
        error: e,
      );
    }
  }
}

/// Manejador de mensajes en background (debe estar fuera de la clase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler - no se puede usar AppLogger aquí (isolate separado)
}
