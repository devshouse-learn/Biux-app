import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Datos de usuario genéricos para el PostCard
class PostCardUser {
  final String id;
  final String fullName;
  final String userName;
  final String photo;

  const PostCardUser({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.photo,
  });
}

/// Widget de publicación reutilizable para Feed y PostDetail.
/// Muestra: encabezado de usuario, galería 1:1, miniaturas, descripción.
class PostCard extends StatelessWidget {
  final PostCardUser user;
  final List<String> imageUrls;
  final String description;
  final String timestamp;
  final List<String> tags;

  /// Callback al tocar la foto del usuario
  final VoidCallback? onUserTap;

  /// Callback al tocar una imagen (recibe index)
  final void Function(int index)? onImageTap;

  /// Callback al mantener presionada una imagen (recibe index)
  final void Function(int index)? onImageLongPress;

  /// Widget de acciones (like, comentar, compartir) debajo de la galería
  final Widget? actionsWidget;

  /// Widgets opcionales superpuestos sobre la galería (ej.: menú de opciones)
  final List<Widget>? galleryOverlays;

  /// Widgets a la derecha del header (ej.: badge publicidad, botón eliminar, compartir)
  final List<Widget>? headerTrailing;

  /// Widget para la descripción personalizada (si es null usa texto simple)
  final Widget? descriptionWidget;

  /// Widget adicional al final (ej.: PostCommentsPreview)
  final Widget? bottomWidget;

  /// Indica si la publicación fue editada
  final bool isEdited;

  const PostCard({
    super.key,
    required this.user,
    required this.imageUrls,
    this.description = '',
    this.timestamp = '',
    this.tags = const [],
    this.onUserTap,
    this.onImageTap,
    this.onImageLongPress,
    this.actionsWidget,
    this.galleryOverlays,
    this.headerTrailing,
    this.descriptionWidget,
    this.bottomWidget,
    this.isEdited = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de usuario
          _PostCardHeader(
            user: user,
            timestamp: timestamp,
            isEdited: isEdited,
            onUserTap: onUserTap,
            trailing: headerTrailing,
          ),
          // Galería de imágenes cuadrada (1:1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _PostCardGallery(
                  imageUrls: imageUrls,
                  onImageTap: onImageTap,
                  onImageLongPress: onImageLongPress,
                  overlays: galleryOverlays,
                ),
                // Descripción y tags
                if (descriptionWidget != null)
                  descriptionWidget!
                else if (description.isNotEmpty || tags.isNotEmpty)
                  _PostCardDescription(description: description, tags: tags),
              ],
            ),
          ),
          // Acciones sociales
          if (actionsWidget != null) actionsWidget!,
          // Widget adicional (ej.: comentarios)
          if (bottomWidget != null) bottomWidget!,
        ],
      ),
    );
  }
}

/// Header de usuario estilo chip semi-transparente
class _PostCardHeader extends StatelessWidget {
  final PostCardUser user;
  final String timestamp;
  final bool isEdited;
  final VoidCallback? onUserTap;
  final List<Widget>? trailing;

  const _PostCardHeader({
    required this.user,
    required this.timestamp,
    this.isEdited = false,
    this.onUserTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: user.photo.isNotEmpty
                        ? CachedNetworkImageProvider(
                            user.photo,
                            cacheManager: OptimizedCacheManager.avatarInstance,
                          )
                        : null,
                    child: user.photo.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.fullName.isNotEmpty
                            ? user.fullName
                            : user.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.userName.isNotEmpty)
                        Text(
                          '@${user.userName}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (timestamp.isNotEmpty) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timestamp,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                if (isEdited)
                  Text(
                    'editado',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
          const Spacer(),
          if (trailing != null) ...trailing!,
        ],
      ),
    );
  }
}

/// Galería de imágenes cuadrada (1:1) con PageView, flechas e indicador
class _PostCardGallery extends StatefulWidget {
  final List<String> imageUrls;
  final void Function(int index)? onImageTap;
  final void Function(int index)? onImageLongPress;
  final List<Widget>? overlays;

  const _PostCardGallery({
    required this.imageUrls,
    this.onImageTap,
    this.onImageLongPress,
    this.overlays,
  });

  @override
  State<_PostCardGallery> createState() => _PostCardGalleryState();
}

class _PostCardGalleryState extends State<_PostCardGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gallerySize = screenWidth - 32; // 16px padding cada lado
    final hasMultiple = widget.imageUrls.length > 1;

    return Column(
      children: [
        // Galería cuadrada con bordes redondeados
        Container(
          height: gallerySize,
          width: gallerySize,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.imageUrls[index];

                  // Validar URL
                  final url = imageUrl.trim();
                  final isValidUrl =
                      url.isNotEmpty &&
                      (url.startsWith('http://') || url.startsWith('https://'));

                  if (!isValidUrl) {
                    return Container(
                      color: Colors.grey[900],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.grey[600],
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'URL no válida',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: widget.onImageTap != null
                        ? () => widget.onImageTap!(index)
                        : null,
                    onLongPress: widget.onImageLongPress != null
                        ? () => widget.onImageLongPress!(index)
                        : null,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      cacheManager: OptimizedCacheManager.instance,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                          size: 48,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Navegación izquierda
              if (hasMultiple)
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              // Navegación derecha
              if (hasMultiple)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentIndex < widget.imageUrls.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              // Indicador de página
              if (hasMultiple)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              // Overlays personalizados
              if (widget.overlays != null) ...widget.overlays!,
            ],
          ),
        ),
        // Miniaturas
        if (hasMultiple) _buildThumbnailRow(),
      ],
    );
  }

  Widget _buildThumbnailRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.imageUrls.length, (index) {
            final imageUrl = widget.imageUrls[index];
            final isSelected = index == _currentIndex;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? ColorTokens.primary30
                        : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    cacheManager: OptimizedCacheManager.instance,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[800],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Descripción y tags por defecto
class _PostCardDescription extends StatelessWidget {
  final String description;
  final List<String> tags;

  const _PostCardDescription({required this.description, this.tags = const []});

  @override
  Widget build(BuildContext context) {
    final tagsText = tags.isNotEmpty
        ? '\n${tags.map((e) => '#$e').join(' ')}'
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$description$tagsText',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
