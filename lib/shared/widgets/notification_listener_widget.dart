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
        _showNotificationSnackbar(data);
      } else {
        // Notificación tocada - navegar
        _handleNotificationTap(data);
      }
    });
  }

  void _showNotificationSnackbar(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Nueva notificación';
    final body = data['body'] ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
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
    final relatedId = data['relatedId'] as String?;

    print('🔔 Navegando por notificación - Type: $type, RelatedId: $relatedId');

    // Si no hay tipo o no hay relatedId, ir a lista de notificaciones
    if (type == null) {
      context.push('/notifications');
      return;
    }

    switch (type) {
      case 'like':
      case 'comment':
        // Navegar al post/experiencia
        if (relatedId != null) {
          context.push('/experiences/$relatedId');
        } else {
          context.push('/notifications');
        }
        break;

      case 'follow':
        // Navegar al perfil del seguidor
        final senderId = data['senderId'] as String?;
        if (senderId != null) {
          context.push('/users/$senderId');
        } else {
          context.push('/notifications');
        }
        break;

      case 'ride_invitation':
      case 'ride_reminder':
        // Navegar a la rodada
        if (relatedId != null) {
          context.push('/rides/$relatedId');
        } else {
          context.push('/notifications');
        }
        break;

      case 'group_invitation':
      case 'group_update':
      case 'group_join_request':
        // Navegar al grupo
        if (relatedId != null) {
          context.push('/groups/$relatedId');
        } else {
          context.push('/notifications');
        }
        break;

      case 'story':
        // Abrir historias del usuario
        final senderId = data['senderId'] as String?;
        if (senderId != null) {
          context.push('/stories/$senderId');
        } else {
          context.push('/notifications');
        }
        break;

      case 'system':
        // Notificaciones del sistema - ir a notificaciones
        context.push('/notifications');
        break;

      default:
        // Tipo desconocido, ir a notificaciones
        print('⚠️ Tipo de notificación desconocido: $type');
        context.push('/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
