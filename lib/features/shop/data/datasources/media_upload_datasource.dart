import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Servicio para subir imÃ¡genes y videos a Firebase Storage
/// Optimizado para funcionar en Web y Mobile
class MediaUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Seleccionar imagen de la cÃ¡mara (solo mobile)
  Future<XFile?> pickImageFromCamera() async {
    if (kIsWeb) {
      debugPrint('âš ï¸ CÃ¡mara no disponible en Web');
      return null;
    }

    try {
      debugPrint('ðŸ“¸ Abriendo cÃ¡mara...');
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint('âœ… Foto tomada: ${image.name}');
      }
      return image;
    } on FirebaseException catch (e) {
      debugPrint('âŒ Error al tomar foto: $e');
      return null;
    }
  }

  /// Seleccionar imagen de la galerÃ­a (web y mobile)
  Future<XFile?> pickImageFromGallery() async {
    try {
      debugPrint('ï¿½ï¸ Abriendo selector de imÃ¡genes...');

      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint(
          'âœ… Imagen seleccionada: ${image.name} (${await image.length()} bytes)',
        );
        return image;
      } else {
        debugPrint('âš ï¸ No se seleccionÃ³ ninguna imagen');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('âŒ Error al seleccionar imagen: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Seleccionar mÃºltiples imÃ¡genes de la galerÃ­a (web y mobile)
  Future<List<XFile>> pickMultipleImages() async {
    try {
      debugPrint('ï¿½ï¸ Abriendo selector mÃºltiple...');

      final images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      debugPrint('âœ… ${images.length} imÃ¡genes seleccionadas');
      for (var img in images) {
        final size = await img.length();
        debugPrint('  - ${img.name}: $size bytes');
      }

      return images;
    } catch (e, stackTrace) {
      debugPrint('âŒ Error al seleccionar mÃºltiples imÃ¡genes: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Seleccionar video de la cÃ¡mara (solo mobile)
  Future<XFile?> pickVideoFromCamera() async {
    if (kIsWeb) {
      debugPrint('âš ï¸ Grabar video no disponible en Web');
      return null;
    }

    try {
      debugPrint('ðŸŽ¥ Abriendo cÃ¡mara de video...');
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        debugPrint('âœ… Video grabado: ${video.name}');
      }
      return video;
    } on FirebaseException catch (e) {
      debugPrint('âŒ Error al grabar video: $e');
      return null;
    }
  }

  /// Seleccionar video de la galerÃ­a (web y mobile)
  Future<XFile?> pickVideoFromGallery() async {
    try {
      debugPrint('ðŸŽ¥ Abriendo selector de videos...');

      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        debugPrint('âœ… Video seleccionado: ${video.name}');
      } else {
        debugPrint('âš ï¸ No se seleccionÃ³ ningÃºn video');
      }
      return video;
    } catch (e, stackTrace) {
      debugPrint('âŒ Error al seleccionar video: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Validar duraciÃ³n del video (mÃ¡ximo 30 segundos)
  Future<bool> validateVideoDuration(String videoPath) async {
    if (kIsWeb) {
      // En web no podemos validar fÃ¡cilmente, asumimos vÃ¡lido
      debugPrint(
        'âš ï¸ ValidaciÃ³n de duraciÃ³n no disponible en Web (asumiendo vÃ¡lido)',
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
        'â±ï¸ DuraciÃ³n del video: ${duration.inSeconds}s - VÃ¡lido: $isValid',
      );
      return isValid;
    } on FirebaseException catch (e) {
      debugPrint('âŒ Error al validar duraciÃ³n del video: $e');
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
    } on FirebaseException catch (e) {
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
      // Validar duraciÃ³n antes de subir
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
    } on FirebaseException catch (e) {
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
    } on FirebaseException catch (e) {
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
    } on FirebaseException catch (e) {
      debugPrint('Error al eliminar video: $e');
      return false;
    }
  }

  /// Limpiar todos los medios de un producto
  Future<void> cleanupProductMedia(String productId) async {
    try {
      // Eliminar imÃ¡genes
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
    } on FirebaseException catch (e) {
      debugPrint('Error al limpiar medios: $e');
    }
  }
}

