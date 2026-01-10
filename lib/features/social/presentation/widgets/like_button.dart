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

  Future<void> _onTap() async {
    final provider = context.read<LikesProvider>();

    // ⛔ PROTECCIÓN MÚLTIPLE CONTRA DOBLE CLICK
    // 1. No permitir si ya está procesando otra acción
    if (provider.isProcessing) {
      debugPrint('⏳ Like ya está procesando, por favor espera');
      return;
    }

    // 2. Verificar si ya ha dado like (solo permitir una vez)
    final isLiked = await provider
        .watchUserLiked(widget.type, widget.targetId)
        .first;
    if (isLiked) {
      debugPrint('✅ Ya has dado like a este contenido');
      return; // No hacer nada si ya le dio like
    }

    // Animación
    await _controller.forward();
    await _controller.reverse();

    // Like (solo permite dar like, no remover)
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
              onTap: (provider.isProcessing || isLiked) ? null : _onTap,
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
