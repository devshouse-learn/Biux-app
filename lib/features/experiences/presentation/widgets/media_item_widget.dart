import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';

/// Widget para mostrar un item multimedia en la creación de experiencias
class MediaItemWidget extends StatelessWidget {
  final MediaItem mediaItem;
  final VoidCallback onRemove;

  const MediaItemWidget({
    super.key,
    required this.mediaItem,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Contenido principal
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: _buildContent(),
          ),

          // Indicador de procesamiento
          if (mediaItem.isProcessing)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Procesando...',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

          // Botón de eliminar
          if (!mediaItem.isProcessing)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),

          // Indicador de tipo de media
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mediaItem.isVideo ? Icons.videocam : Icons.photo,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${mediaItem.duration}s',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Media remota (ya subida - modo edición)
    if (mediaItem.isRemote) {
      if (mediaItem.isVideo) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: mediaItem.url!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildVideoPlaceholder(),
              errorWidget: (context, url, error) => _buildVideoPlaceholder(),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        );
      } else {
        return CachedNetworkImage(
          imageUrl: mediaItem.url!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildImagePlaceholder(),
        );
      }
    }

    // Media local (archivo nuevo)
    if (mediaItem.isVideo) {
      // Para videos, mostrar thumbnail si existe, sino el primer frame
      if (mediaItem.thumbnailPath != null) {
        return Image.file(
          File(mediaItem.thumbnailPath!),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildVideoPlaceholder();
          },
        );
      } else {
        return _buildVideoPlaceholder();
      }
    } else {
      // Para imágenes
      return Image.file(
        File(mediaItem.filePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.grey, size: 32),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.photo, color: Colors.grey, size: 32),
      ),
    );
  }
}
