import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../providers/comments_provider.dart';
import 'comment_item.dart';

/// Widget de lista de comentarios
class CommentsList extends StatelessWidget {
  final CommentableType type;
  final String targetId;
  final String targetOwnerId;
  final bool showTextField;
  final String? placeholder;

  const CommentsList({
    super.key,
    required this.type,
    required this.targetId,
    required this.targetOwnerId,
    this.showTextField = true,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentsProvider>();

    return Column(
      children: [
        if (showTextField)
          _CommentTextField(
            type: type,
            targetId: targetId,
            targetOwnerId: targetOwnerId,
            placeholder: placeholder ?? 'Escribe un comentario...',
          ),
        StreamBuilder<List<CommentEntity>>(
          stream: provider.watchComments(type, targetId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No hay comentarios aún',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentItem(
                  comment: comments[index],
                  type: type,
                  targetId: targetId,
                  targetOwnerId: targetOwnerId,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Campo de texto para escribir comentarios
class _CommentTextField extends StatefulWidget {
  final CommentableType type;
  final String targetId;
  final String targetOwnerId;
  final String placeholder;
  final String? parentCommentId;
  final String? parentCommentOwnerId;

  const _CommentTextField({
    required this.type,
    required this.targetId,
    required this.targetOwnerId,
    required this.placeholder,
    this.parentCommentId,
    this.parentCommentOwnerId,
  });

  @override
  State<_CommentTextField> createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends State<_CommentTextField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<CommentsProvider>();

    String? commentId;
    if (widget.type == CommentableType.post) {
      commentId = await provider.commentOnPost(
        postId: widget.targetId,
        postOwnerId: widget.targetOwnerId,
        text: text,
        parentCommentId: widget.parentCommentId,
        parentCommentOwnerId: widget.parentCommentOwnerId,
      );
    } else {
      commentId = await provider.commentOnRide(
        rideId: widget.targetId,
        rideOwnerId: widget.targetOwnerId,
        text: text,
        parentCommentId: widget.parentCommentId,
        parentCommentOwnerId: widget.parentCommentOwnerId,
      );
    }

    if (commentId != null) {
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: isDark ? theme.dividerColor : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: 500,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _onSubmit(),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                errorText: provider.error,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: provider.isPosting ? null : _onSubmit,
            icon: provider.isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            color: isDark ? Colors.lightBlue[300] : theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
