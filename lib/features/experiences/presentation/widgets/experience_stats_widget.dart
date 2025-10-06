import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Widget para mostrar estadísticas de la experiencia
class ExperienceStatsWidget extends StatelessWidget {
  final int mediaCount;
  final double totalSizeMB;
  final Duration? estimatedUploadTime;
  final bool isCompressing;
  final VoidCallback? onOptimize;

  const ExperienceStatsWidget({
    super.key,
    required this.mediaCount,
    required this.totalSizeMB,
    this.estimatedUploadTime,
    this.isCompressing = false,
    this.onOptimize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono y título
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: _getIconColor(), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Resumen de contenido',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (isCompressing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorTokens.primary50,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Estadísticas principales
          Row(
            children: [
              // Cantidad de multimedia
              Expanded(
                child: _StatItem(
                  icon: Icons.photo_library,
                  label: 'Archivos',
                  value: mediaCount.toString(),
                  color: ColorTokens.primary50,
                ),
              ),

              // Tamaño total
              Expanded(
                child: _StatItem(
                  icon: Icons.storage,
                  label: 'Tamaño',
                  value: _formatSize(totalSizeMB),
                  color: _getSizeColor(),
                ),
              ),

              // Tiempo estimado de subida
              if (estimatedUploadTime != null)
                Expanded(
                  child: _StatItem(
                    icon: Icons.cloud_upload,
                    label: 'Subida',
                    value: _formatUploadTime(estimatedUploadTime!),
                    color: _getUploadTimeColor(),
                  ),
                ),
            ],
          ),

          // Recomendación de optimización
          if (_shouldShowOptimizationTip()) ...[
            const SizedBox(height: 12),
            _buildOptimizationTip(),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (totalSizeMB > 50) return ColorTokens.warning10.withOpacity(0.1);
    if (totalSizeMB > 20) return ColorTokens.secondary10.withOpacity(0.1);
    return ColorTokens.success10.withOpacity(0.1);
  }

  Color _getBorderColor() {
    if (totalSizeMB > 50) return ColorTokens.warning40.withOpacity(0.3);
    if (totalSizeMB > 20) return ColorTokens.secondary50.withOpacity(0.3);
    return ColorTokens.success40.withOpacity(0.3);
  }

  Color _getIconColor() {
    if (totalSizeMB > 50) return ColorTokens.warning40;
    if (totalSizeMB > 20) return ColorTokens.secondary50;
    return ColorTokens.success40;
  }

  Color _getSizeColor() {
    if (totalSizeMB > 50) return ColorTokens.warning40;
    if (totalSizeMB > 20) return ColorTokens.secondary50;
    return ColorTokens.success40;
  }

  Color _getUploadTimeColor() {
    if (estimatedUploadTime == null) return Colors.grey;
    final minutes = estimatedUploadTime!.inMinutes;
    if (minutes > 5) return ColorTokens.warning40;
    if (minutes > 2) return ColorTokens.secondary50;
    return ColorTokens.success40;
  }

  bool _shouldShowOptimizationTip() {
    return totalSizeMB > 20 && onOptimize != null && !isCompressing;
  }

  Widget _buildOptimizationTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorTokens.warning10.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorTokens.warning40.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: ColorTokens.warning40, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tu contenido es algo pesado. ¿Quieres optimizarlo para una subida más rápida?',
              style: TextStyle(fontSize: 12, color: ColorTokens.warning40),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onOptimize,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(
              'Optimizar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorTokens.warning40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSize(double sizeMB) {
    if (sizeMB < 1) {
      return '${(sizeMB * 1024).toInt()} KB';
    } else if (sizeMB < 1024) {
      return '${sizeMB.toStringAsFixed(1)} MB';
    } else {
      return '${(sizeMB / 1024).toStringAsFixed(1)} GB';
    }
  }

  String _formatUploadTime(Duration duration) {
    if (duration.inMinutes < 1) {
      return '< 1 min';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }
}

/// Widget para mostrar un item de estadística individual
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget compacto para mostrar solo el tamaño total
class CompactExperienceStatsWidget extends StatelessWidget {
  final int mediaCount;
  final double totalSizeMB;
  final bool isCompressing;

  const CompactExperienceStatsWidget({
    super.key,
    required this.mediaCount,
    required this.totalSizeMB,
    this.isCompressing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompressing) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorTokens.primary50,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          Icon(Icons.photo_library, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '$mediaCount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(width: 8),

          Icon(Icons.storage, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            _formatSize(totalSizeMB),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSize(double sizeMB) {
    if (sizeMB < 1) {
      return '${(sizeMB * 1024).toInt()}KB';
    } else if (sizeMB < 1024) {
      return '${sizeMB.toStringAsFixed(1)}MB';
    } else {
      return '${(sizeMB / 1024).toStringAsFixed(1)}GB';
    }
  }
}
