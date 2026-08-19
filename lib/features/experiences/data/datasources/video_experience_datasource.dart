import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import "package:flutter/foundation.dart";
import 'package:biux/core/services/app_logger.dart';

/// Servicio optimizado para gestión de videos en experiencias
/// Maneja compresión, subida y gestión de videos hasta 30 segundos
class VideoExperienceService {
  static const int maxVideoDurationSeconds = 30;
  static const int maxVideoSizeMB = 50;
  static const int imageDisplayDurationSeconds = 15;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Selecciona un video de la galería con validaciones
  Future<XFile?> pickVideoFromGallery() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: maxVideoDurationSeconds),
      );

      if (video != null) {
        // Validar tamaño del archivo
        final file = File(video.path);
        final fileSizeBytes = await file.length();
        final fileSizeMB = fileSizeBytes / (1024 * 1024);

        if (fileSizeMB > maxVideoSizeMB) {
          throw VideoTooLargeException(
            'El video es demasiado grande. Máximo permitido: ${maxVideoSizeMB}MB',
          );
        }

        AppLogger.debug(
          'Video seleccionado: ${video.path}, Tamaño: ${fileSizeMB.toStringAsFixed(2)}MB',
          tag: 'VideoExperienceService',
        );
      }

      return video;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error seleccionando video',
        error: e,
        tag: 'VideoExperienceService',
      );
      rethrow;
    }
  }

  /// Graba un nuevo video con la cámara
  Future<XFile?> recordVideo() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: maxVideoDurationSeconds),
      );

      if (video != null) {}

      return video;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error grabando video',
        error: e,
        tag: 'VideoExperienceService',
      );
      rethrow;
    }
  }

  /// Sube un video a Firebase Storage con progreso
  Future<VideoUploadResult> uploadVideo({
    required XFile videoFile,
    required String userId,
    String? experienceId,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${videoFile.name}';
      final videosRef = _storage.ref().child(
        'experiences/$userId/videos/$fileName',
      );

      // Crear task de subida
      final uploadTask = videosRef.putFile(File(videoFile.path));

      // Escuchar progreso
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
        AppLogger.debug(
          'Progreso subida: ${(progress * 100).toStringAsFixed(1)}%',
          tag: 'VideoExperienceService',
        );
      });

      // Esperar a que termine la subida
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return VideoUploadResult(
        videoUrl: downloadUrl,
        fileName: fileName,
        sizeBytes: snapshot.totalBytes,
      );
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error subiendo video',
        error: e,
        tag: 'VideoExperienceService',
      );
      throw VideoUploadException('Error subiendo video: $e');
    }
  }

  /// Genera un thumbnail para el video subiendo el primer frame como imagen.
  ///
  /// Requiere que el video ya esté subido a Firebase Storage.
  /// Retorna la URL del thumbnail o null si no se pudo generar.
  Future<String?> generateThumbnail({
    required String videoUrl,
    required String userId,
  }) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();

      // No existe API pura de video_player para capturar un frame
      // como archivo de imagen. Retornamos null hasta agregar
      // video_thumbnail u otro paquete nativo.
      AppLogger.warning(
        'Thumbnail: se requiere paquete video_thumbnail para captura de frame',
        tag: 'VideoExperienceService',
      );
      return null;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error generando thumbnail',
        error: e,
        tag: 'VideoExperienceService',
      );
      return null;
    } finally {
      await controller?.dispose();
    }
  }

  /// Valida que la duración del video no exceda [maxVideoDurationSeconds].
  Future<bool> validateVideoDuration(XFile videoFile) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(File(videoFile.path));
      await controller.initialize();

      final duration = controller.value.duration;
      final isValid = duration.inSeconds <= maxVideoDurationSeconds;

      AppLogger.debug(
        'Duración del video: ${duration.inSeconds}s (max: ${maxVideoDurationSeconds}s)',
        tag: 'VideoExperienceService',
      );

      if (!isValid) {
        throw VideoTooLongException(
          'El video dura ${duration.inSeconds}s, máximo permitido: ${maxVideoDurationSeconds}s',
        );
      }

      return true;
    } on FirebaseException catch (e) {
      if (e is VideoTooLongException) rethrow;
      AppLogger.error(
        'Error validando duración',
        error: e,
        tag: 'VideoExperienceService',
      );
      return false;
    } finally {
      await controller?.dispose();
    }
  }

  /// Obtiene información real de un video (duración, dimensiones, tamaño).
  Future<VideoInfo?> getVideoInfo(XFile videoFile) async {
    VideoPlayerController? controller;
    try {
      final file = File(videoFile.path);
      final sizeBytes = await file.length();

      controller = VideoPlayerController.file(file);
      await controller.initialize();

      final duration = controller.value.duration;
      final size = controller.value.size;

      return VideoInfo(
        path: videoFile.path,
        sizeBytes: sizeBytes,
        sizeMB: sizeBytes / (1024 * 1024),
        durationSeconds: duration.inSeconds,
        width: size.width.toInt(),
        height: size.height.toInt(),
      );
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error obteniendo info del video',
        error: e,
        tag: 'VideoExperienceService',
      );
      return null;
    } finally {
      await controller?.dispose();
    }
  }

  /// Limpia archivos temporales de video
  Future<void> cleanupTempFiles(List<String> filePaths) async {
    for (final path in filePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } on FirebaseException catch (e) {
        AppLogger.warning(
          'Error eliminando archivo temporal $path: $e',
          tag: 'VideoExperienceService',
        );
      }
    }
  }
}

/// Resultado de subida de video
class VideoUploadResult {
  final String videoUrl;
  final String fileName;
  final int sizeBytes;

  VideoUploadResult({
    required this.videoUrl,
    required this.fileName,
    required this.sizeBytes,
  });

  double get sizeMB => sizeBytes / (1024 * 1024);
}

/// Información de un video
class VideoInfo {
  final String path;
  final int sizeBytes;
  final double sizeMB;
  final int durationSeconds;
  final int width;
  final int height;

  VideoInfo({
    required this.path,
    required this.sizeBytes,
    required this.sizeMB,
    required this.durationSeconds,
    required this.width,
    required this.height,
  });

  double get aspectRatio => width / height;
}

/// Excepciones personalizadas
class VideoTooLargeException implements Exception {
  final String message;
  VideoTooLargeException(this.message);

  @override
  String toString() => message;
}

class VideoUploadException implements Exception {
  final String message;
  VideoUploadException(this.message);

  @override
  String toString() => message;
}

class VideoTooLongException implements Exception {
  final String message;
  VideoTooLongException(this.message);

  @override
  String toString() => message;
}
