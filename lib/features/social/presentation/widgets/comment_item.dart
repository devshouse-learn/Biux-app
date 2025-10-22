import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../providers/comments_provider.dart';
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
              // Avatar del usuario
              UserAvatar(
                userName: comment.userName,
                photoUrl: comment.userPhoto,
                radius: isReply ? 16 : 20,
              ),
              const SizedBox(width: 8),
              // Contenido del comentario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y tiempo
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(comment.createdAt, locale: 'es'),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (comment.isEdited)
                          Text(
                            ' (editado)',
                            style: TextStyle(
                              color: Colors.grey[600],
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
                        color: comment.isDeleted ? Colors.grey : Colors.black,
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
                          // Botón de like (puedes usar el LikeButton widget aquí)
                          InkWell(
                            onTap: () {
                              // Implementar like de comentario
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.favorite_border, size: 16),
                                if (comment.likesCount > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    comment.likesCount.toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
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
    // Implementar campo de respuesta
    // Puede ser un showModalBottomSheet o inline
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
              if (context.mounted) Navigator.pop(context);
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
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
