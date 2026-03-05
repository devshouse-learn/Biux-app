import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:biux/core/design_system/locale_notifier.dart';

/// Pantalla para editar el recorte cuadrado de una imagen
/// El usuario puede desplazar y escalar la imagen para ajustarla al encuadre cuadrado
class ImageCropEditorScreen extends StatefulWidget {
  final File imageFile;
  final String? title;

  const ImageCropEditorScreen({super.key, required this.imageFile, this.title});

  @override
  State<ImageCropEditorScreen> createState() => _ImageCropEditorScreenState();
}

class _ImageCropEditorScreenState extends State<ImageCropEditorScreen> {
  late Offset _imageOffset;
  late double _imageScale;
  double _initialScale = 1.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialImageOffset = Offset.zero;

  Size? _originalImageSize;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _imageOffset = Offset.zero;
    _imageScale = 1.0;
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
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<File?> _cropAndSaveImage() async {
    try {
      if (_originalImageSize == null) return null;

      // Leer la imagen original
      final imageBytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      // Obtener las dimensiones del panel de visualización
      final screenSize = MediaQuery.of(context).size;
      final frameSize = screenSize.width - 40; // Dejando margen

      // Calcular dimensiones reales de la imagen mostrada
      final displayImageWidth = _originalImageSize!.width * _imageScale;

      // Calcular el área de recorte en coordenadas de la imagen original
      final scaleFactor = _originalImageSize!.width / displayImageWidth;

      final cropX = (-_imageOffset.dx * scaleFactor)
          .clamp(0, _originalImageSize!.width.toInt())
          .toInt();
      final cropY = (-_imageOffset.dy * scaleFactor)
          .clamp(0, _originalImageSize!.height.toInt())
          .toInt();
      final cropSize = (frameSize * scaleFactor)
          .clamp(
            0,
            min(
              _originalImageSize!.width,
              _originalImageSize!.height,
            ).toDouble(),
          )
          .toInt();

      // Realizar el recorte
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropSize,
        height: cropSize,
      );

      // Redimensionar a una resolución estándar para guardar
      final resizedImage = img.copyResize(
        croppedImage,
        width: 1080,
        height: 1080,
      );

      // Guardar la imagen recortada
      final encodedBytes = img.encodeJpg(resizedImage, quality: 90);

      final String originalPath = widget.imageFile.path;
      final String extension = originalPath.split('.').last;
      final String newPath = originalPath.replaceAll(
        '.$extension',
        '_cropped_1x1.jpg',
      );

      final File croppedFile = File(newPath);
      await croppedFile.writeAsBytes(encodedBytes);

      return croppedFile;
    } catch (e) {
      final l = Provider.of<LocaleNotifier>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.t('error_cropping_image')}: $e')),
      );
      return null;
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _initialScale = _imageScale;
    _initialFocalPoint = details.focalPoint;
    _initialImageOffset = _imageOffset;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Escala
      _imageScale = (_initialScale * details.scale).clamp(0.5, 3.0);

      // Offset
      final Offset offset = details.focalPoint - _initialFocalPoint;
      _imageOffset = Offset(
        _initialImageOffset.dx + offset.dx,
        _initialImageOffset.dy + offset.dy,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final screenSize = MediaQuery.of(context).size;
    final frameSize = screenSize.width - 40; // Margen de 20 a cada lado

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? l.t('adjust_image'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? l.t('adjust_image'))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('${l.t('error_loading_image')}: $_error'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.t('go_back')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? l.t('adjust_image')),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Área de vista previa y edición
          Expanded(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: GestureDetector(
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Marco cuadrado de referencia (encuadre)
                      Container(
                        width: frameSize,
                        height: frameSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      // Oscuridad alrededor del marco
                      Container(
                        width: frameSize,
                        height: frameSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Arriba
                            Positioned(
                              top: -frameSize,
                              left: -frameSize,
                              child: Container(
                                width: frameSize * 3,
                                height: frameSize,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            // Abajo
                            Positioned(
                              bottom: -frameSize,
                              left: -frameSize,
                              child: Container(
                                width: frameSize * 3,
                                height: frameSize,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            // Izquierda
                            Positioned(
                              left: -frameSize,
                              top: -frameSize,
                              child: Container(
                                width: frameSize,
                                height: frameSize * 3,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            // Derecha
                            Positioned(
                              right: -frameSize,
                              top: -frameSize,
                              child: Container(
                                width: frameSize,
                                height: frameSize * 3,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Imagen
                      Transform.translate(
                        offset: _imageOffset,
                        child: Transform.scale(
                          scale: _imageScale,
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 64,
                              );
                            },
                          ),
                        ),
                      ),

                      // Controles en esquinas (pseudo handles)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Instrucciones y controles
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.t('use_fingers_to_scale'),
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: Text(l.t('cancel')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _cropAndSaveImage,
                      icon: const Icon(Icons.check),
                      label: Text(l.t('accept')),
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
}

double min(double a, double b) => a < b ? a : b;
