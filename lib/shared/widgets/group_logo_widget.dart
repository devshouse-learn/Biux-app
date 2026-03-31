import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget especializado para logos de grupos con manejo robusto de errores
class GroupLogoWidget extends StatelessWidget {
  final String? logoUrl;
  final double size;
  final bool isCircular;

  const GroupLogoWidget({
    super.key,
    required this.logoUrl,
    this.size = 40,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = _buildImageWidget();

    if (isCircular) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildImageWidget() {
    // Si no hay URL, mostrar placeholder directamente
    if (logoUrl == null || logoUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: logoUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        // Solo hacer log en debug, no en producción
        assert(() {
          debugPrint('⚠️ Error cargando logo de grupo: $url');
          debugPrint('   Error: $error');
          return true;
        }());
        return _buildPlaceholder();
      },
      // Optimización de memoria
      memCacheWidth: (size * 2).toInt(), // 2x para pantallas de alta densidad
      memCacheHeight: (size * 2).toInt(),
      // Timeouts más cortos para mejor UX
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      // Filtro de calidad para imágenes pequeñas
      filterQuality: FilterQuality.medium,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: isCircular
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(8),
      ),
      child: Icon(Icons.groups, color: Colors.grey[600], size: size * 0.5),
    );
  }
}
