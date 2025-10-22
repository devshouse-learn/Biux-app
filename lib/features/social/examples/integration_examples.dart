import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Imports del sistema social
import 'package:biux/features/social/presentation/widgets/like_button.dart';
import 'package:biux/features/social/presentation/widgets/comments_list.dart';
import 'package:biux/features/social/presentation/widgets/attendees_list.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'package:biux/features/social/presentation/providers/comments_provider.dart';
import 'package:biux/features/social/presentation/providers/attendees_provider.dart';
import 'package:biux/features/social/domain/repositories/likes_repository.dart';
import 'package:biux/features/social/domain/repositories/comments_repository.dart';

/// ========================================
/// EJEMPLO 1: POST CARD CON LIKES Y COMENTARIOS
/// ========================================

class PostCardExample extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final String postContent;
  final String postImageUrl;

  const PostCardExample({
    super.key,
    required this.postId,
    required this.postOwnerId,
    required this.postContent,
    required this.postImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del post
          if (postImageUrl.isNotEmpty)
            Image.network(
              postImageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(postContent),
          ),

          // Divider
          const Divider(height: 1),

          // Barra de acciones: like, comentar, compartir
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Botón de like con contador
                LikeButton(
                  type: LikeableType.post,
                  targetId: postId,
                  targetOwnerId: postOwnerId,
                  targetPreview: postContent,
                  showCount: true,
                  activeColor: Colors.red,
                ),

                const SizedBox(width: 8),

                // Botón de comentarios con contador
                _CommentsButton(
                  postId: postId,
                  postOwnerId: postOwnerId,
                ),

                const Spacer(),

                // Botón de compartir
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Implementar compartir
                  },
                ),
              ],
            ),
          ),

          // Vista previa de comentarios (opcional)
          _CommentsPreview(
            postId: postId,
            postOwnerId: postOwnerId,
          ),
        ],
      ),
    );
  }
}

class _CommentsButton extends StatelessWidget {
  final String postId;
  final String postOwnerId;

  const _CommentsButton({
    required this.postId,
    required this.postOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentsProvider>();

    return StreamBuilder<int>(
      stream: provider.watchCommentsCount(CommentableType.post, postId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return InkWell(
          onTap: () {
            context.push('/posts/$postId/comments?ownerId=$postOwnerId');
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.comment_outlined, size: 24),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Text('$count'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentsPreview extends StatelessWidget {
  final String postId;
  final String postOwnerId;

  const _CommentsPreview({
    required this.postId,
    required this.postOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentsProvider>();

    return StreamBuilder<List<dynamic>>(
      stream: provider.watchComments(CommentableType.post, postId),
      builder: (context, snapshot) {
        final comments = snapshot.data ?? [];

        if (comments.isEmpty) return const SizedBox.shrink();

        // Mostrar solo los primeros 2 comentarios
        final previewComments = comments.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            ...previewComments.map((comment) => ListTile(
                  dense: true,
                  title: Text(
                    comment.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    comment.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            if (comments.length > 2)
              TextButton(
                onPressed: () {
                  context.push('/posts/$postId/comments?ownerId=$postOwnerId');
                },
                child: Text('Ver los ${comments.length} comentarios'),
              ),
          ],
        );
      },
    );
  }
}

/// ========================================
/// EJEMPLO 2: RODADA CARD CON ASISTENTES
/// ========================================

class RideCardExample extends StatelessWidget {
  final String rideId;
  final String rideOwnerId;
  final String rideTitle;
  final String rideDescription;
  final String rideDate;
  final String rideLocation;

  const RideCardExample({
    super.key,
    required this.rideId,
    required this.rideOwnerId,
    required this.rideTitle,
    required this.rideDescription,
    required this.rideDate,
    required this.rideLocation,
  });

  @override
  Widget build(BuildContext context) {
    final attendeesProvider = context.watch<AttendeesProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la rodada
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rideTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(rideDescription),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(rideDate),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(rideLocation),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Asistentes
          StreamBuilder<int>(
            stream: attendeesProvider.watchConfirmedCount(rideId),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return ListTile(
                leading: const Icon(Icons.people),
                title: Text('$count asistentes confirmados'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/rides/$rideId/attendees?ownerId=$rideOwnerId');
                },
              );
            },
          ),

          const Divider(height: 1),

          // Botón de unirse
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<bool>(
              stream: attendeesProvider.watchUserIsAttending(rideId),
              builder: (context, snapshot) {
                final isAttending = snapshot.data ?? false;

                if (isAttending) {
                  return StreamBuilder<dynamic>(
                    stream: attendeesProvider.watchUserStatus(rideId),
                    builder: (context, statusSnapshot) {
                      final status = statusSnapshot.data;

                      return Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Estás asistiendo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {
                              _showStatusMenu(context, attendeesProvider);
                            },
                            child: const Text('Cambiar'),
                          ),
                        ],
                      );
                    },
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await attendeesProvider.joinRide(
                        rideId: rideId,
                        rideOwnerId: rideOwnerId,
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Unirme a la rodada'),
                  ),
                );
              },
            ),
          ),

          // Comentarios
          const Divider(height: 1),
          _RideCommentsButton(
            rideId: rideId,
            rideOwnerId: rideOwnerId,
          ),
        ],
      ),
    );
  }

  void _showStatusMenu(BuildContext context, dynamic provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Salir de la rodada'),
            onTap: () async {
              await provider.leaveRide(rideId);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _RideCommentsButton extends StatelessWidget {
  final String rideId;
  final String rideOwnerId;

  const _RideCommentsButton({
    required this.rideId,
    required this.rideOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentsProvider>();

    return StreamBuilder<int>(
      stream: provider.watchCommentsCount(CommentableType.ride, rideId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return ListTile(
          leading: const Icon(Icons.comment),
          title: Text('$count comentarios'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/rides/$rideId/comments?ownerId=$rideOwnerId');
          },
        );
      },
    );
  }
}

/// ========================================
/// EJEMPLO 3: NAVIGATION BAR CON BADGE DE NOTIFICACIONES
/// ========================================

class NavigationBarWithNotifications extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavigationBarWithNotifications({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: 'Publicar',
        ),
        // Notificaciones con badge
        BottomNavigationBarItem(
          icon: Consumer<NotificationsProvider>(
            builder: (context, provider, child) {
              return Badge(
                label: Text('${provider.unreadCount}'),
                isLabelVisible: provider.hasUnread,
                backgroundColor: Colors.red,
                child: const Icon(Icons.notifications),
              );
            },
          ),
          label: 'Notificaciones',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}

/// ========================================
/// EJEMPLO 4: HISTORIA CON LIKE
/// ========================================

class StoryViewerExample extends StatelessWidget {
  final String storyId;
  final String storyOwnerId;
  final String storyImageUrl;

  const StoryViewerExample({
    super.key,
    required this.storyId,
    required this.storyOwnerId,
    required this.storyImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de la historia
        Positioned.fill(
          child: Image.network(
            storyImageUrl,
            fit: BoxFit.cover,
          ),
        ),

        // Botón de like en la parte inferior
        Positioned(
          bottom: 100,
          left: 20,
          child: LikeButton(
            type: LikeableType.story,
            targetId: storyId,
            targetOwnerId: storyOwnerId,
            showCount: true,
            activeColor: Colors.pink,
            inactiveColor: Colors.white,
            size: 32.0,
          ),
        ),
      ],
    );
  }
}
