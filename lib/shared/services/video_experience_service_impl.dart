/// Re-exporta el servicio de video implementado en el feature de experiencias.
export 'package:biux/features/experiences/data/datasources/video_experience_datasource.dart';

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoExperienceServiceImpl {
  /// Genera un thumbnail del video capturando el primer frame.
  /// Retorna null si no se puede generar (fallback seguro).
  Future<File?> generateThumbnail(File videoFile) async {
    try {
      // Intentar obtener info del video para validar que es procesable
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      await controller.dispose();

      // El video es válido; la generación de thumbnail real
      // requiere un paquete nativo (video_thumbnail). Por ahora
      // retornamos null y la UI usa un placeholder de video.
      debugPrint('🎬 Video válido para thumbnail: ${videoFile.path}');
      return null;
    } catch (e) {
      debugPrint('⚠️ Error generando thumbnail: $e');
      return null;
    }
  }

  /// Valida que la duración del video no exceda el máximo permitido.
  Future<bool> validateDuration(
    File videoFile, {
    required Duration maxDuration,
  }) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      final duration = controller.value.duration;
      await controller.dispose();

      final isValid = duration <= maxDuration;

      if (!isValid) {
        debugPrint(
          '⚠️ Video demasiado largo: ${duration.inSeconds}s '
          '(máximo: ${maxDuration.inSeconds}s)',
        );
      }

      return isValid;
    } catch (e) {
      debugPrint('⚠️ Error validando duración del video: $e');
      return false;
    }
  }

  /// Obtiene la duración del video en segundos.
  Future<int> getVideoDurationSeconds(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      final seconds = controller.value.duration.inSeconds;
      await controller.dispose();
      return seconds;
    } catch (e) {
      debugPrint('⚠️ Error obteniendo duración: $e');
      return 0;
    }
  }

  /// Obtiene el tamaño del video en MB.
  Future<double> getVideoSizeMB(File videoFile) async {
    try {
      final bytes = await videoFile.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      debugPrint('⚠️ Error obteniendo tamaño: $e');
      return 0;
    }
  }
}
