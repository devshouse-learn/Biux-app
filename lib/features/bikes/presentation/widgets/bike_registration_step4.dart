import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/shared/widgets/photo_viewer.dart';

/// Cuarto paso del registro: Generar QR y finalizar
class BikeRegistrationStep4 extends StatelessWidget {
  const BikeRegistrationStep4({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BikeProvider>(
      builder: (context, bikeProvider, child) {
        final l = Provider.of<LocaleNotifier>(context, listen: false);
        final registrationData = bikeProvider.registrationData;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),

              // Título de revisión
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorTokens.primary95,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorTokens.primary80),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.fact_check_outlined,
                      size: 48,
                      color: ColorTokens.primary30,
                    ),
                    SizedBox(height: 16),
                    Text(
                      l.t('step4_title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.primary30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      l.t('step4_description'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorTokens.neutral30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Resumen de la bicicleta
              _buildBikeSummary(context, registrationData),

              const SizedBox(height: 24),

              // Nota informativa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.t('finalize_bike_info'),
                        style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBikeSummary(BuildContext context, Map<String, dynamic> data) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final bikeType = data['type'] as BikeType?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.neutral90),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_bike,
                color: ColorTokens.primary30,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                l.t('bike_summary_title'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.primary30,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Fotos
          _buildPhotosSection(context, data),

          SizedBox(height: 16),

          // Información básica
          _buildInfoRow(l.t('brand_colon'), data['brand'] ?? ''),
          _buildInfoRow(l.t('model_colon'), data['model'] ?? ''),
          _buildInfoRow(l.t('year_colon'), data['year']?.toString() ?? ''),
          _buildInfoRow(l.t('color_colon'), data['color'] ?? ''),
          _buildInfoRow(l.t('size_colon'), data['size'] ?? ''),
          _buildInfoRow(
            l.t('type_colon'),
            bikeType != null ? l.t(bikeType.displayName) : '',
          ),
          _buildInfoRow(l.t('city_colon'), data['city'] ?? ''),

          if (data['neighborhood'] != null &&
              data['neighborhood'].toString().isNotEmpty)
            _buildInfoRow(l.t('neighborhood_colon'), data['neighborhood']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorTokens.neutral70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(BuildContext context, Map<String, dynamic> data) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final mainPhoto = data['mainPhoto'] as String?;
    final serialPhoto = data['serialPhoto'] as String?;
    final additionalPhotos = data['additionalPhotos'] as List<dynamic>?;
    final invoice = data['invoice'] as String?;

    // Lista de todas las fotos disponibles
    final photos = <Map<String, String>>[];

    if (mainPhoto != null) {
      photos.add({'path': mainPhoto, 'label': l.t('main_photo')});
    }
    if (serialPhoto != null) {
      photos.add({'path': serialPhoto, 'label': l.t('serial_number_short')});
    }
    if (additionalPhotos != null && additionalPhotos.isNotEmpty) {
      for (int i = 0; i < additionalPhotos.length; i++) {
        photos.add({
          'path': additionalPhotos[i],
          'label': '${l.t('photo')} ${i + 1}',
        });
      }
    }
    if (invoice != null) {
      photos.add({'path': invoice, 'label': l.t('invoice')});
    }

    if (photos.isEmpty) return const SizedBox.shrink();

    // Extraer solo las rutas para el visor
    final photoPaths = photos.map((p) => p['path']!).toList();
    final photoLabels = photos.map((p) => p['label']!).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.t('photos'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorTokens.primary30,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.zoom_in, size: 16, color: ColorTokens.neutral60),
            SizedBox(width: 4),
            Text(
              l.t('tap_to_enlarge_photo'),
              style: TextStyle(fontSize: 12, color: ColorTokens.neutral60),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: photos.asMap().entries.map((entry) {
            final index = entry.key;
            final photo = entry.value;
            return GestureDetector(
              onTap: () {
                context.openPhotoViewer(
                  photoUrls: photoPaths,
                  initialIndex: index,
                  photoLabels: photoLabels,
                );
              },
              child: _buildPhotoCard(photo['path']!, photo['label']!),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String photoPath, String label) {
    final isUrl = photoPath.startsWith('http');

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isUrl
              ? Image.network(
                  photoPath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                )
              : Image.file(
                  File(photoPath),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: ColorTokens.neutral70),
        ),
      ],
    );
  }
}
