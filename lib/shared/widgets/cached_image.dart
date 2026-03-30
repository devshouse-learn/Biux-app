
// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const CachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  const CachedImage.avatar({
    super.key,
    required this.url,
    this.width = 40,
    this.height = 40,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Widget img = url == null || url!.isEmpty
        ? _buildError()
        : CachedNetworkImage(
            imageUrl: url!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, __) => placeholder ?? _buildPlaceholder(),
            errorWidget: (_, __, ___) => errorWidget ?? _buildError(),
            fadeInDuration: const Duration(milliseconds: 200),
            memCacheWidth: width?.toInt(),
            memCacheHeight: height?.toInt(),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }

  Widget _buildPlaceholder() => Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      );

  Widget _buildError() => Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey.shade200,
        child: Icon(
          Icons.person_rounded,
          color: Colors.grey.shade400,
          size: (width ?? 40) * 0.5,
        ),
      );
}

class CachedAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final Color? backgroundColor;

  const CachedAvatar({
    super.key,
    required this.url,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      child: ClipOval(
        child: CachedImage(
          url: url,
          width: radius * 2,
          height: radius * 2,
        ),
      ),
    );
  }
}
