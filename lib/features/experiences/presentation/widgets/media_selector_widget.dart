import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Widget para seleccionar el tipo de multimedia a agregar
class MediaSelectorWidget extends StatelessWidget {
  final bool allowVideo;
  final VoidCallback onImageFromGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback? onVideoFromGallery;
  final VoidCallback? onRecordVideo;

  const MediaSelectorWidget({
    super.key,
    required this.allowVideo,
    required this.onImageFromGallery,
    required this.onTakePhoto,
    this.onVideoFromGallery,
    this.onRecordVideo,
  });

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            l.t('add_content'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),

          // Botones para imágenes
          Row(
            children: [
              Expanded(
                child: _MediaButton(
                  icon: Icons.photo_library,
                  label: l.t('gallery'),
                  onTap: onImageFromGallery,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MediaButton(
                  icon: Icons.camera_alt,
                  label: l.t('camera'),
                  onTap: onTakePhoto,
                ),
              ),
            ],
          ),

          // ✅ VIDEOS DESHABILITADOS - Solo se permiten fotos
          // if (allowVideo &&
          //     (onVideoFromGallery != null || onRecordVideo != null)) ...[
          //   const SizedBox(height: 8),
          //   Row(
          //     children: [
          //       if (onVideoFromGallery != null)
          //         Expanded(
          //           child: _MediaButton(
          //             icon: Icons.video_library,
          //             label: 'Video',
          //             onTap: onVideoFromGallery!,
          //             color: ColorTokens.secondary50,
          //           ),
          //         ),
          //       if (onVideoFromGallery != null && onRecordVideo != null)
          //         const SizedBox(width: 8),
          //       if (onRecordVideo != null)
          //         Expanded(
          //           child: _MediaButton(
          //             icon: Icons.videocam,
          //             label: 'Grabar',
          //             onTap: onRecordVideo!,
          //             color: ColorTokens.secondary50,
          //           ),
          //         ),
          //     ],
          //   ),
          // ],
        ],
      ),
    );
  }
}

/// Botón individual para selección de multimedia
class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = ColorTokens.primary50;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: buttonColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
            color: buttonColor.withValues(alpha: 0.05),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: buttonColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: buttonColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
