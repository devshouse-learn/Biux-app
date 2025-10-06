import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Configuración de calidad de compresión
enum CompressionQuality {
  low(0.3, 'Baja', 'Menor tamaño, menor calidad'),
  medium(0.6, 'Media', 'Balance entre tamaño y calidad'),
  high(0.8, 'Alta', 'Mayor calidad, mayor tamaño'),
  original(1.0, 'Original', 'Sin compresión');

  const CompressionQuality(this.value, this.label, this.description);

  final double value;
  final String label;
  final String description;
}

/// Widget para configurar la calidad de compresión
class CompressionSettingsWidget extends StatelessWidget {
  final CompressionQuality selectedQuality;
  final Function(CompressionQuality) onQualityChanged;
  final bool showVideoSettings;
  final int maxVideoSeconds;
  final Function(int)? onMaxVideoSecondsChanged;

  const CompressionSettingsWidget({
    super.key,
    required this.selectedQuality,
    required this.onQualityChanged,
    this.showVideoSettings = false,
    this.maxVideoSeconds = 30,
    this.onMaxVideoSecondsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.tune, color: ColorTokens.primary50, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Configuración de compresión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calidad de compresión
          const Text(
            'Calidad de multimedia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Opciones de calidad
          ...CompressionQuality.values.map(
            (quality) => _QualityOption(
              quality: quality,
              isSelected: selectedQuality == quality,
              onTap: () => onQualityChanged(quality),
            ),
          ),

          // Configuración de video (si está habilitada)
          if (showVideoSettings) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              'Configuración de video',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // Duración máxima de video
            Row(
              children: [
                const Text(
                  'Duración máxima:',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onMaxVideoSecondsChanged != null)
                        GestureDetector(
                          onTap: () {
                            if (maxVideoSeconds > 10) {
                              onMaxVideoSecondsChanged!(maxVideoSeconds - 5);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${maxVideoSeconds}s',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      if (onMaxVideoSecondsChanged != null)
                        GestureDetector(
                          onTap: () {
                            if (maxVideoSeconds < 60) {
                              onMaxVideoSecondsChanged!(maxVideoSeconds + 5);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.add, size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Los videos se cortarán automáticamente si exceden esta duración',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para una opción de calidad individual
class _QualityOption extends StatelessWidget {
  final CompressionQuality quality;
  final bool isSelected;
  final VoidCallback onTap;

  const _QualityOption({
    required this.quality,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorTokens.primary50.withOpacity(0.1)
                  : Colors.transparent,
          border: Border.all(
            color: isSelected ? ColorTokens.primary50 : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ColorTokens.primary50 : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? ColorTokens.primary50 : Colors.transparent,
              ),
              child:
                  isSelected
                      ? const Center(
                        child: Icon(Icons.check, size: 10, color: Colors.white),
                      )
                      : null,
            ),

            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        quality.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected
                                  ? ColorTokens.primary50
                                  : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(quality.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  Text(
                    quality.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
