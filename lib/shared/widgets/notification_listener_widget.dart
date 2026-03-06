import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/shared/services/notification_service.dart';

/// Widget que escucha las notificaciones push y navega según el tipo
class BiuxNotificationListener extends StatefulWidget {
  final Widget child;

  const BiuxNotificationListener({super.key, required this.child});

  @override
  State<BiuxNotificationListener> createState() =>
      _BiuxNotificationListenerState();
}

class _BiuxNotificationListenerState extends State<BiuxNotificationListener> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    // Escuchar notificaciones
    _notificationService.notificationStream.listen((data) {
      if (!mounted) return;

      final isOpened = data['opened'] == true;
      if (!isOpened) {
        // Notificación recibida pero no tocada - mostrar snackbar
        try {
          _showNotificationSnackbar(data);
        } catch (e) {
          debugPrint('⚠️ Error mostrando snackbar de notificación: $e');
        }
      } else {
        // Notificación tocada - navegar
        _handleNotificationTap(data);
      }
    });
  }

  void _showNotificationSnackbar(Map<String, dynamic> data) {
    if (!mounted) return;

    final title = data['title'] ?? 'Nueva notificación';
    final body = data['body'] ?? '';

    // Verificar que existe un ScaffoldMessenger
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) {
      debugPrint('⚠️ No hay ScaffoldMessenger disponible para mostrar notificación');
      return;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => _handleNotificationTap(data),
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final targetId = data['targetId'] as String?;
    final targetType = data['targetType'] as String?;

    debugPrint('🔔 Navegando por notificación');
    debugPrint('   Type: $type');
    debugPrint('   TargetId: $targetId');
    debugPrint('   TargetType: $targetType');

    // Si no hay tipo, ir a lista de notificaciones
    if (type == null) {
      context.push('/notifications');
      return;
    }

    switch (type) {
      // Likes en posts
      case 'like_post':
        if (targetId != null) {
          context.push('/stories/post/$targetId');
        } else {
          context.push('/notifications');
        }
        break;

      // Comentarios en posts
      case 'comment_post':
        if (targetId != null) {
          context.push('/stories/post/$targetId');
        } else {
          context.push('/notifications');
        }
        break;

      // Likes en comentarios (ir al post/ride donde está el comentario)
      case 'like_comment':
        if (targetId != null) {
          // targetType puede ser 'post' o 'ride'
          if (targetType == 'post') {
            context.push('/stories/post/$targetId');
          } else if (targetType == 'ride') {
            context.push('/rides/$targetId');
          } else {
            context.push('/notifications');
          }
        } else {
          context.push('/notifications');
        }
        break;

      // Likes en rodadas
      case 'like_ride':
        if (targetId != null) {
          context.push('/rides/$targetId');
        } else {
          context.push('/notifications');
        }
        break;

      // Comentarios en rodadas
      case 'comment_ride':
        if (targetId != null) {
          context.push('/rides/$targetId');
        } else {
          context.push('/notifications');
        }
        break;

      // Seguir usuario
      case 'follow':
        final fromUserId = data['fromUserId'] as String?;
        if (fromUserId != null) {
          context.push('/users/$fromUserId');
        } else {
          context.push('/notifications');
        }
        break;

      // Invitaciones y recordatorios de rodadas
      case 'ride_invitation':
      case 'ride_reminder':
      case 'ride_update':
        if (targetId != null) {
          context.push('/rides/$targetId');
        } else {
          context.push('/notifications');
        }
        break;

      // Grupos
      case 'group_invitation':
      case 'group_update':
      case 'group_join_request':
        if (targetId != null) {
          context.push('/groups/$targetId');
        } else {
          context.push('/notifications');
        }
        break;

      // Historias
      case 'story':
        final fromUserId = data['fromUserId'] as String?;
        if (fromUserId != null) {
          context.push('/stories/$fromUserId');
        } else {
          context.push('/notifications');
        }
        break;

      // Notificaciones del sistema
      case 'system':
        context.push('/notifications');
        break;

      default:
        // Tipo desconocido, ir a notificaciones
        debugPrint('⚠️ Tipo de notificación desconocido: $type');
        context.push('/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
