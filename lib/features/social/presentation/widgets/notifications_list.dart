import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notifications_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

/// Widget de lista de notificaciones
class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();

    return Column(
      children: [
        // Header con acciones
        if (provider.notifications.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${provider.unreadCount} sin leer',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.markAllAsRead(),
                  child: const Text('Marcar todas como leídas'),
                ),
              ],
            ),
          ),
        // Lista de notificaciones
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tienes notificaciones',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: provider.notifications.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return NotificationItem(
                      notification: provider.notifications[index],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Widget de elemento de notificación individual
class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // Configurar locale español para timeago
    timeago.setLocaleMessages('es', timeago.EsMessages());

    final provider = context.read<NotificationsProvider>();

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notificación eliminada')));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: notification.fromUserPhoto != null
              ? NetworkImage(notification.fromUserPhoto!)
              : null,
          backgroundColor: notification.isRead
              ? Colors.grey[300]
              : Theme.of(context).primaryColor.withOpacity(0.1),
          child: notification.fromUserPhoto == null
              ? Icon(
                  _getIcon(),
                  color: notification.isRead
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                )
              : null,
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.targetPreview != null)
              Text(
                notification.targetPreview!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            Text(
              timeago.format(notification.createdAt, locale: 'es'),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        tileColor: notification.isRead ? null : Colors.blue[50],
        onTap: () {
          // Marcar como leída
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }

          // Navegar al contenido relacionado
          _navigateToTarget(context);
        },
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.likePost:
      case NotificationType.likeComment:
      case NotificationType.likeStory:
        return Icons.favorite;
      case NotificationType.commentPost:
      case NotificationType.commentRide:
      case NotificationType.replyComment:
        return Icons.comment;
      case NotificationType.rideJoin:
        return Icons.directions_bike;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.follow:
        return Icons.person_add;
    }
  }

  void _navigateToTarget(BuildContext context) {
    if (notification.targetType == null || notification.targetId == null) {
      return;
    }

    switch (notification.type) {
      // LIKES - Navegar al contenido específico
      case NotificationType.likePost:
        // Para posts, ir directamente a los comentarios
        final postOwnerId =
            notification.metadata?['postOwnerId'] ?? notification.fromUserId;
        context.push(
          '/posts/${notification.targetId}/comments?ownerId=$postOwnerId',
        );
        break;

      case NotificationType.likeComment:
        // Para likes en comentarios, usar el contexto guardado en metadata
        final contextType = notification.metadata?['contextType'] as String?;
        final contextTargetId =
            notification.metadata?['contextTargetId'] as String?;

        if (contextType == 'post' && contextTargetId != null) {
          // Navegar a los comentarios del post
          final postOwnerId =
              notification.metadata?['postOwnerId'] ?? notification.fromUserId;
          context.push('/posts/$contextTargetId/comments?ownerId=$postOwnerId');
        } else if (contextType == 'ride' && contextTargetId != null) {
          // Navegar al detalle de la rodada con comentarios abiertos
          context.push(
            '/rides/$contextTargetId',
            extra: {'openComments': true},
          );
        } else {
          // Fallback: usar targetType si no hay metadata
          if (notification.targetType == NotificationTargetType.post) {
            final postOwnerId =
                notification.metadata?['postOwnerId'] ??
                notification.fromUserId;
            context.push(
              '/posts/${notification.targetId}/comments?ownerId=$postOwnerId',
            );
          } else if (notification.targetType == NotificationTargetType.ride) {
            context.push(
              '/rides/${notification.targetId}',
              extra: {'openComments': true},
            );
          }
        }
        break;

      case NotificationType.likeStory:
        // Las historias navegan al perfil del creador
        context.push('/user-profile/${notification.fromUserId}');
        break;

      // COMENTARIOS - Navegar directamente a la sección de comentarios
      case NotificationType.commentPost:
        final postOwnerId1 =
            notification.metadata?['postOwnerId'] ?? notification.fromUserId;
        context.push(
          '/posts/${notification.targetId}/comments?ownerId=$postOwnerId1',
        );
        break;

      case NotificationType.commentRide:
        context.push(
          '/rides/${notification.targetId}',
          extra: {'openComments': true},
        );
        break;

      case NotificationType.replyComment:
        // Para respuestas, ir directamente a comentarios
        if (notification.targetType == NotificationTargetType.post) {
          final postOwnerId2 =
              notification.metadata?['postOwnerId'] ?? notification.fromUserId;
          context.push(
            '/posts/${notification.targetId}/comments?ownerId=$postOwnerId2',
          );
        } else if (notification.targetType == NotificationTargetType.ride) {
          context.push(
            '/rides/${notification.targetId}',
            extra: {'openComments': true},
          );
        }
        break;

      // RODADAS - Navegar a detalle de rodada
      case NotificationType.rideJoin:
        context.push('/rides/${notification.targetId}');
        break;

      // MENCIONES - Navegar según el contexto
      case NotificationType.mention:
        if (notification.targetType == NotificationTargetType.post) {
          final postOwnerId3 =
              notification.metadata?['postOwnerId'] ?? notification.fromUserId;
          context.push(
            '/posts/${notification.targetId}/comments?ownerId=$postOwnerId3',
          );
        } else if (notification.targetType == NotificationTargetType.ride) {
          context.push(
            '/rides/${notification.targetId}',
            extra: {'openComments': true},
          );
        } else {
          context.push('/user-profile/${notification.fromUserId}');
        }
        break;

      // SEGUIMIENTO - Navegar al perfil del usuario
      case NotificationType.follow:
        context.push('/user-profile/${notification.fromUserId}');
        break;
    }
  }
}
