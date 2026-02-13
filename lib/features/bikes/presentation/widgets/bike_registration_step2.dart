import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';

/// Segundo paso del registro: Fotos
class BikeRegistrationStep2 extends StatefulWidget {
  const BikeRegistrationStep2({super.key});

  @override
  State<BikeRegistrationStep2> createState() => _BikeRegistrationStep2State();
}

class _BikeRegistrationStep2State extends State<BikeRegistrationStep2> {
  final ImagePicker _picker = ImagePicker();
  String? _mainPhoto;
  String? _serialPhoto;
  List<String> _additionalPhotos = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final bikeProvider = context.read<BikeProvider>();
    final data = bikeProvider.registrationData;

    _mainPhoto = data['mainPhoto'];
    _serialPhoto = data['serialPhoto'];
    _additionalPhotos = List<String>.from(data['additionalPhotos'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 8),

          // Foto Principal (Obligatoria)
          _buildPhotoSection(
            title: AppStrings.mainPhotoLabel,
            subtitle: 'Obligatoria',
            isRequired: true,
            currentPhoto: _mainPhoto,
            onPhotoSelected: (photo) {
              setState(() {
                _mainPhoto = photo;
              });
              context.read<BikeProvider>().updateRegistrationData(
                'mainPhoto',
                photo,
              );
            },
          ),

          const SizedBox(height: 24),

          // Foto del Número de Serie (Muy recomendada)
          _buildPhotoSection(
            title: AppStrings.serialPhotoLabel,
            subtitle: 'Muy recomendada',
            isRequired: false,
            currentPhoto: _serialPhoto,
            onPhotoSelected: (photo) {
              setState(() {
                _serialPhoto = photo;
              });
              context.read<BikeProvider>().updateRegistrationData(
                'serialPhoto',
                photo,
              );
            },
          ),

          const SizedBox(height: 24),

          // Fotos Adicionales (Opcionales)
          _buildAdditionalPhotosSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPhotoSection({
    required String title,
    required String subtitle,
    required bool isRequired,
    String? currentPhoto,
    required Function(String?) onPhotoSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorTokens.primary30,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isRequired ? ColorTokens.error95 : ColorTokens.warning95,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isRequired
                      ? ColorTokens.error30
                      : ColorTokens.warning30,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _pickImage(onPhotoSelected),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: currentPhoto != null
                    ? ColorTokens.primary30
                    : ColorTokens.neutral70,
                width: 2,
                style: currentPhoto != null
                    ? BorderStyle.solid
                    : BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: currentPhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: currentPhoto.startsWith('http')
                        ? Image.network(
                            currentPhoto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPhotoPlaceholder(true);
                            },
                          )
                        : Image.file(
                            File(currentPhoto),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPhotoPlaceholder(true);
                            },
                          ),
                  )
                : _buildPhotoPlaceholder(false),
          ),
        ),
        if (currentPhoto != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _pickImage(onPhotoSelected),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Cambiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: ColorTokens.primary30,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      onPhotoSelected(null);
                    });
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(
                    foregroundColor: ColorTokens.error50,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(bool hasError) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasError ? Icons.error_outline : Icons.add_a_photo,
          size: 48,
          color: hasError ? Colors.red : ColorTokens.neutral70,
        ),
        const SizedBox(height: 12),
        Text(
          hasError ? 'Error al cargar imagen' : 'Toca para agregar foto',
          style: TextStyle(
            fontSize: 14,
            color: hasError ? ColorTokens.error50 : ColorTokens.neutral70,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.additionalPhotosLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorTokens.primary30,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Opcional (2-4 fotos)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid de fotos adicionales
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount:
              _additionalPhotos.length + (_additionalPhotos.length < 4 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _additionalPhotos.length) {
              return _buildAdditionalPhotoCard(_additionalPhotos[index], index);
            } else {
              return _buildAddPhotoCard();
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalPhotoCard(String photo, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorTokens.primary30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: photo.startsWith('http')
                ? Image.network(
                    photo,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      );
                    },
                  )
                : Image.file(
                    File(photo),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _additionalPhotos.removeAt(index);
                });
                context.read<BikeProvider>().updateRegistrationData(
                  'additionalPhotos',
                  _additionalPhotos,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: ColorTokens.neutral100,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: _additionalPhotos.length < 4 ? _pickAdditionalImage : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorTokens.neutral70,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: ColorTokens.neutral70),
            const SizedBox(height: 8),
            Text(
              'Agregar foto',
              style: TextStyle(fontSize: 12, color: ColorTokens.neutral70),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(Function(String?) onPhotoSelected) async {
    // Mostrar diálogo para seleccionar fuente
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      onPhotoSelected(image.path);
    }
  }

  Future<void> _pickAdditionalImage() async {
    if (_additionalPhotos.length >= 4) return;

    // Mostrar diálogo para seleccionar fuente
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _additionalPhotos.add(image.path);
      });
      context.read<BikeProvider>().updateRegistrationData(
        'additionalPhotos',
        _additionalPhotos,
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: ColorTokens.primary30,
                ),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: ColorTokens.primary30,
                ),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
