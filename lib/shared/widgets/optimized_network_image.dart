import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget para mostrar imágenes de red optimizadas con cache
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String imageType;
  final Widget? errorWidget;
  final Widget? placeholder;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.imageType = 'general',
    this.errorWidget,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget() {
    IconData iconData;
    switch (imageType) {
      case 'avatar':
        iconData = Icons.person;
        break;
      case 'post':
        iconData = Icons.image;
        break;
      case 'story':
        iconData = Icons.play_circle_outline;
        break;
      default:
        iconData = Icons.broken_image;
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        iconData,
        color: Colors.grey[600],
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.4 : height! * 0.4)
            : 32,
      ),
    );
  }
}
