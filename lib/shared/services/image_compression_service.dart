import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import "package:flutter/foundation.dart";

/// Servicio para comprimir imágenes antes de subirlas a Firebase
/// Esto reduce significativamente los costos de almacenamiento y transferencia
class ImageCompressionService {
  static const int _maxWidth = 1080; // Ancho máximo en píxeles
  static const int _maxHeight = 1080; // Alto máximo en píxeles
  static const int _quality = 85; // Calidad de compresión (0-100)
  static const int _maxFileSizeBytes = 500 * 1024; // 500KB máximo

  /// Comprime una imagen desde un archivo
  /// Retorna el archivo comprimido o null si ocurre un error
  static Future<File?> compressImageFile(File file) async {
    try {
      // Verificar si el archivo ya es pequeño
      final fileSize = await file.length();
      if (fileSize <= _maxFileSizeBytes) {
        return file; // No necesita compresión
      }

      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Comprimir imagen
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: _maxWidth,
        minHeight: _maxHeight,
        quality: _quality,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) return file;

      // Verificar que la compresión fue exitosa
      final compressedSize = await File(compressedFile.path).length();
      debugPrint(
        'Imagen comprimida: ${fileSize ~/ 1024}KB → ${compressedSize ~/ 1024}KB',
      );

      return File(compressedFile.path);
    } catch (e) {
      debugPrint('Error comprimiendo imagen: $e');
      return file; // Retornar archivo original si falla
    }
  }

  /// Comprime imagen desde bytes (útil para imágenes desde red)
  static Future<Uint8List?> compressImageBytes(Uint8List bytes) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: _maxWidth,
        minHeight: _maxHeight,
        quality: _quality,
        format: CompressFormat.jpeg,
      );

      debugPrint(
        'Bytes comprimidos: ${bytes.length ~/ 1024}KB → ${compressedBytes.length ~/ 1024}KB',
      );
      return compressedBytes;
    } catch (e) {
      debugPrint('Error comprimiendo bytes: $e');
      return bytes;
    }
  }

  /// Comprime imagen para avatar (tamaño más pequeño)
  static Future<File?> compressAvatarImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 400, // Tamaño más pequeño para avatares
        minHeight: 400,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      return compressedFile != null ? File(compressedFile.path) : file;
    } catch (e) {
      debugPrint('Error comprimiendo avatar: $e');
      return file;
    }
  }

  /// Comprime imagen para thumbnail (muy pequeña)
  static Future<File?> compressThumbnail(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 200, // Muy pequeño para thumbnails
        minHeight: 200,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      return compressedFile != null ? File(compressedFile.path) : file;
    } catch (e) {
      debugPrint('Error comprimiendo thumbnail: $e');
      return file;
    }
  }

  /// Calcula el tamaño estimado después de la compresión
  static Future<int> estimateCompressedSize(File file) async {
    final originalSize = await file.length();

    // Estimación basada en experiencia: JPEG con calidad 85 reduce ~60-80%
    if (originalSize > _maxFileSizeBytes) {
      return (_maxFileSizeBytes * 0.8).round();
    }

    return originalSize;
  }

  /// Verifica si una imagen necesita compresión
  static Future<bool> needsCompression(File file) async {
    final fileSize = await file.length();
    return fileSize > _maxFileSizeBytes;
  }
}
