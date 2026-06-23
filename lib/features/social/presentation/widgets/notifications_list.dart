import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/social/domain/entities/notification_entity.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

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
  bool _isProcessing = false;
  String? _actionResult; // 'accepted', 'rejected'

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  @override
  Widget build(BuildContext context) {
    // Selector: solo reconstruye si esta notificación específica cambió
    final notification = context
        .select<NotificationsProvider, NotificationEntity>(
          (provider) => provider.notifications.firstWhere(
            (n) => n.id == widget.notification.id,
            orElse: () => widget.notification,
          ),
        );
    final l = Provider.of<LocaleNotifier>(context);

    final isFollowRequest = notification.type == NotificationType.followRequest;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  Provider.of<LocaleNotifier>(
                    context,
                    listen: false,
                  ).t('delete_notification_confirm'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                      Provider.of<LocaleNotifier>(
                        context,
                        listen: false,
                      ).t('cancel'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(
                      Provider.of<LocaleNotifier>(
                        context,
                        listen: false,
                      ).t('delete'),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        context.read<NotificationsProvider>().deleteNotification(
          notification.id,
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              notification.fromUserPhoto != null &&
                  notification.fromUserPhoto!.isNotEmpty
              ? NetworkImage(notification.fromUserPhoto!)
              : (notification.fromUserId == 'BIUX_SYSTEM'
                    ? const AssetImage('img/biux_logo_background_blue.png')
                    : null),
          backgroundColor: notification.isRead
              ? Colors.grey[300]
              : Theme.of(context).primaryColor,
          child:
              (notification.fromUserPhoto == null ||
                      notification.fromUserPhoto!.isEmpty) &&
                  notification.fromUserId != 'BIUX_SYSTEM'
              ? Icon(
                  _getIconForType(notification.type),
                  color: notification.isRead ? Colors.grey : Colors.white,
                )
              : null,
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            color: notification.isRead
                ? null
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : null,
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
                          backgroundColor: ColorTokens.primary30,
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
                        child: Text(Provider.of<LocaleNotifier>(context, listen: false).t('deny'), style: const TextStyle(fontSize: 13)),
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
        tileColor: notification.isRead
            ? null
            : Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.blue[50],
        onTap: () {
          // Marcar como leída
          if (!notification.isRead) {
            context.read<NotificationsProvider>().markAsRead(notification.id);
          }

          // Navegar al contenido relacionado (no navegar si es follow_request)
          if (!isFollowRequest) {
            _navigateToTarget(context, notification);
          }
        },
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    setState(() => _isProcessing = true);

    final notificationsProvider = context.read<NotificationsProvider>();
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final isLocalNotification = notificationsProvider.isLocalNotification(
      widget.notification.id,
    );

    try {
      bool success = true;

      // Solo llamar a Firebase si no es una notificación local de prueba
      if (!isLocalNotification) {
        final profileProvider = context.read<UserProfileProvider>();
        success = await profileProvider.acceptFollowRequest(
          widget.notification.fromUserId,
        );
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _actionResult = success ? 'accepted' : null;
        });

        if (success) {
          // Actualizar la notificación para mostrar que ahora te sigue
          notificationsProvider.updateLocalNotification(
            widget.notification.id,
            message: '${widget.notification.fromUserName} empezó a seguirte',
            type: NotificationType.follow,
            isRead: true,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.t('error_accepting_request'))),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.t('error_accepting_request'))));
      }
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    setState(() => _isProcessing = true);

    final notificationsProvider = context.read<NotificationsProvider>();
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final isLocalNotification = notificationsProvider.isLocalNotification(
      widget.notification.id,
    );

    try {
      bool success = true;

      // Solo llamar a Firebase si no es una notificación local de prueba
      if (!isLocalNotification) {
        final profileProvider = context.read<UserProfileProvider>();
        success = await profileProvider.rejectFollowRequest(
          widget.notification.fromUserId,
        );
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _actionResult = success ? 'rejected' : null;
        });

        if (success) {
          // Actualizar la notificación para mostrar que se denegó
          notificationsProvider.updateLocalNotification(
            widget.notification.id,
            message:
                'Denegaste la solicitud de ${widget.notification.fromUserName}',
            isRead: true,
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.t('error_denying_request'))));
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.t('error_denying_request'))));
      }
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
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

  void _navigateToTarget(
    BuildContext context,
    NotificationEntity notification,
  ) {
    if (notification.targetType == null || notification.targetId == null) {
      // Para follow/followRequest, navegar al perfil del remitente
      if (notification.type == NotificationType.follow ||
          notification.type == NotificationType.followRequest) {
        context.push(AppRoutes.userProfilePath(notification.fromUserId));
      }
      return;
    }

    switch (notification.type) {
      // LIKES - Navegar al contenido específico
      case NotificationType.likePost:
        context.push(AppRoutes.postDetailPath(notification.targetId!));
        break;

      case NotificationType.likeComment:
        final contextType = notification.metadata?['contextType'] as String?;
        final contextTargetId =
            notification.metadata?['contextTargetId'] as String?;

        if (contextType == 'post' && contextTargetId != null) {
          final postOwnerId =
              notification.metadata?['postOwnerId'] ?? notification.fromUserId;
          context.push(
            AppRoutes.postCommentsPath(contextTargetId, ownerId: postOwnerId),
          );
        } else if (contextType == 'ride' && contextTargetId != null) {
          context.push(
            AppRoutes.rideDetailPath(contextTargetId),
            extra: {'openComments': true},
          );
        } else {
          if (notification.targetType == NotificationTargetType.post) {
            final postOwnerId =
                notification.metadata?['postOwnerId'] ??
                notification.fromUserId;
            context.push(
              AppRoutes.postCommentsPath(
                notification.targetId!,
                ownerId: postOwnerId,
              ),
            );
          } else if (notification.targetType == NotificationTargetType.ride) {
            context.push(
              AppRoutes.rideDetailPath(notification.targetId!),
              extra: {'openComments': true},
            );
          }
        }
        break;

      case NotificationType.likeStory:
        context.push(AppRoutes.userProfilePath(notification.fromUserId));
        break;

      // COMENTARIOS
      case NotificationType.commentPost:
        context.push(AppRoutes.postDetailPath(notification.targetId!));
        break;

      case NotificationType.commentRide:
        context.push(
          AppRoutes.rideDetailPath(notification.targetId!),
          extra: {'openComments': true},
        );
        break;

      case NotificationType.replyComment:
        if (notification.targetType == NotificationTargetType.post) {
          final postOwnerId2 =
              notification.metadata?['postOwnerId'] ?? notification.fromUserId;
          context.push(
            AppRoutes.postCommentsPath(
              notification.targetId!,
              ownerId: postOwnerId2,
            ),
          );
        } else if (notification.targetType == NotificationTargetType.ride) {
          context.push(
            AppRoutes.rideDetailPath(notification.targetId!),
            extra: {'openComments': true},
          );
        }
        break;

      // RODADAS
      case NotificationType.rideJoin:
        context.push(AppRoutes.rideDetailPath(notification.targetId!));
        break;

      // MENCIONES
      case NotificationType.mention:
        if (notification.targetType == NotificationTargetType.post) {
          final postOwnerId3 =
              notification.metadata?['postOwnerId'] ?? notification.fromUserId;
          context.push(
            AppRoutes.postCommentsPath(
              notification.targetId!,
              ownerId: postOwnerId3,
            ),
          );
        } else if (notification.targetType == NotificationTargetType.ride) {
          context.push(
            AppRoutes.rideDetailPath(notification.targetId!),
            extra: {'openComments': true},
          );
        } else {
          context.push(AppRoutes.userProfilePath(notification.fromUserId));
        }
        break;

      // SEGUIMIENTO
      case NotificationType.follow:
        context.push(AppRoutes.userProfilePath(notification.fromUserId));
        break;

      // SOLICITUD DE SEGUIMIENTO
      case NotificationType.followRequest:
        context.push(AppRoutes.userProfilePath(notification.fromUserId));
        break;
    }
  }
}
