import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Servicio para subir imágenes y videos a Firebase Storage
class MediaUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Seleccionar imagen de la cámara
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      return null;
    }
  }

  /// Seleccionar imagen de la galería
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
      return null;
    }
  }

  /// Seleccionar múltiples imágenes de la galería
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return images;
    } catch (e) {
      debugPrint('Error al seleccionar imágenes: $e');
      return [];
    }
  }

  /// Seleccionar video de la cámara
  Future<XFile?> pickVideoFromCamera() async {
    try {
      return await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
    } catch (e) {
      debugPrint('Error al grabar video: $e');
      return null;
    }
  }

  /// Seleccionar video de la galería
  Future<XFile?> pickVideoFromGallery() async {
    try {
      return await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
    } catch (e) {
      debugPrint('Error al seleccionar video: $e');
      return null;
    }
  }

  /// Validar duración del video (máximo 30 segundos)
  Future<bool> validateVideoDuration(String videoPath) async {
    try {
      final controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      final duration = controller.value.duration;
      controller.dispose();

      return duration.inSeconds <= 30;
    } catch (e) {
      debugPrint('Error al validar duración del video: $e');
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
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
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

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${videoFile.name}';
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
