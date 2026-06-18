import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio para enviar notificaciones de bienvenida a nuevos usuarios
class WelcomeNotificationService {
  static final WelcomeNotificationService _instance =
      WelcomeNotificationService._internal();

  factory WelcomeNotificationService() {
    return _instance;
  }

  WelcomeNotificationService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _biuxBotId = 'BIUX_SYSTEM'; // ID del sistema BIUX

  /// Envía un mensaje de bienvenida al nuevo usuario
  /// Espera a que el usuario esté autenticado en Firebase si es necesario
  Future<void> sendWelcomeMessage(String userId, String userName) async {
    try {
      // Si el userName está vacío, usar un valor por defecto
      final displayName = userName.isEmpty ? 'Ciclista' : userName;

      AppLogger.info(
        'Enviando notificación de bienvenida a: $userId',
        tag: 'WelcomeNotification',
      );

      // Esperar a que el usuario esté autenticado en Firebase (máximo 10 segundos)
      String targetUserId = userId;
      final stopwatch = Stopwatch()..start();

      while (stopwatch.elapsedMilliseconds < 10000) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          targetUserId = currentUser.uid;
          AppLogger.info(
            'Usuario autenticado en Firebase: $targetUserId',
            tag: 'WelcomeNotification',
          );
          break;
        }
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Crear notificación en Firebase Realtime Database
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final notificationId =
          _database.ref().push().key ?? DateTime.now().toString();

      final notificationData = {
        'id': notificationId, // Campo requerido
        'type': 'welcome',
        'fromUserId': _biuxBotId,
        'fromUserName': 'BIUX',
        'fromUserPhoto': '',
        'message': '¡Bienvenido a BIUX!',
        'title': '¡Hola $displayName! 🚴‍♂️',
        'body': _buildWelcomeMessage(displayName),
        'isRead': false,
        'createdAt': timestamp, // Campo requerido por las reglas
        'timestamp': timestamp, // Campo adicional por compatibilidad
        'metadata': {
          'actionUrl': '/complete-profile',
          'actionLabel': 'Completar Perfil',
          'priority': 'high',
        },
      };

      AppLogger.info(
        'Guardando notificación en: notifications/$targetUserId/$notificationId',
        tag: 'WelcomeNotification',
      );

      await _database
          .ref('notifications/$targetUserId/$notificationId')
          .set(notificationData);

      AppLogger.info(
        'Notificación de bienvenida enviada exitosamente a: $targetUserId',
        tag: 'WelcomeNotification',
      );
    } catch (e) {
      AppLogger.error(
        'Error enviando notificación de bienvenida: $e',
        tag: 'WelcomeNotification',
        error: e,
      );
    }
  }

  /// Construye el mensaje de bienvenida personalizado
  String _buildWelcomeMessage(String userName) {
    return '''¡Hola $userName! 👋

Te damos la bienvenida a BIUX, la comunidad de ciclistas más activa.

🎯 Próximos pasos:

1️⃣ **Completa tu perfil** - Agrega una foto y describe quién eres
   Esta información ayuda a otros ciclistas a conocerte mejor

2️⃣ **Registra tu bicicleta** - Protégela con nuestro sistema anti-robo
   Accede desde el menú: Mis Bicis > Registrar Bicicleta

3️⃣ **Únete a un grupo** - Conecta con ciclistas de tu ciudad
   Explora: Grupos > Buscar por ciudad

4️⃣ **Crea tu primera rodada** - Organiza una salida en bici
   Invita amigos y disfruta del ciclismo en comunidad

💡 Consejos:
• Revisa el mapa para ver rodadas cerca de ti
• Activa notificaciones para no perder ninguna actividad
• Lee nuestros tips de seguridad en la sección Aprendizaje

¿Preguntas? Contáctanos desde Ayuda > Centro de Soporte

¡A pedalear! 🚴‍♀️🚴‍♂️''';
  }

  /// Envía una notificación de prueba al usuario autenticado actual
  /// Útil para testear la bandeja de mensajes sin necesidad de registrarse
  Future<void> sendTestWelcomeMessage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        AppLogger.warning(
          'No se pudo enviar notificación de prueba: usuario no autenticado',
          tag: 'WelcomeNotification',
        );
        return;
      }

      AppLogger.info(
        'Enviando notificación de prueba a: ${currentUser.uid}',
        tag: 'WelcomeNotification',
      );

      await sendWelcomeMessage(currentUser.uid, '');
    } catch (e) {
      AppLogger.error(
        'Error enviando notificación de prueba',
        tag: 'WelcomeNotification',
        error: e,
      );
    }
  }
}
