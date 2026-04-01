import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:go_router/go_router.dart';
import '../providers/comments_provider.dart';
import '../widgets/like_button.dart';
import '../widgets/bookmark_button.dart';
import '../../domain/repositories/likes_repository.dart';
import '../../domain/repositories/comments_repository.dart';

/// Widget que muestra las acciones sociales para un post/experiencia
/// (Likes y Comentarios)
class PostSocialActions extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final String? postPreview; // Texto o descripción corta del post
  final VoidCallback? onRepost;

  const PostSocialActions({
    super.key,
    required this.postId,
    required this.postOwnerId,
    this.postPreview,
    this.onRepost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Botón de like con contador
          LikeButton(
            type: LikeableType.post,
            targetId: postId,
            targetOwnerId: postOwnerId,
            targetPreview: postPreview,
            showCount: true,
            activeColor: Colors.red,
            inactiveColor: theme.iconTheme.color ?? Colors.grey,
          ),

          const SizedBox(width: 16),

          // Botón de comentarios
          _CommentsButton(postId: postId, postOwnerId: postOwnerId),

          if (onRepost != null) ...[
            const SizedBox(width: 16),
            InkWell(
              onTap: onRepost,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  Icons.repeat_rounded,
                  size: 24,
                  color: theme.iconTheme.color ?? Colors.grey,
                ),
              ),
            ),
          ],

          const Spacer(),

          // Botón de guardar/bookmark
          BookmarkButton(
            postId: postId,
            size: 24,
            inactiveColor: theme.iconTheme.color ?? Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _CommentsButton extends StatelessWidget {
  final String postId;
  final String postOwnerId;

  const _CommentsButton({required this.postId, required this.postOwnerId});

  @override
  Widget build(BuildContext context) {
    final commentsProvider = context.watch<CommentsProvider>();

    return StreamBuilder<int>(
      stream: commentsProvider.watchCommentsCount(CommentableType.post, postId),
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
                  Text('$count', style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget que muestra una vista previa de comentarios
class PostCommentsPreview extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final int maxComments; // Número máximo de comentarios a mostrar

  const PostCommentsPreview({
    super.key,
    required this.postId,
    required this.postOwnerId,
    this.maxComments = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsProvider = context.watch<CommentsProvider>();

    return StreamBuilder<List<dynamic>>(
      stream: commentsProvider.watchComments(CommentableType.post, postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final comments = snapshot.data ?? [];
        if (comments.isEmpty) {
          return const SizedBox.shrink();
        }

        final previewComments = comments.take(maxComments).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            ...previewComments.map(
              (comment) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.userName} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      TextSpan(
                        text: comment.text,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (comments.length > maxComments)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Builder(
                  builder: (context) {
                    final l = Provider.of<LocaleNotifier>(context);
                    return TextButton(
                      onPressed: () {
                        context.push(
                          '/posts/$postId/comments?ownerId=$postOwnerId',
                        );
                      },
                      child: Text(
                        l
                            .t('view_all_comments')
                            .replaceAll('{n}', comments.length.toString()),
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.lightBlue[300]
                              : theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Widget para like en historias con expiración de 24h
class StoryLikeButton extends StatelessWidget {
  final String storyId;
  final String storyOwnerId;

  const StoryLikeButton({
    super.key,
    required this.storyId,
    required this.storyOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LikeButton(
      type: LikeableType.story,
      targetId: storyId,
      targetOwnerId: storyOwnerId,
      showCount: true,
      activeColor: Colors.pink,
      inactiveColor: theme.brightness == Brightness.dark
          ? Colors.white
          : theme.iconTheme.color ?? Colors.grey,
      size: 32.0,
    );
  }
}
