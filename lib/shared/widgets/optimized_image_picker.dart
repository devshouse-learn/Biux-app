import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../core/design_system/color_tokens.dart';
import '../services/image_compression_service.dart';
import '../services/optimized_storage_service.dart';
import '../services/optimized_cache_manager.dart';

/// Widget optimizado para selección y carga de imágenes
/// Integra compresión automática y carga eficiente para reducir costos de Firebase
class OptimizedImagePicker extends StatefulWidget {
  final String? currentImageUrl;
  final Function(String? imageUrl) onImageSelected;
  final String imageType; // 'avatar', 'cover', 'gallery', 'ride', 'story'
  final String? entityId; // userId, groupId, rideId según el contexto
  final double width;
  final double height;
  final bool showProgress;
  final Widget? placeholder;
  final BorderRadius? borderRadius;

  const OptimizedImagePicker({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    required this.imageType,
    this.entityId,
    this.width = 100,
    this.height = 100,
    this.showProgress = true,
    this.placeholder,
    this.borderRadius,
  });

  @override
  State<OptimizedImagePicker> createState() => _OptimizedImagePickerState();
}

class _OptimizedImagePickerState extends State<OptimizedImagePicker> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _showImageSourceDialog,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          border: Border.all(color: ColorTokens.neutral20, width: 2),
        ),
        child: Stack(
          children: [
            // Imagen actual o placeholder
            _buildImageContent(),

            // Overlay de carga
            if (_isUploading) _buildUploadOverlay(),

            // Icono de cámara
            if (!_isUploading) _buildCameraIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
        child: Image.file(
          _selectedImage!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    }

    if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: widget.currentImageUrl!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
          // Configuración de caché optimizada para reducir transferencias
          cacheManager: DefaultCacheManager(),
          maxWidthDiskCache: _safeCacheSize(
            widget.width,
            2,
          ), // 2x para pantallas HD
          maxHeightDiskCache: _safeCacheSize(widget.height, 2),
          memCacheWidth: _safeRound(widget.width),
          memCacheHeight: _safeRound(widget.height),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          color: ColorTokens.neutral10,
          child: Icon(
            Icons.image_outlined,
            color: ColorTokens.neutral40,
            size: widget.width * 0.3,
          ),
        );
  }

  Widget _buildUploadOverlay() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: widget.showProgress ? _uploadProgress : null,
            valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary50),
            strokeWidth: 3,
          ),
          SizedBox(height: 8),
          Text(
            widget.showProgress
                ? '${_uploadProgress.isFinite ? (_uploadProgress * 100).round() : 0}%'
                : 'Subiendo...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraIcon() {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: ColorTokens.primary50,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.camera_alt, color: Colors.white, size: 14),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera, color: ColorTokens.primary50),
                title: Text('Tomar foto'),
                onTap: () => _selectImage(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: ColorTokens.primary50,
                ),
                title: Text('Seleccionar de galería'),
                onTap: () => _selectImage(ImageSource.gallery),
              ),
              if (widget.currentImageUrl != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Eliminar imagen'),
                  onTap: _removeImage,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    Navigator.pop(context); // Cerrar modal

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920, // Límite inicial antes de compresión
        maxHeight: 1920,
        imageQuality: 90, // Calidad inicial alta, luego comprimimos
      );

      if (pickedFile == null) return;

      final File imageFile = File(pickedFile.path);

      // Verificar si necesita compresión y mostrar info al usuario
      final needsCompression = await ImageCompressionService.needsCompression(
        imageFile,
      );
      if (needsCompression) {
        final originalSize = await imageFile.length();
        _showCompressionInfo(originalSize);
      }

      setState(() {
        _selectedImage = imageFile;
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      await _uploadImage(imageFile);
    } catch (e) {
      _showError('Error seleccionando imagen: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String? uploadedUrl;

      switch (widget.imageType) {
        case 'avatar':
        case 'cover':
        case 'gallery':
          uploadedUrl = await OptimizedStorageService.uploadUserImage(
            userId: widget.entityId!,
            imageFile: imageFile,
            imageType: widget.imageType,
            onProgress: () {
              setState(() {
                _uploadProgress += 0.1; // Incremento aproximado
              });
            },
          );
          break;

        case 'group':
          final result = await OptimizedStorageService.uploadGroupImage(
            groupId: widget.entityId!,
            imageFile: imageFile,
            imageType: 'cover',
            onProgress: () {
              setState(() {
                _uploadProgress += 0.1;
              });
            },
          );
          uploadedUrl = result?['main'];
          break;

        case 'ride':
          // Si no hay entityId (creación de ride), generar uno temporal
          final rideId =
              widget.entityId ??
              'temp_${DateTime.now().millisecondsSinceEpoch}';
          uploadedUrl = await OptimizedStorageService.uploadRideImage(
            rideId: rideId,
            imageFile: imageFile,
            onProgress: () {
              setState(() {
                _uploadProgress += 0.1;
              });
            },
          );
          break;

        case 'story':
          uploadedUrl = await OptimizedStorageService.uploadStoryImage(
            userId: widget.entityId!,
            imageFile: imageFile,
            onProgress: () {
              setState(() {
                _uploadProgress += 0.1;
              });
            },
          );
          break;
      }

      if (uploadedUrl != null) {
        widget.onImageSelected(uploadedUrl);
        _showSuccess('Imagen subida con éxito');
      } else {
        _showError('Error subiendo imagen');
      }
    } catch (e) {
      _showError('Error en la carga: $e');
    } finally {
      setState(() {
        _isUploading = false;
        _selectedImage = null;
      });
    }
  }

  void _removeImage() {
    Navigator.pop(context);
    // Pasar cadena vacía para indicar eliminación (no null)
    widget.onImageSelected("");
  }

  void _showCompressionInfo(int originalSizeBytes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subiendo imagen'),
        backgroundColor: ColorTokens.primary50,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Helper function para validar que un número sea finito y seguro para convertir a int
  int? _safeRound(double value) {
    if (!value.isFinite) return null;
    return value.round();
  }

  /// Helper function para cache con multiplicador
  int? _safeCacheSize(double value, int multiplier) {
    if (!value.isFinite) return null;
    return (value * multiplier).round();
  }
}

/// Widget para mostrar imágenes optimizadas con caché inteligente
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final String imageType; // Para usar caché apropiado

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.imageType = 'default', // thumbnail, avatar, etc.
  });

  /// Calcula la resolución óptima para caché según el tipo de imagen
  int? _getOptimalCacheSize(double? displaySize, String imageType) {
    if (displaySize == null || !displaySize.isFinite) {
      return null;
    }

    // Para avatares y logos, usamos una resolución mínima de 200px para mejor calidad
    if (imageType == 'avatar' || imageType == 'logo') {
      final minSize = 200.0;
      final result = (displaySize * 2).clamp(
        minSize,
        400.0,
      ); // 2x para calidad HD, máximo 400px
      print(
        'OptimizedNetworkImage - Cache size para $imageType: display=${displaySize} -> cache=${result}',
      );
      return result.round();
    }

    // Para thumbnails, usamos 1.5x el tamaño de display
    if (imageType == 'thumbnail') {
      final result = (displaySize * 1.5).clamp(100.0, 300.0);
      print(
        'OptimizedNetworkImage - Cache size para thumbnail: display=${displaySize} -> cache=${result}',
      );
      return result.round();
    }

    // Para covers y otras imágenes grandes, usamos resolución HD
    if (imageType == 'cover') {
      // Para covers, usamos mínimo 600px y hasta 1200px para máxima calidad
      final minSize = 600.0;
      final result = (displaySize * 3).clamp(
        minSize,
        1200.0,
      ); // 3x para calidad ultra HD, máximo 1200px
      print(
        'OptimizedNetworkImage - Cache size para cover: display=${displaySize} -> cache=${result}',
      );
      return result.round();
    }

    // Para otros tipos, usar el tamaño original si es finito
    final result = displaySize.round();
    print(
      'OptimizedNetworkImage - Cache size para $imageType: display=${displaySize} -> cache=${result}',
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Validar que la URL no esté vacía
    if (imageUrl.isEmpty) {
      print('OptimizedNetworkImage - URL vacía, mostrando widget de error');
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: ColorTokens.neutral10,
            child: Icon(
              Icons.broken_image,
              color: ColorTokens.neutral40,
              size: 24,
            ),
          );
    }

    // Debug: Imprimir información de la imagen
    print(
      'OptimizedNetworkImage: ${imageUrl.isNotEmpty ? "Loading" : "Empty URL"} - URL: $imageUrl',
    );
    print(
      'OptimizedNetworkImage: imageType: $imageType, width: $width, height: $height',
    );

    // Seleccionar el cache manager apropiado según el tipo de imagen
    final cacheManager = OptimizedCacheManager.getCacheManager(imageType);
    print(
      'OptimizedNetworkImage - Cache Manager para $imageType: ${cacheManager.runtimeType}',
    );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheManager: cacheManager,
        placeholder: (context, url) {
          print('OptimizedNetworkImage - Placeholder mostrado para: $url');
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: ColorTokens.neutral10,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorTokens.primary50,
                    ),
                  ),
                ),
              );
        },
        errorWidget: (context, url, error) {
          print('OptimizedNetworkImage - Error cargando: $url, Error: $error');
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: ColorTokens.neutral10,
                child: Icon(
                  Icons.broken_image,
                  color: ColorTokens.neutral40,
                  size:
                      (width != null &&
                          height != null &&
                          width!.isFinite &&
                          height!.isFinite)
                      ? (width! < height! ? width! * 0.3 : height! * 0.3)
                      : 24,
                ),
              );
        },
        // Configuración optimizada para máximo rendimiento y mínimo costo
        maxWidthDiskCache: _getOptimalCacheSize(width, imageType),
        maxHeightDiskCache: _getOptimalCacheSize(height, imageType),
        memCacheWidth: _getOptimalCacheSize(width, imageType),
        memCacheHeight: _getOptimalCacheSize(height, imageType),
      ),
    );
  }
}
