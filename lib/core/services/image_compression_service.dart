import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import "package:flutter/foundation.dart";

/// Servicio para comprimir imÃ¡genes antes de subirlas a Firebase
/// Esto reduce significativamente los costos de almacenamiento y transferencia
class ImageCompressionService {
  static const int _maxWidth = 1080; // Ancho mÃ¡ximo en pÃ­xeles
  static const int _maxHeight = 1080; // Alto mÃ¡ximo en pÃ­xeles
  static const int _quality = 85; // Calidad de compresiÃ³n (0-100)
  static const int _maxFileSizeBytes = 500 * 1024; // 500KB mÃ¡ximo

  /// Comprime una imagen desde un archivo
  /// Retorna el archivo comprimido o null si ocurre un error
  static Future<File?> compressImageFile(File file) async {
    try {
      // Verificar si el archivo ya es pequeÃ±o
      final fileSize = await file.length();
      if (fileSize <= _maxFileSizeBytes) {
        return file; // No necesita compresiÃ³n
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

      // Verificar que la compresiÃ³n fue exitosa
      final compressedSize = await File(compressedFile.path).length();
      debugPrint(
        'Imagen comprimida: ${fileSize ~/ 1024}KB â†’ ${compressedSize ~/ 1024}KB',
      );

      return File(compressedFile.path);
    } on Exception catch (e) {
      debugPrint('Error comprimiendo imagen: $e');
      return file; // Retornar archivo original si falla
    }
  }

  /// Comprime imagen desde bytes (Ãºtil para imÃ¡genes desde red)
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
        'Bytes comprimidos: ${bytes.length ~/ 1024}KB â†’ ${compressedBytes.length ~/ 1024}KB',
      );
      return compressedBytes;
    } on Exception catch (e) {
      debugPrint('Error comprimiendo bytes: $e');
      return bytes;
    }
  }

  /// Comprime imagen para avatar (tamaÃ±o mÃ¡s pequeÃ±o)
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
        minWidth: 400, // TamaÃ±o mÃ¡s pequeÃ±o para avatares
        minHeight: 400,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      return compressedFile != null ? File(compressedFile.path) : file;
    } on Exception catch (e) {
      debugPrint('Error comprimiendo avatar: $e');
      return file;
    }
  }

  /// Comprime imagen para thumbnail (muy pequeÃ±a)
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
        minWidth: 200, // Muy pequeÃ±o para thumbnails
        minHeight: 200,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      return compressedFile != null ? File(compressedFile.path) : file;
    } on Exception catch (e) {
      debugPrint('Error comprimiendo thumbnail: $e');
      return file;
    }
  }

  /// Calcula el tamaÃ±o estimado despuÃ©s de la compresiÃ³n
  static Future<int> estimateCompressedSize(File file) async {
    final originalSize = await file.length();

    // EstimaciÃ³n basada en experiencia: JPEG con calidad 85 reduce ~60-80%
    if (originalSize > _maxFileSizeBytes) {
      return (_maxFileSizeBytes * 0.8).round();
    }

    return originalSize;
  }

  /// Verifica si una imagen necesita compresiÃ³n
  static Future<bool> needsCompression(File file) async {
    final fileSize = await file.length();
    return fileSize > _maxFileSizeBytes;
  }
}


