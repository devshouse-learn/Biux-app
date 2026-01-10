import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget para seleccionar y recortar imagen de perfil en formato cuadrado
/// La foto es OPCIONAL - el usuario puede dejar su perfil sin foto
class ProfileImagePicker extends StatefulWidget {
  final String? currentImageUrl;
  final Function(File) onImageSelected;
  final double size;

  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.size = 120,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _selectedImage;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de perfil
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ColorTokens.primary30, width: 3),
            boxShadow: [
              BoxShadow(
                color: ColorTokens.neutral0.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(child: _buildImageContent()),
        ),

        // Indicador de carga
        if (_isProcessing)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorTokens.neutral0.withValues(alpha: 0.7),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorTokens.primary50,
                  ),
                ),
              ),
            ),
          ),

        // Botón de edición
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isProcessing ? null : _showImageOptions,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorTokens.primary50,
                border: Border.all(color: ColorTokens.neutral100, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: ColorTokens.neutral0.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: ColorTokens.neutral100,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      );
    }

    if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      return Image.network(
        widget.currentImageUrl!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: ColorTokens.neutral20,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorTokens.primary50,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: ColorTokens.neutral30,
      child: const Icon(Icons.person, size: 40, color: ColorTokens.neutral60),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle del modal
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.neutral40,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.neutral90,
                  ),
                ),
                const SizedBox(height: 20),

                // Opciones
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary50.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: ColorTokens.primary50,
                    ),
                  ),
                  title: const Text('Tomar foto'),
                  subtitle: const Text('Usar la cámara'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorTokens.secondary50.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: ColorTokens.secondary50,
                    ),
                  ),
                  title: const Text('Seleccionar de galería'),
                  subtitle: const Text('Elegir foto existente'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),

                if (_selectedImage != null ||
                    (widget.currentImageUrl != null &&
                        widget.currentImageUrl!.isNotEmpty))
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorTokens.error50.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: ColorTokens.error50,
                      ),
                    ),
                    title: const Text('Eliminar foto'),
                    subtitle: const Text('Usar avatar por defecto'),
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final croppedFile = await _cropToSquare(File(pickedFile.path));
        if (croppedFile != null) {
          setState(() {
            _selectedImage = croppedFile;
          });
          widget.onImageSelected(croppedFile);
        }
      }
    } catch (e) {
      print('Error seleccionando imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al seleccionar la imagen'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Recortar imagen a formato cuadrado centrado
  Future<File?> _cropToSquare(File imageFile) async {
    try {
      // Leer bytes de la imagen
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decodificar imagen
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      // Determinar el tamaño cuadrado (el menor entre ancho y alto)
      final int squareSize = originalImage.width < originalImage.height
          ? originalImage.width
          : originalImage.height;

      // Calcular offset para centrar el recorte
      final int offsetX = (originalImage.width - squareSize) ~/ 2;
      final int offsetY = (originalImage.height - squareSize) ~/ 2;

      // Recortar imagen
      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: offsetX,
        y: offsetY,
        width: squareSize,
        height: squareSize,
      );

      // Redimensionar para optimizar tamaño
      final img.Image resizedImage = img.copyResize(
        croppedImage,
        width: 512,
        height: 512,
      );

      // Codificar de vuelta a bytes
      final List<int> encodedBytes = img.encodeJpg(resizedImage, quality: 85);

      // Crear archivo temporal
      final String originalPath = imageFile.path;
      final String extension = originalPath.split('.').last;
      final String newPath = originalPath.replaceAll(
        '.$extension',
        '_square.jpg',
      );

      final File croppedFile = File(newPath);
      await croppedFile.writeAsBytes(encodedBytes);

      return croppedFile;
    } catch (e) {
      print('Error recortando imagen: $e');
      return null;
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    // Aquí podrías llamar un callback para eliminar la imagen del servidor
  }
}
