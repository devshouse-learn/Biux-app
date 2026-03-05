import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/likes_repository.dart';
import '../providers/likes_provider.dart';

/// Widget de botón de like con animación
class LikeButton extends StatefulWidget {
  final LikeableType type;
  final String targetId;
  final String targetOwnerId;
  final String? targetPreview;
  final bool showCount;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;

  const LikeButton({
    super.key,
    required this.type,
    required this.targetId,
    required this.targetOwnerId,
    this.targetPreview,
    this.showCount = true,
    this.activeColor,
    this.inactiveColor,
    this.size = 24.0,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isTapping = false;

  Future<void> _onTap() async {
    if (_isTapping) return;
    _isTapping = true;

    try {
      final provider = context.read<LikesProvider>();

      // Obtener estado actual del like
      final isLiked = await provider
          .watchUserLiked(widget.type, widget.targetId)
          .first;

      // Animación
      _controller.forward().then((_) => _controller.reverse());

      // Toggle: si ya tiene like, quitarlo; si no, agregarlo
      if (isLiked) {
        // Remover like
        switch (widget.type) {
          case LikeableType.post:
            await provider.unlikePost(widget.targetId);
            break;
          case LikeableType.comment:
            await provider.unlikeComment(widget.targetId);
            break;
          case LikeableType.story:
            await provider.unlikeStory(widget.targetId);
            break;
        }
      } else {
        // Agregar like
        switch (widget.type) {
          case LikeableType.post:
            await provider.likePost(
              postId: widget.targetId,
              postOwnerId: widget.targetOwnerId,
              postPreview: widget.targetPreview,
            );
            break;
          case LikeableType.comment:
            await provider.likeComment(
              commentId: widget.targetId,
              commentOwnerId: widget.targetOwnerId,
              commentPreview: widget.targetPreview,
            );
            break;
          case LikeableType.story:
            await provider.likeStory(
              storyId: widget.targetId,
              storyOwnerId: widget.targetOwnerId,
            );
            break;
        }
      }
    } finally {
      _isTapping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LikesProvider>();
    final activeColor = widget.activeColor ?? Colors.red;
    final inactiveColor = widget.inactiveColor ?? Colors.grey;

    return StreamBuilder<bool>(
      stream: provider.watchUserLiked(widget.type, widget.targetId),
      builder: (context, isLikedSnapshot) {
        final isLiked = isLikedSnapshot.data ?? false;

        return StreamBuilder<int>(
          stream: provider.watchLikesCount(widget.type, widget.targetId),
          builder: (context, countSnapshot) {
            final count = countSnapshot.data ?? 0;

            return InkWell(
              onTap: _onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? activeColor : inactiveColor,
                        size: widget.size,
                      ),
                    ),
                    if (widget.showCount && count > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          color: isLiked ? activeColor : inactiveColor,
                          fontWeight: isLiked
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
