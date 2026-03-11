import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Servicio para subir imágenes y videos a Firebase Storage
/// Optimizado para funcionar en Web y Mobile
class MediaUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Seleccionar imagen de la cámara (solo mobile)
  Future<XFile?> pickImageFromCamera() async {
    if (kIsWeb) {
      debugPrint('⚠️ Cámara no disponible en Web');
      return null;
    }

    try {
      debugPrint('📸 Abriendo cámara...');
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint('✅ Foto tomada: ${image.name}');
      }
      return image;
    } catch (e) {
      debugPrint('❌ Error al tomar foto: $e');
      return null;
    }
  }

  /// Seleccionar imagen de la galería (web y mobile)
  Future<XFile?> pickImageFromGallery() async {
    try {
      debugPrint('�️ Abriendo selector de imágenes...');

      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint(
          '✅ Imagen seleccionada: ${image.name} (${await image.length()} bytes)',
        );
        return image;
      } else {
        debugPrint('⚠️ No se seleccionó ninguna imagen');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error al seleccionar imagen: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Seleccionar múltiples imágenes de la galería (web y mobile)
  Future<List<XFile>> pickMultipleImages() async {
    try {
      debugPrint('�️ Abriendo selector múltiple...');

      final images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      debugPrint('✅ ${images.length} imágenes seleccionadas');
      for (var img in images) {
        final size = await img.length();
        debugPrint('  - ${img.name}: $size bytes');
      }

      return images;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al seleccionar múltiples imágenes: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Seleccionar video de la cámara (solo mobile)
  Future<XFile?> pickVideoFromCamera() async {
    if (kIsWeb) {
      debugPrint('⚠️ Grabar video no disponible en Web');
      return null;
    }

    try {
      debugPrint('🎥 Abriendo cámara de video...');
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        debugPrint('✅ Video grabado: ${video.name}');
      }
      return video;
    } catch (e) {
      debugPrint('❌ Error al grabar video: $e');
      return null;
    }
  }

  /// Seleccionar video de la galería (web y mobile)
  Future<XFile?> pickVideoFromGallery() async {
    try {
      debugPrint('🎥 Abriendo selector de videos...');

      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        debugPrint('✅ Video seleccionado: ${video.name}');
      } else {
        debugPrint('⚠️ No se seleccionó ningún video');
      }
      return video;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al seleccionar video: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Validar duración del video (máximo 30 segundos)
  Future<bool> validateVideoDuration(String videoPath) async {
    if (kIsWeb) {
      // En web no podemos validar fácilmente, asumimos válido
      debugPrint(
        '⚠️ Validación de duración no disponible en Web (asumiendo válido)',
      );
      return true;
    }

    try {
      final controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      final duration = controller.value.duration;
      controller.dispose();

      final isValid = duration.inSeconds <= 30;
      debugPrint(
        '⏱️ Duración del video: ${duration.inSeconds}s - Válido: $isValid',
      );
      return isValid;
    } catch (e) {
      debugPrint('❌ Error al validar duración del video: $e');
      return false;
    }
  }

  /// Subir imagen a Firebase Storage
  Future<String?> uploadImage(
    XFile imageFile,
    String productId, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final ref = _storage.ref().child('products/$productId/images/$fileName');

      final uploadTask = ref.putFile(File(imageFile.path));

      // Escuchar progreso
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      return null;
    }
  }

  /// Subir video a Firebase Storage
  Future<String?> uploadVideo(
    XFile videoFile,
    String productId, {
    Function(double)? onProgress,
  }) async {
    try {
      // Validar duración antes de subir
      final isValid = await validateVideoDuration(videoFile.path);
      if (!isValid) {
        debugPrint('Video excede los 30 segundos');
        return null;
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${videoFile.name}';
      final ref = _storage.ref().child('products/$productId/videos/$fileName');

      final uploadTask = ref.putFile(File(videoFile.path));

      // Escuchar progreso
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir video: $e');
      return null;
    }
  }

  /// Eliminar imagen de Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error al eliminar imagen: $e');
      return false;
    }
  }

  /// Eliminar video de Firebase Storage
  Future<bool> deleteVideo(String videoUrl) async {
    try {
      final ref = _storage.refFromURL(videoUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error al eliminar video: $e');
      return false;
    }
  }

  /// Limpiar todos los medios de un producto
  Future<void> cleanupProductMedia(String productId) async {
    try {
      // Eliminar imágenes
      final imagesRef = _storage.ref().child('products/$productId/images');
      final imagesList = await imagesRef.listAll();
      for (var item in imagesList.items) {
        await item.delete();
      }

      // Eliminar videos
      final videosRef = _storage.ref().child('products/$productId/videos');
      final videosList = await videosRef.listAll();
      for (var item in videosList.items) {
        await item.delete();
      }
    } catch (e) {
      debugPrint('Error al limpiar medios: $e');
    }
  }
}
