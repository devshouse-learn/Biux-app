import 'package:flutter/material.dart';
import 'package:biux/shared/widgets/optimized_network_image.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

/// Widget para visualizar fotos en pantalla completa con zoom y gestos
class PhotoViewer extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;
  final List<String>? photoLabels; // Etiquetas opcionales para cada foto

  const PhotoViewer({
    super.key,
    required this.photoUrls,
    this.initialIndex = 0,
    this.photoLabels,
  });

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Visor de fotos con zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photoUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return ZoomablePhoto(photoUrl: widget.photoUrls[index]);
            },
          ),

          // AppBar superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title:
                  widget.photoLabels != null &&
                      _currentIndex < widget.photoLabels!.length
                  ? Text(
                      widget.photoLabels![_currentIndex],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )
                  : null,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => _sharePhoto(widget.photoUrls[_currentIndex]),
                ),
              ],
            ),
          ),

          // Indicador de página (si hay más de 1 foto)
          if (widget.photoUrls.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.photoUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sharePhoto(String photoUrl) {
    // PENDIENTE: Implementar compartir foto
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartir foto próximamente')),
    );
  }
}

/// Widget individual de foto con zoom mediante gestos
class ZoomablePhoto extends StatefulWidget {
  final String photoUrl;

  const ZoomablePhoto({super.key, required this.photoUrl});

  @override
  State<ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<ZoomablePhoto>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: OptimizedNetworkImage(
            imageUrl: widget.photoUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    final Matrix4 currentMatrix = _transformationController.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();

    Matrix4 targetMatrix;
    if (currentScale > 1.0) {
      // Si ya está con zoom, volver al zoom original
      targetMatrix = Matrix4.identity();
    } else {
      // Si está en zoom original, hacer zoom x2
      targetMatrix = Matrix4.identity()..scaleByVector3(Vector3(2.0, 2.0, 1.0));
    }

    _animation = Matrix4Tween(begin: currentMatrix, end: targetMatrix).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward(from: 0).then((_) {
      _transformationController.value = targetMatrix;
    });

    _animation!.addListener(() {
      _transformationController.value = _animation!.value;
    });
  }
}

/// Extension para abrir el visor de fotos fácilmente
extension PhotoViewerExtension on BuildContext {
  void openPhotoViewer({
    required List<String> photoUrls,
    int initialIndex = 0,
    List<String>? photoLabels,
  }) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewer(
          photoUrls: photoUrls,
          initialIndex: initialIndex,
          photoLabels: photoLabels,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
