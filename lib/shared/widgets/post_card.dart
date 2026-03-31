import 'dart:async';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  /// Callback de doble-tap (para dar like)
  final VoidCallback? onDoubleTap;

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
    this.onDoubleTap,
    this.actionsWidget,
    this.galleryOverlays,
    this.headerTrailing,
    this.descriptionWidget,
    this.bottomWidget,
    this.isEdited = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
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
                  onDoubleTap: onDoubleTap,
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isDark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    backgroundImage: user.photo.isNotEmpty
                        ? CachedNetworkImageProvider(
                            user.photo,
                            cacheManager: OptimizedCacheManager.avatarInstance,
                          )
                        : null,
                    child: user.photo.isEmpty
                        ? Icon(
                            Icons.person,
                            color: isDark ? Colors.grey[400] : Colors.grey,
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
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
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
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (isEdited)
                  Text(
                    l.t('post_edited'),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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

/// Galería de imágenes cuadrada (1:1) con PageView, flechas e indicador.
/// Doble-tap = like con corazón animado.
/// Zoom con pellizco que vuelve al soltar.
class _PostCardGallery extends StatefulWidget {
  final List<String> imageUrls;
  final void Function(int index)? onImageTap;
  final void Function(int index)? onImageLongPress;
  final VoidCallback? onDoubleTap;
  final List<Widget>? overlays;

  const _PostCardGallery({
    required this.imageUrls,
    this.onImageTap,
    this.onImageLongPress,
    this.onDoubleTap,
    this.overlays,
  });

  @override
  State<_PostCardGallery> createState() => _PostCardGalleryState();
}

class _PostCardGalleryState extends State<_PostCardGallery>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showArrows = false;
  Timer? _arrowTimer;

  // Zoom
  final TransformationController _transformController =
      TransformationController();

  // Animación de corazón al doble-tap
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnim;
  late Animation<double> _heartOpacityAnim;
  bool _showHeart = false;

  void _onPageSwipe() {
    if (!_showArrows) {
      setState(() => _showArrows = true);
    }
    _arrowTimer?.cancel();
    _arrowTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showArrows = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Animación del corazón
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heartScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartAnimController);
    _heartOpacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_heartAnimController);

    _heartAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showHeart = false);
      }
    });
  }

  @override
  void dispose() {
    _arrowTimer?.cancel();
    _pageController.dispose();
    _transformController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    // Mostrar corazón animado
    setState(() => _showHeart = true);
    _heartAnimController.forward(from: 0.0);

    // Ejecutar callback de like
    widget.onDoubleTap?.call();
  }

  void _resetZoom() {
    // Volver al estado original con animación suave
    _transformController.value = Matrix4.identity();
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
                  _onPageSwipe();
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
                    final l2 = Provider.of<LocaleNotifier>(
                      context,
                      listen: false,
                    );
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
                            l2.t('post_invalid_url'),
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
                    onDoubleTap: _onDoubleTap,
                    onLongPress: widget.onImageLongPress != null
                        ? () => widget.onImageLongPress!(index)
                        : null,
                    child: Listener(
                      onPointerUp: (_) {
                        // Cuando suelta todos los dedos, volver al tamaño original
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) _resetZoom();
                        });
                      },
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        clipBehavior: Clip.hardEdge,
                        panEnabled: false,
                        minScale: 1.0,
                        maxScale: 3.0,
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
                    child: AnimatedOpacity(
                      opacity: _showArrows ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !_showArrows,
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
                  ),
                ),
              // Navegación derecha
              if (hasMultiple)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showArrows ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !_showArrows,
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
              // Corazón animado al doble-tap
              if (_showHeart)
                Positioned.fill(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _heartAnimController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _heartOpacityAnim.value,
                          child: Transform.scale(
                            scale: _heartScaleAnim.value,
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 100,
                              shadows: [
                                Shadow(blurRadius: 20, color: Colors.black54),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            height: 1.5,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
