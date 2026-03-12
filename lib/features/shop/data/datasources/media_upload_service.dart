import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para selección y subida de media (imágenes/videos) para la tienda.
/// STUB — pendiente de implementación real con Firebase Storage.
class MediaUploadService {
  MediaUploadService();

  final ImagePicker _picker = ImagePicker();

  /// Selecciona imagen desde la cámara.
  Future<XFile?> pickImageFromCamera() async {
    debugPrint(
      '⚠️ MediaUploadService.pickImageFromCamera() — STUB: sin implementar',
    );
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      debugPrint('Error al abrir cámara: $e');
      return null;
    }
  }

  /// Selecciona imagen desde la galería.
  Future<XFile?> pickImageFromGallery() async {
    debugPrint(
      '⚠️ MediaUploadService.pickImageFromGallery() — STUB: sin implementar',
    );
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Error al abrir galería: $e');
      return null;
    }
  }

  /// Selecciona múltiples imágenes desde la galería.
  Future<List<XFile>> pickMultipleImages() async {
    debugPrint(
      '⚠️ MediaUploadService.pickMultipleImages() — STUB: sin implementar',
    );
    try {
      return await _picker.pickMultiImage();
    } catch (e) {
      debugPrint('Error al seleccionar múltiples imágenes: $e');
      return [];
    }
  }

  /// Sube una imagen a Firebase Storage.
  Future<String?> uploadImage(
    XFile image,
    String productId, {
    void Function(double)? onProgress,
  }) async {
    debugPrint('⚠️ MediaUploadService.uploadImage() — STUB: sin implementar');
    // TODO: Implementar subida a Firebase Storage
    return null;
  }

  /// Selecciona video desde la cámara.
  Future<XFile?> pickVideoFromCamera() async {
    debugPrint(
      '⚠️ MediaUploadService.pickVideoFromCamera() — STUB: sin implementar',
    );
    try {
      return await _picker.pickVideo(source: ImageSource.camera);
    } catch (e) {
      debugPrint('Error al grabar video: $e');
      return null;
    }
  }

  /// Selecciona video desde la galería.
  Future<XFile?> pickVideoFromGallery() async {
    debugPrint(
      '⚠️ MediaUploadService.pickVideoFromGallery() — STUB: sin implementar',
    );
    try {
      return await _picker.pickVideo(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Error al seleccionar video: $e');
      return null;
    }
  }

  /// Valida que la duración del video esté dentro del límite.
  Future<bool> validateVideoDuration(String videoPath) async {
    debugPrint(
      '⚠️ MediaUploadService.validateVideoDuration() — STUB: sin implementar',
    );
    // TODO: Implementar validación real de duración
    return true;
  }

  /// Sube un video a Firebase Storage.
  Future<String?> uploadVideo(
    XFile video,
    String productId, {
    void Function(double)? onProgress,
  }) async {
    debugPrint('⚠️ MediaUploadService.uploadVideo() — STUB: sin implementar');
    // TODO: Implementar subida a Firebase Storage
    return null;
  }
}
