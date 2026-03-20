import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:biux/shared/services/image_compression_service.dart';

/// Servicio para selección y subida de media (imágenes/videos) para la tienda.
class MediaUploadService {
  MediaUploadService();

  final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Duración máxima permitida para videos de productos (en segundos).
  static const int maxVideoDurationSeconds = 60;

  /// Selecciona imagen desde la cámara.
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      debugPrint('Error al abrir cámara: $e');
      return null;
    }
  }

  /// Selecciona imagen desde la galería.
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Error al abrir galería: $e');
      return null;
    }
  }

  /// Selecciona múltiples imágenes desde la galería.
  Future<List<XFile>> pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage();
    } catch (e) {
      debugPrint('Error al seleccionar múltiples imágenes: $e');
      return [];
    }
  }

  /// Sube una imagen a Firebase Storage.
  /// Comprime la imagen antes de subirla y retorna la URL de descarga.
  Future<String?> uploadImage(
    XFile image,
    String productId, {
    void Function(double)? onProgress,
  }) async {
    try {
      final imageFile = File(image.path);

      // Comprimir imagen antes de subir
      final compressedFile = await ImageCompressionService.compressImageFile(
        imageFile,
      );
      final fileToUpload = compressedFile ?? imageFile;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'product_img_$timestamp.jpg';
      final ref = _storage.ref().child(
        'shop/products/$productId/images/$fileName',
      );

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000',
        customMetadata: {
          'productId': productId,
          'compressed': 'true',
          'originalSize': '${await imageFile.length()}',
          'compressedSize': '${await fileToUpload.length()}',
        },
      );

      final uploadTask = ref.putFile(fileToUpload, metadata);

      // Reportar progreso si se proporciona callback
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Limpiar archivo comprimido temporal
      if (compressedFile != null && await compressedFile.exists()) {
        await compressedFile.delete();
      }

      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir imagen del producto: $e');
      return null;
    }
  }

  /// Selecciona video desde la cámara.
  Future<XFile?> pickVideoFromCamera() async {
    try {
      return await _picker.pickVideo(source: ImageSource.camera);
    } catch (e) {
      debugPrint('Error al grabar video: $e');
      return null;
    }
  }

  /// Selecciona video desde la galería.
  Future<XFile?> pickVideoFromGallery() async {
    try {
      return await _picker.pickVideo(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Error al seleccionar video: $e');
      return null;
    }
  }

  /// Valida que la duración del video esté dentro del límite.
  /// Retorna `true` si el video dura [maxVideoDurationSeconds] segundos o menos.
  Future<bool> validateVideoDuration(String videoPath) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      final duration = controller.value.duration;
      return duration.inSeconds <= maxVideoDurationSeconds;
    } catch (e) {
      debugPrint('Error al validar duración del video: $e');
      // En caso de error, permitimos el video para no bloquear al usuario
      return true;
    } finally {
      await controller?.dispose();
    }
  }

  /// Sube un video a Firebase Storage.
  /// Retorna la URL de descarga o `null` si falla.
  Future<String?> uploadVideo(
    XFile video,
    String productId, {
    void Function(double)? onProgress,
  }) async {
    try {
      final videoFile = File(video.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'product_vid_$timestamp.mp4';
      final ref = _storage.ref().child(
        'shop/products/$productId/videos/$fileName',
      );

      final metadata = SettableMetadata(
        contentType: 'video/mp4',
        cacheControl: 'public, max-age=31536000',
        customMetadata: {
          'productId': productId,
          'fileSize': '${await videoFile.length()}',
        },
      );

      final uploadTask = ref.putFile(videoFile, metadata);

      // Reportar progreso si se proporciona callback
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error al subir video del producto: $e');
      return null;
    }
  }
}
