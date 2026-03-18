import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/stories/data/models/comment_story.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/stories/presentation/screens/story_view/story_view_bloc.dart';
import 'package:biux/shared/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StoryCommentsBottomSheet extends StatefulWidget {
  final Story story;

  const StoryCommentsBottomSheet({Key? key, required this.story})
    : super(key: key);

  @override
  State<StoryCommentsBottomSheet> createState() =>
      _StoryCommentsBottomSheetState();
}

class _StoryCommentsBottomSheetState extends State<StoryCommentsBottomSheet> {
  late TextEditingController _commentController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.isEmpty) return;

    final userId = AuthenticationRepository().getUserId;
    final userName = LocalStorage().getUserName();

    final newComment = CommentStory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userPhoto: '', // Aquí se podría agregar la foto del usuario
      text: _commentController.text,
      createdAt: DateTime.now().toString(),
      likesCount: 0,
    );

    widget.story.listComments.add(newComment);
    _commentController.clear();

    // Actualizar en la BD
    context.read<StoryViewBloc>().updateStoryComments(story: widget.story);

    setState(() {});

    // Scroll al último comentario
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l.t('comments')} (${widget.story.listComments.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Lista de comentarios
          Expanded(
            child: widget.story.listComments.isEmpty
                ? Center(
                    child: Text(
                      l.t('no_comments_yet'),
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: widget.story.listComments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.story.listComments[index];
                      // Filtrar comentarios eliminados - no mostrarlos
                      if (!comment.shouldDisplay) {
                        return const SizedBox.shrink();
                      }
                      return _CommentTile(comment: comment);
                    },
                  ),
          ),

          // Campo de entrada de comentario
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: l.t('add_comment_hint'),
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: ColorTokens.primary30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary30,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentStory comment;

  const _CommentTile({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (placeholder)
              CircleAvatar(
                radius: 16,
                backgroundColor: ColorTokens.primary30,
                child: Text(
                  comment.userName.isNotEmpty
                      ? comment.userName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(comment.createdAt, l),
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.likesCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 8),
              child: GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 12, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.likesCount}',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateString, LocaleNotifier l) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return l.t('time_seconds_ago');
      } else if (difference.inMinutes < 60) {
        return l
            .t('time_minutes_ago')
            .replaceAll('{n}', '${difference.inMinutes}');
      } else if (difference.inHours < 24) {
        return l.t('time_hours_ago').replaceAll('{n}', '${difference.inHours}');
      } else if (difference.inDays < 7) {
        return l.t('time_days_ago').replaceAll('{n}', '${difference.inDays}');
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return l.t('unknown_date');
    }
  }
}
