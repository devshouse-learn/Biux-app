import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      print('NotificationService inicializado correctamente');
    } catch (e) {
      print('Error inicializando NotificationService: $e');
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

    print('📱 Permisos de notificación: ${settings.authorizationStatus}');
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
    print('📬 Notificación recibida en foreground: ${message.messageId}');

    // Crear notificación en Firestore
    await _saveNotificationToFirestore(message);

    // Mostrar notificación local
    await _showLocalNotification(message);

    // Emitir evento para actualizar UI
    _notificationStreamController.add(message.data);
  }

  /// Maneja cuando el usuario toca una notificación (app en background)
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('🔔 Notificación tocada (background): ${message.messageId}');

    // Agregar delay para asegurar que el contexto esté listo
    Future.delayed(const Duration(milliseconds: 500), () {
      _notificationStreamController.add({...message.data, 'opened': true});
    });
  }

  /// Verifica si la app se abrió desde una notificación
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print(
        '🚀 App abierta desde notificación (terminated): ${initialMessage.messageId}',
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
                notification?.title ?? data['title'] ?? 'Nueva notificación',
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

      print('✅ Notificación guardada en Firestore');
    } catch (e) {
      print('❌ Error guardando notificación en Firestore: $e');
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
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _notificationStreamController.add({...data, 'opened': true});
      } catch (e) {
        print('❌ Error procesando payload de notificación: $e');
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

      print('✅ Token FCM guardado: ${token.substring(0, 20)}...');

      // Escuchar cambios de token
      _fcm.onTokenRefresh.listen((newToken) {
        _updateDeviceToken(userId, newToken);
      });
    } catch (e) {
      print('❌ Error guardando token FCM: $e');
    }
  }

  /// Actualiza el token del dispositivo
  Future<void> _updateDeviceToken(String userId, String newToken) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([newToken]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });

      print('🔄 Token FCM actualizado');
    } catch (e) {
      print('❌ Error actualizando token FCM: $e');
    }
  }

  /// Reinicializa el servicio después del login (guarda token del usuario actual)
  Future<void> reinitializeAfterLogin() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('⚠️ No hay usuario autenticado');
        return;
      }

      // Obtener y guardar token
      await _saveDeviceToken();

      // Inicializar preferencias de notificación si no existen
      await _ensureNotificationSettings(userId);

      print(
        '✅ NotificationService reinicializado para usuario: ${userId.substring(0, 8)}...',
      );
    } catch (e) {
      print('❌ Error reinicializando NotificationService: $e');
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

        print('✅ Preferencias de notificación inicializadas');
      }
    } catch (e) {
      print('❌ Error inicializando preferencias: $e');
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
      print('🗑️ Token FCM eliminado');
    } catch (e) {
      print('❌ Error eliminando token FCM: $e');
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
      print('🚨 Enviando alerta de robo al propietario $bikeOwnerId');

      // Obtener tokens FCM del propietario
      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(bikeOwnerId)
          .get();

      if (!ownerDoc.exists) {
        print('⚠️ Usuario propietario no encontrado');
        return;
      }

      final ownerData = ownerDoc.data();
      final fcmTokens = ownerData?['fcmTokens'] as List<dynamic>?;

      if (fcmTokens == null || fcmTokens.isEmpty) {
        print('⚠️ El propietario no tiene tokens FCM registrados');
        return;
      }

      // Crear notificación en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(bikeOwnerId)
          .collection('notifications')
          .add({
            'title': '🚨 ALERTA: Intento de venta de tu bicicleta robada',
            'body':
                'Alguien intentó vender tu $bikeBrand $bikeModel (Serie: $bikeFrameSerial)',
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

      print('✅ Alerta de robo guardada en Firestore');

      // Aquí se enviaría la notificación push real mediante Cloud Functions
      // En producción, esto se haría desde el backend usando Admin SDK
      print('📤 Notificación push enviada al propietario (simulado)');
    } catch (e) {
      print('❌ Error enviando alerta de robo: $e');
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
      print('📢 Notificando a administradores sobre intento de robo');

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
              'title':
                  '⚠️ Alerta de Seguridad: Intento de venta de bici robada',
              'body':
                  '$sellerName intentó vender $bikeBrand $bikeModel (Serie: $bikeFrameSerial)',
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

      print(
        '✅ Administradores notificados (${adminsQuery.docs.length} admins)',
      );
    } catch (e) {
      print('❌ Error notificando a administradores: $e');
    }
  }
}

/// Manejador de mensajes en background (debe estar fuera de la clase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Mensaje recibido en background: ${message.messageId}');
  // Aquí puedes agregar lógica adicional para procesar el mensaje en background
}
