import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/social/domain/entities/notification_entity.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Widget de lista de notificaciones
class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final l = Provider.of<LocaleNotifier>(context);

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
                  l
                      .t('unread_count')
                      .replaceAll('{n}', provider.unreadCount.toString()),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.markAllAsRead(),
                  child: Text(l.t('mark_all_read')),
                ),
              ],
            ),
          ),
        // Lista de notificaciones
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.notifications.isEmpty
              ? Center(
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
                        l.t('no_notifications'),
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
class NotificationItem extends StatefulWidget {
  final NotificationEntity notification;

  const NotificationItem({super.key, required this.notification});

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  bool _isProcessing = false;
  String? _actionResult; // 'accepted', 'rejected'

  @override
  Widget build(BuildContext context) {
    // Configurar locale español para timeago
    timeago.setLocaleMessages('es', timeago.EsMessages());

    final provider = context.read<NotificationsProvider>();
    final l = Provider.of<LocaleNotifier>(context);

    final isFollowRequest =
        widget.notification.type == NotificationType.followRequest;

    return Dismissible(
      key: Key(widget.notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        provider.deleteNotification(widget.notification.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.t('notification_deleted'))));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: widget.notification.fromUserPhoto != null
              ? NetworkImage(widget.notification.fromUserPhoto!)
              : null,
          backgroundColor: widget.notification.isRead
              ? Colors.grey[300]
              : Theme.of(context).primaryColor,
          child: widget.notification.fromUserPhoto == null
              ? Icon(
                  _getIcon(),
                  color: widget.notification.isRead
                      ? Colors.grey
                      : Colors.white,
                )
              : null,
        ),
        title: Text(
          widget.notification.message,
          style: TextStyle(
            fontWeight: widget.notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            color: widget.notification.isRead
                ? null
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.notification.targetPreview != null)
              Text(
                widget.notification.targetPreview!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            Text(
              timeago.format(widget.notification.createdAt, locale: 'es'),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            // Botones de aceptar/denegar para solicitudes de seguimiento
            if (isFollowRequest && _actionResult == null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _handleAccept(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16242D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Permitir',
                                style: TextStyle(fontSize: 13),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _handleReject(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Denegar',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_actionResult == 'accepted')
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  l.t('request_accepted'),
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (_actionResult == 'rejected')
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  l.t('request_denied'),
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        tileColor: widget.notification.isRead
            ? null
            : Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.blue[50],
        onTap: () {
          // Marcar como leída
          if (!widget.notification.isRead) {
            provider.markAsRead(widget.notification.id);
          }

          // Navegar al contenido relacionado (no navegar si es follow_request)
          if (!isFollowRequest) {
            _navigateToTarget(context);
          }
        },
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    setState(() => _isProcessing = true);

    try {
      final profileProvider = context.read<UserProfileProvider>();
      final success = await profileProvider.acceptFollowRequest(
        widget.notification.fromUserId,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _actionResult = success ? 'accepted' : null;
        });

        if (success) {
          // Marcar la notificación como leída
          context.read<NotificationsProvider>().markAsRead(
            widget.notification.id,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.t('error_accepting_request'))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('error_accepting_request'))),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    setState(() => _isProcessing = true);

    try {
      final profileProvider = context.read<UserProfileProvider>();
      final success = await profileProvider.rejectFollowRequest(
        widget.notification.fromUserId,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _actionResult = success ? 'rejected' : null;
        });

        if (success) {
          // Marcar la notificación como leída
          context.read<NotificationsProvider>().markAsRead(
            widget.notification.id,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.t('error_denying_request'))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('error_denying_request'))),
        );
      }
    }
  }

  IconData _getIcon() {
    switch (widget.notification.type) {
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
      case NotificationType.followRequest:
        return Icons.person_add_alt_1;
    }
  }

  void _navigateToTarget(BuildContext context) {
    if (widget.notification.targetType == null ||
        widget.notification.targetId == null) {
      // Para follow/followRequest, navegar al perfil del remitente
      if (widget.notification.type == NotificationType.follow ||
          widget.notification.type == NotificationType.followRequest) {
        context.push('/user-profile/${widget.notification.fromUserId}');
      }
      return;
    }

    switch (widget.notification.type) {
      // LIKES - Navegar al contenido específico
      case NotificationType.likePost:
        // Para posts, ir al detalle del post
        context.push('/post-detail/${widget.notification.targetId}');
        break;

      case NotificationType.likeComment:
        // Para likes en comentarios, usar el contexto guardado en metadata
        final contextType =
            widget.notification.metadata?['contextType'] as String?;
        final contextTargetId =
            widget.notification.metadata?['contextTargetId'] as String?;

        if (contextType == 'post' && contextTargetId != null) {
          // Navegar a los comentarios del post
          final postOwnerId =
              widget.notification.metadata?['postOwnerId'] ??
              widget.notification.fromUserId;
          context.push('/posts/$contextTargetId/comments?ownerId=$postOwnerId');
        } else if (contextType == 'ride' && contextTargetId != null) {
          // Navegar al detalle de la rodada con comentarios abiertos
          context.push(
            '/rides/$contextTargetId',
            extra: {'openComments': true},
          );
        } else {
          // Fallback: usar targetType si no hay metadata
          if (widget.notification.targetType == NotificationTargetType.post) {
            final postOwnerId =
                widget.notification.metadata?['postOwnerId'] ??
                widget.notification.fromUserId;
            context.push(
              '/posts/${widget.notification.targetId}/comments?ownerId=$postOwnerId',
            );
          } else if (widget.notification.targetType ==
              NotificationTargetType.ride) {
            context.push(
              '/rides/${widget.notification.targetId}',
              extra: {'openComments': true},
            );
          }
        }
        break;

      case NotificationType.likeStory:
        // Las historias navegan al perfil del creador
        context.push('/user-profile/${widget.notification.fromUserId}');
        break;

      // COMENTARIOS - Navegar directamente a la sección de comentarios
      case NotificationType.commentPost:
        // Para comentarios en posts, ir al detalle del post
        context.push('/post-detail/${widget.notification.targetId}');
        break;

      case NotificationType.commentRide:
        context.push(
          '/rides/${widget.notification.targetId}',
          extra: {'openComments': true},
        );
        break;

      case NotificationType.replyComment:
        // Para respuestas, ir directamente a comentarios
        if (widget.notification.targetType == NotificationTargetType.post) {
          final postOwnerId2 =
              widget.notification.metadata?['postOwnerId'] ??
              widget.notification.fromUserId;
          context.push(
            '/posts/${widget.notification.targetId}/comments?ownerId=$postOwnerId2',
          );
        } else if (widget.notification.targetType ==
            NotificationTargetType.ride) {
          context.push(
            '/rides/${widget.notification.targetId}',
            extra: {'openComments': true},
          );
        }
        break;

      // RODADAS - Navegar a detalle de rodada
      case NotificationType.rideJoin:
        context.push('/rides/${widget.notification.targetId}');
        break;

      // MENCIONES - Navegar según el contexto
      case NotificationType.mention:
        if (widget.notification.targetType == NotificationTargetType.post) {
          final postOwnerId3 =
              widget.notification.metadata?['postOwnerId'] ??
              widget.notification.fromUserId;
          context.push(
            '/posts/${widget.notification.targetId}/comments?ownerId=$postOwnerId3',
          );
        } else if (widget.notification.targetType ==
            NotificationTargetType.ride) {
          context.push(
            '/rides/${widget.notification.targetId}',
            extra: {'openComments': true},
          );
        } else {
          context.push('/user-profile/${widget.notification.fromUserId}');
        }
        break;

      // SEGUIMIENTO - Navegar al perfil del usuario
      case NotificationType.follow:
        context.push('/user-profile/${widget.notification.fromUserId}');
        break;

      // SOLICITUD DE SEGUIMIENTO - No navegar (se maneja con botones)
      case NotificationType.followRequest:
        context.push('/user-profile/${widget.notification.fromUserId}');
        break;
    }
  }
}
