import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

        print(
          '🎥 Video seleccionado: ${video.path}, Tamaño: ${fileSizeMB.toStringAsFixed(2)}MB',
        );
      }

      return video;
    } catch (e) {
      print('❌ Error seleccionando video: $e');
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

      if (video != null) {
        print('🎥 Video grabado: ${video.path}');
      }

      return video;
    } catch (e) {
      print('❌ Error grabando video: $e');
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
      print('📤 Iniciando subida de video...');

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
        print('📤 Progreso subida: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Esperar a que termine la subida
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Video subido exitosamente: $downloadUrl');

      return VideoUploadResult(
        videoUrl: downloadUrl,
        fileName: fileName,
        sizeBytes: snapshot.totalBytes,
      );
    } catch (e) {
      print('❌ Error subiendo video: $e');
      throw VideoUploadException('Error subiendo video: $e');
    }
  }

  /// Genera thumbnail para un video (placeholder por ahora)
  Future<String?> generateThumbnail({
    required String videoUrl,
    required String userId,
  }) async {
    try {
      // PENDIENTE: Implementar generación real de thumbnail
      // Por ahora retornamos null para usar el video directamente
      print('🖼️ Generando thumbnail para: $videoUrl');
      return null;
    } catch (e) {
      print('❌ Error generando thumbnail: $e');
      return null;
    }
  }

  /// Valida la duración de un video
  Future<bool> validateVideoDuration(XFile videoFile) async {
    try {
      // PENDIENTE: Implementar validación real de duración
      // Por ahora asumimos que el picker ya limita la duración
      return true;
    } catch (e) {
      print('❌ Error validando duración: $e');
      return false;
    }
  }

  /// Obtiene información de un video
  Future<VideoInfo?> getVideoInfo(XFile videoFile) async {
    try {
      final file = File(videoFile.path);
      final sizeBytes = await file.length();

      return VideoInfo(
        path: videoFile.path,
        sizeBytes: sizeBytes,
        sizeMB: sizeBytes / (1024 * 1024),
        // PENDIENTE: Obtener duración y dimensiones reales
        durationSeconds: 30, // Placeholder
        width: 1080, // Placeholder
        height: 1920, // Placeholder
      );
    } catch (e) {
      print('❌ Error obteniendo info del video: $e');
      return null;
    }
  }

  /// Limpia archivos temporales de video
  Future<void> cleanupTempFiles(List<String> filePaths) async {
    for (final path in filePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          print('🧹 Archivo temporal eliminado: $path');
        }
      } catch (e) {
        print('⚠️ Error eliminando archivo temporal $path: $e');
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
