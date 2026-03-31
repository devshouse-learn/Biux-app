
import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    Key? key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (ctx, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300]!.withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class PostSkeleton extends StatelessWidget {
  const PostSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoading(width: 44, height: 44, borderRadius: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLoading(width: 120, height: 14),
                  SizedBox(height: 6),
                  SkeletonLoading(width: 80, height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const SkeletonLoading(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const SkeletonLoading(width: 200, height: 14),
          const SizedBox(height: 14),
          const SkeletonLoading(width: double.infinity, height: 200, borderRadius: 12),
          const SizedBox(height: 14),
          Row(
            children: const [
              SkeletonLoading(width: 60, height: 12),
              SizedBox(width: 20),
              SkeletonLoading(width: 60, height: 12),
              SizedBox(width: 20),
              SkeletonLoading(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SkeletonLoading(width: 100, height: 100, borderRadius: 50),
          const SizedBox(height: 16),
          const SkeletonLoading(width: 160, height: 20),
          const SizedBox(height: 8),
          const SkeletonLoading(width: 100, height: 14),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (_) => Column(
              children: const [
                SkeletonLoading(width: 40, height: 18),
                SizedBox(height: 4),
                SkeletonLoading(width: 60, height: 12),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const SkeletonLoading(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoading(width: 140, height: 14),
                SizedBox(height: 6),
                SkeletonLoading(width: 200, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const AnimatedBuilder({Key? key, required Animation<double> animation, required this.builder})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, null);
}
