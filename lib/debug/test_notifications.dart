import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Script de prueba para verificar notificaciones
class NotificationTester {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crear una notificación de prueba
  Future<void> createTestNotification() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      print('❌ No hay usuario autenticado');
      return;
    }

    print('👤 Usuario actual: $userId');

    try {
      // 1. Verificar que el token FCM esté guardado
      final tokens = await _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .get();

      print('📱 Tokens FCM encontrados: ${tokens.docs.length}');
      for (var token in tokens.docs) {
        print('   Token ID: ${token.id}');
        print('   Token: ${token.data()['token']?.substring(0, 20)}...');
        print('   Platform: ${token.data()['platform']}');
      }

      if (tokens.docs.isEmpty) {
        print('⚠️ NO HAY TOKENS FCM - Ejecuta reinitializeAfterLogin()');
        return;
      }

      // 2. Verificar preferencias de notificaciones
      final prefs = await _firestore
          .doc('users/$userId/notificationSettings/preferences')
          .get();

      if (prefs.exists) {
        print('✅ Preferencias encontradas:');
        print('   ${prefs.data()}');
      } else {
        print('⚠️ NO HAY PREFERENCIAS - Se crearán por defecto');
      }

      // 3. Crear notificación de prueba
      print('\n🔔 Creando notificación de prueba...');

      final notificationRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            'type': 'like',
            'title': '🧪 Test Notification',
            'body': 'Esta es una notificación de prueba del sistema',
            'senderId': 'test_sender_123',
            'relatedId': 'test_experience_456',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });

      print('✅ Notificación creada con ID: ${notificationRef.id}');
      print('📍 Ruta: users/$userId/notifications/${notificationRef.id}');
      print(
        '\n⏱️ Esperando 3 segundos para que se ejecute Cloud Function...\n',
      );

      await Future.delayed(Duration(seconds: 3));

      // 4. Verificar que la notificación se guardó
      final notification = await notificationRef.get();
      if (notification.exists) {
        print('✅ Notificación confirmada en Firestore:');
        print('   ${notification.data()}');
      }

      print('\n📊 SIGUIENTE PASO:');
      print('   1. Revisa los logs de Cloud Function con:');
      print('      firebase functions:log --only onNotificationCreated');
      print('   2. Si no hay logs, la Cloud Function NO se está ejecutando');
      print('   3. Si hay logs pero no llega push, verifica el token FCM');
    } catch (e) {
      print('❌ Error: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  /// Verificar configuración completa
  Future<void> checkConfiguration() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      print('❌ No hay usuario autenticado');
      return;
    }

    print('🔍 VERIFICACIÓN DE CONFIGURACIÓN\n');
    print('👤 Usuario: $userId');

    // 1. Tokens FCM
    final tokens = await _firestore
        .collection('users')
        .doc(userId)
        .collection('fcmTokens')
        .get();

    print('\n📱 TOKENS FCM:');
    if (tokens.docs.isEmpty) {
      print('   ❌ NO HAY TOKENS GUARDADOS');
      print(
        '   → Solución: Ejecutar NotificationService().reinitializeAfterLogin()',
      );
    } else {
      print('   ✅ ${tokens.docs.length} token(s) encontrado(s)');
      for (var token in tokens.docs) {
        print(
          '      • ${token.data()['platform']}: ${token.data()['token']?.substring(0, 30)}...',
        );
      }
    }

    // 2. Preferencias
    final prefs = await _firestore
        .doc('users/$userId/notificationSettings/preferences')
        .get();

    print('\n⚙️ PREFERENCIAS:');
    if (!prefs.exists) {
      print('   ❌ NO HAY PREFERENCIAS');
      print(
        '   → Solución: Ejecutar NotificationService()._ensureNotificationSettings()',
      );
    } else {
      print('   ✅ Preferencias configuradas:');
      final data = prefs.data() as Map<String, dynamic>;
      data.forEach((key, value) {
        if (key != 'createdAt' && key != 'updatedAt') {
          print('      • $key: $value');
        }
      });
    }

    // 3. Últimas notificaciones
    final notifications = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    print('\n📬 ÚLTIMAS NOTIFICACIONES:');
    if (notifications.docs.isEmpty) {
      print('   ℹ️ No hay notificaciones');
    } else {
      print('   ${notifications.docs.length} notificación(es) reciente(s):');
      for (var notif in notifications.docs) {
        final data = notif.data();
        print('      • [${data['type']}] ${data['title']}');
      }
    }

    print('\n✅ Verificación completa');
  }

  /// Forzar reinicialización de notificaciones
  Future<void> forceReinitialize() async {
    print('🔄 Forzando reinicialización...');
    // Aquí llamarías al método real del NotificationService
    print('⚠️ Debes ejecutar esto desde tu app:');
    print('   await NotificationService().reinitializeAfterLogin();');
  }
}
