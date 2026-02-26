import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../providers/comments_provider.dart';
import '../providers/likes_provider.dart';
import 'user_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget de elemento de comentario individual
class CommentItem extends StatelessWidget {
  final CommentEntity comment;
  final CommentableType type;
  final String targetId;
  final String targetOwnerId;
  final bool isReply;

  const CommentItem({
    super.key,
    required this.comment,
    required this.type,
    required this.targetId,
    required this.targetOwnerId,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    // Configurar locale español para timeago
    timeago.setLocaleMessages('es', timeago.EsMessages());

    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 40.0 : 8.0,
        right: 8.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar del usuario - clickeable para ir al perfil
              GestureDetector(
                onTap: () {
                  context.push('/user-profile/${comment.userId}');
                },
                child: UserAvatar(
                  userName: comment.userName,
                  photoUrl: comment.userPhoto,
                  radius: isReply ? 16 : 20,
                ),
              ),
              const SizedBox(width: 8),
              // Contenido del comentario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y tiempo - nombre clickeable
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              context.push('/user-profile/${comment.userId}');
                            },
                            child: Text(
                              comment.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            timeago.format(comment.createdAt, locale: 'es'),
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (comment.isEdited)
                          Text(
                            ' (editado)',
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Texto del comentario
                    Text(
                      comment.displayText,
                      style: TextStyle(
                        color: comment.isDeleted
                            ? theme.textTheme.bodyMedium?.color?.withValues(
                                alpha: 0.5,
                              )
                            : theme.textTheme.bodyMedium?.color,
                        fontStyle: comment.isDeleted
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Acciones (like, responder)
                    if (!comment.isDeleted)
                      Row(
                        children: [
                          // Botón de like con estado en tiempo real
                          Consumer<LikesProvider>(
                            builder: (context, likesProvider, _) {
                              return StreamBuilder<bool>(
                                stream: likesProvider.watchUserLikedComment(
                                  commentId: comment.id,
                                  contextTargetId: targetId,
                                  contextType: type,
                                ),
                                builder: (context, likeSnapshot) {
                                  final isLiked = likeSnapshot.data ?? false;

                                  return StreamBuilder<int>(
                                    stream: likesProvider
                                        .watchCommentLikesCount(
                                          commentId: comment.id,
                                          contextTargetId: targetId,
                                          contextType: type,
                                        ),
                                    builder: (context, countSnapshot) {
                                      final likesCount =
                                          countSnapshot.data ??
                                          comment.likesCount;

                                      return InkWell(
                                        onTap: () async {
                                          if (isLiked) {
                                            await likesProvider.unlikeComment(
                                              comment.id,
                                              contextTargetId: targetId,
                                              contextType: type,
                                            );
                                          } else {
                                            await likesProvider.likeComment(
                                              commentId: comment.id,
                                              commentOwnerId: comment.userId,
                                              contextTargetId:
                                                  targetId, // ID del post/ride
                                              contextType:
                                                  type, // Tipo: post o ride
                                            );
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              size: 16,
                                              color: isLiked
                                                  ? Colors.red
                                                  : theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color
                                                        ?.withValues(
                                                          alpha: 0.6,
                                                        ),
                                            ),
                                            if (likesCount > 0) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                likesCount.toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          // Botón de responder
                          if (!isReply)
                            InkWell(
                              onTap: () {
                                // Mostrar campo de respuesta
                                _showReplyField(context);
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.reply, size: 16),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Responder',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  if (comment.repliesCount > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${comment.repliesCount})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              // Menú de opciones (editar, eliminar)
              if (!comment.isDeleted) _buildOptionsMenu(context),
            ],
          ),
          // Mostrar respuestas si es un comentario principal
          if (!isReply && comment.repliesCount > 0) _buildReplies(context),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    final provider = context.read<CommentsProvider>();

    // Solo mostrar menú si el usuario es el autor
    if (comment.userId != provider.userId) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          _showEditDialog(context);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18),
              SizedBox(width: 8),
              Text('Eliminar'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplies(BuildContext context) {
    final provider = context.watch<CommentsProvider>();

    return StreamBuilder<List<CommentEntity>>(
      stream: provider.watchReplies(type, targetId, comment.id),
      builder: (context, snapshot) {
        final replies = snapshot.data ?? [];

        if (replies.isEmpty) return const SizedBox.shrink();

        return Column(
          children: replies.map((reply) {
            return CommentItem(
              comment: reply,
              type: type,
              targetId: targetId,
              targetOwnerId: targetOwnerId,
              isReply: true,
            );
          }).toList(),
        );
      },
    );
  }

  void _showReplyField(BuildContext context) {
    final controller = TextEditingController();
    final provider = context.read<CommentsProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Responder a ${comment.userName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escribe tu respuesta...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;

                    String? commentId;
                    if (type == CommentableType.post) {
                      commentId = await provider.commentOnPost(
                        postId: targetId,
                        postOwnerId: targetOwnerId,
                        text: controller.text,
                        parentCommentId: comment.id,
                        parentCommentOwnerId: comment.userId,
                      );
                    } else if (type == CommentableType.ride) {
                      commentId = await provider.commentOnRide(
                        rideId: targetId,
                        rideOwnerId: targetOwnerId,
                        text: controller.text,
                        parentCommentId: comment.id,
                        parentCommentOwnerId: comment.userId,
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      if (commentId != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Respuesta publicada'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Responder'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: comment.text);
    final provider = context.read<CommentsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: controller,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe tu comentario...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.editComment(
                type: type,
                targetId: targetId,
                commentId: comment.id,
                newText: controller.text,
              );
              if (context.mounted) {
                Navigator.pop(context);

                // Mostrar feedback basado en el resultado
                if (provider.error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comentario actualizado'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.error ?? 'Error al actualizar comentario',
                      ),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final provider = context.read<CommentsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este comentario?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteComment(
                type: type,
                targetId: targetId,
                commentId: comment.id,
              );
              if (context.mounted) {
                Navigator.pop(context);

                // Mostrar feedback basado en el resultado
                if (provider.error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comentario eliminado'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.error ?? 'Error al eliminar comentario',
                      ),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
