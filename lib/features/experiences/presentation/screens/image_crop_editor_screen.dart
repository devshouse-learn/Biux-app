import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Pantalla para editar el recorte cuadrado de una imagen
/// El usuario puede desplazar y escalar la imagen para ajustarla al encuadre cuadrado
class ImageCropEditorScreen extends StatefulWidget {
  final File imageFile;
  final String? title;

  const ImageCropEditorScreen({
    super.key,
    required this.imageFile,
    this.title = 'Ajustar imagen',
  });

  @override
  State<ImageCropEditorScreen> createState() => _ImageCropEditorScreenState();
}

class _ImageCropEditorScreenState extends State<ImageCropEditorScreen> {
  // Transformaciones de la imagen
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _startFocalPoint = Offset.zero;
  Offset _startOffset = Offset.zero;

  // Dimensiones de imagen original
  Size? _originalImageSize;
  bool _isLoading = true;
  bool _isCropping = false;
  String? _error;

  // Escala base para que la imagen llene el marco
  double _fitScale = 1.0;

  // Dimensiones reales del contenedor (del LayoutBuilder)
  Size _containerSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    try {
      final imageBytes = await widget.imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage != null) {
        setState(() {
          _originalImageSize = Size(
            decodedImage.width.toDouble(),
            decodedImage.height.toDouble(),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se pudo decodificar la imagen';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar imagen: $e';
        _isLoading = false;
      });
    }
  }

  /// Calcula la escala mínima para que la imagen cubra el marco cuadrado
  double _calcFitScale(double frameSize, Size imageDisplaySize) {
    final scaleX = frameSize / imageDisplaySize.width;
    final scaleY = frameSize / imageDisplaySize.height;
    return math.max(scaleX, scaleY);
  }

  /// Asegura que la imagen siempre cubra el marco cuadrado completamente
  void _clampOffset(double frameSize, Size imageDisplaySize) {
    final scaledW = imageDisplaySize.width * _scale;
    final scaledH = imageDisplaySize.height * _scale;

    final halfFrame = frameSize / 2;

    // Limitar desplazamiento para que el marco siempre esté dentro de la imagen
    final minX = halfFrame - scaledW / 2;
    final maxX = scaledW / 2 - halfFrame;
    final minY = halfFrame - scaledH / 2;
    final maxY = scaledH / 2 - halfFrame;

    _offset = Offset(
      _offset.dx.clamp(math.min(minX, 0), math.max(maxX, 0)),
      _offset.dy.clamp(math.min(minY, 0), math.max(maxY, 0)),
    );
  }

  Future<void> _onAccept() async {
    if (_isCropping || _originalImageSize == null) return;

    setState(() => _isCropping = true);

    try {
      final imageBytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        setState(() => _isCropping = false);
        return;
      }

      final screenSize = MediaQuery.of(context).size;
      final frameSize = screenSize.width - 40;

      final imageW = _originalImageSize!.width;
      final imageH = _originalImageSize!.height;

      // Usar las dimensiones reales del contenedor guardadas del LayoutBuilder
      final containerW = _containerSize.width > 0 ? _containerSize.width : screenSize.width;
      final containerH = _containerSize.height > 0 ? _containerSize.height : screenSize.height * 0.6;
      final displayScale = math.min(containerW / imageW, containerH / imageH);

      // Escala total aplicada (displayScale * _scale)
      final totalScale = displayScale * _scale;

      // Centro de la imagen en pantalla: está en el centro del container,
      // desplazada por _offset
      // El marco cuadrado está centrado en el container

      // Posición del centro del marco relativa al centro de la imagen original (en píxeles de imagen)
      final cropCenterX = (imageW / 2) - (_offset.dx / totalScale);
      final cropCenterY = (imageH / 2) - (_offset.dy / totalScale);

      // Tamaño del recorte en píxeles de imagen
      final cropSizeInImage = frameSize / totalScale;

      // Coordenadas del recorte
      int cropX = (cropCenterX - cropSizeInImage / 2).round();
      int cropY = (cropCenterY - cropSizeInImage / 2).round();
      int cropSize = cropSizeInImage.round();

      // Clamping
      cropX = cropX.clamp(0, (imageW - 1).toInt());
      cropY = cropY.clamp(0, (imageH - 1).toInt());
      cropSize = cropSize.clamp(1, math.min(imageW.toInt() - cropX, imageH.toInt() - cropY));

      final croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropSize,
        height: cropSize,
      );

      // Redimensionar a 1080x1080
      final resizedImage = img.copyResize(croppedImage, width: 1080, height: 1080);
      final encodedBytes = img.encodeJpg(resizedImage, quality: 90);

      final originalPath = widget.imageFile.path;
      final ext = originalPath.split('.').last;
      final newPath = originalPath.replaceAll('.$ext', '_cropped_1x1.jpg');

      final croppedFile = File(newPath);
      await croppedFile.writeAsBytes(encodedBytes);

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      setState(() => _isCropping = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al recortar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final frameSize = screenSize.width - 40;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Ajustar imagen')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Ajustar imagen')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Ajustar imagen'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Área de edición
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerW = constraints.maxWidth;
                final containerH = constraints.maxHeight;

                // Guardar dimensiones reales del contenedor para usarlas en _onAccept
                _containerSize = Size(containerW, containerH);

                // Calcular cómo se muestra la imagen con BoxFit.contain
                final imageW = _originalImageSize!.width;
                final imageH = _originalImageSize!.height;
                final displayScale = math.min(containerW / imageW, containerH / imageH);
                final displayW = imageW * displayScale;
                final displayH = imageH * displayScale;
                final imageDisplaySize = Size(displayW, displayH);

                // Escala mínima para cubrir el marco
                _fitScale = _calcFitScale(frameSize, imageDisplaySize);
                final minScale = _fitScale;

                return Container(
                  color: Colors.black,
                  child: GestureDetector(
                    onScaleStart: (details) {
                      _baseScale = _scale;
                      _startFocalPoint = details.focalPoint;
                      _startOffset = _offset;
                    },
                    onScaleUpdate: (details) {
                      setState(() {
                        _scale = (_baseScale * details.scale).clamp(minScale, 5.0);
                        final delta = details.focalPoint - _startFocalPoint;
                        _offset = _startOffset + delta;
                        _clampOffset(frameSize, imageDisplaySize);
                      });
                    },
                    onScaleEnd: (_) {
                      // Asegurar escala mínima
                      if (_scale < minScale) {
                        setState(() {
                          _scale = minScale;
                          _clampOffset(frameSize, imageDisplaySize);
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Imagen transformable
                        Transform.translate(
                          offset: _offset,
                          child: Transform.scale(
                            scale: _scale,
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, color: Colors.white, size: 64);
                              },
                            ),
                          ),
                        ),

                        // Oscuridad fuera del marco (4 rectángulos)
                        // Arriba
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: (containerH - frameSize) / 2,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                        // Abajo
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: (containerH - frameSize) / 2,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                        // Izquierda
                        Positioned(
                          top: (containerH - frameSize) / 2,
                          left: 0,
                          child: Container(
                            width: (containerW - frameSize) / 2,
                            height: frameSize,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                        // Derecha
                        Positioned(
                          top: (containerH - frameSize) / 2,
                          right: 0,
                          child: Container(
                            width: (containerW - frameSize) / 2,
                            height: frameSize,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),

                        // Marco cuadrado
                        IgnorePointer(
                          child: Container(
                            width: frameSize,
                            height: frameSize,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Stack(
                              children: [
                                // Líneas de tercios horizontales
                                Positioned(
                                  top: frameSize / 3 - 0.5,
                                  left: 0, right: 0,
                                  child: Container(height: 0.5, color: Colors.white38),
                                ),
                                Positioned(
                                  top: frameSize * 2 / 3 - 0.5,
                                  left: 0, right: 0,
                                  child: Container(height: 0.5, color: Colors.white38),
                                ),
                                // Líneas de tercios verticales
                                Positioned(
                                  left: frameSize / 3 - 0.5,
                                  top: 0, bottom: 0,
                                  child: Container(width: 0.5, color: Colors.white38),
                                ),
                                Positioned(
                                  left: frameSize * 2 / 3 - 0.5,
                                  top: 0, bottom: 0,
                                  child: Container(width: 0.5, color: Colors.white38),
                                ),
                                // Esquinas
                                _buildCorner(top: -1, left: -1),
                                _buildCorner(top: -1, right: -1),
                                _buildCorner(bottom: -1, left: -1),
                                _buildCorner(bottom: -1, right: -1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Controles inferiores
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pellizca para escalar, arrastra para ajustar',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isCropping ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isCropping ? null : _onAccept,
                      icon: _isCropping
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isCropping ? 'Procesando...' : 'Aceptar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            left: left != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            right: right != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
