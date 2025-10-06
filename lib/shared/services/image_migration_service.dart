import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../services/image_compression_service.dart';
import '../services/optimized_storage_service.dart';

/// Servicio para migrar imágenes existentes al sistema optimizado
/// Esto permite reducir costos de imágenes ya almacenadas en Firebase
class ImageMigrationService {
  static const int _batchSize = 10; // Procesar de a 10 imágenes por lote

  /// Migra todas las imágenes de un usuario al sistema optimizado
  static Future<Map<String, dynamic>> migrateUserImages({
    required String userId,
    required List<String> imageUrls,
    VoidCallback? onProgress,
  }) async {
    final results = <String, dynamic>{
      'migrated': <String>[],
      'failed': <String>[],
      'originalSizeBytes': 0,
      'compressedSizeBytes': 0,
      'savingsBytes': 0,
      'savingsPercentage': 0.0,
    };

    for (int i = 0; i < imageUrls.length; i += _batchSize) {
      final batch = imageUrls.skip(i).take(_batchSize).toList();

      for (final imageUrl in batch) {
        try {
          final migrationResult = await _migrateImage(
            imageUrl: imageUrl,
            entityId: userId,
            imageType: 'gallery',
            uploadFunction:
                (file, type, id) => OptimizedStorageService.uploadUserImage(
                  userId: id,
                  imageFile: file,
                  imageType: type,
                ),
          );

          if (migrationResult['success']) {
            results['migrated'].add(migrationResult['newUrl']);
            results['originalSizeBytes'] +=
                migrationResult['originalSize'] as int;
            results['compressedSizeBytes'] +=
                migrationResult['compressedSize'] as int;
          } else {
            results['failed'].add(imageUrl);
          }
        } catch (e) {
          debugPrint('Error migrando imagen $imageUrl: $e');
          results['failed'].add(imageUrl);
        }

        onProgress?.call();
      }

      // Pausa entre lotes para no sobrecargar Firebase
      await Future.delayed(Duration(milliseconds: 500));
    }

    // Calcular ahorros
    final originalSize = results['originalSizeBytes'] as int;
    final compressedSize = results['compressedSizeBytes'] as int;
    results['savingsBytes'] = originalSize - compressedSize;
    results['savingsPercentage'] =
        originalSize > 0
            ? ((originalSize - compressedSize) / originalSize * 100)
            : 0.0;

    return results;
  }

  /// Migra imágenes de grupo (portada + galería)
  static Future<Map<String, dynamic>> migrateGroupImages({
    required String groupId,
    required Map<String, String>
    imageMap, // {'cover': url, 'gallery1': url, ...}
    VoidCallback? onProgress,
  }) async {
    final results = <String, dynamic>{
      'migrated': <String, String>{}, // tipo -> nueva URL
      'failed': <String>[],
      'originalSizeBytes': 0,
      'compressedSizeBytes': 0,
    };

    for (final entry in imageMap.entries) {
      try {
        final imageType = entry.key;
        final imageUrl = entry.value;

        final migrationResult = await _migrateImage(
          imageUrl: imageUrl,
          entityId: groupId,
          imageType: imageType.contains('cover') ? 'cover' : 'gallery',
          uploadFunction: (file, type, id) async {
            final result = await OptimizedStorageService.uploadGroupImage(
              groupId: id,
              imageFile: file,
              imageType: type,
            );
            return result?['main']; // Retornar URL principal
          },
        );

        if (migrationResult['success']) {
          results['migrated'][imageType] = migrationResult['newUrl'];
          results['originalSizeBytes'] +=
              migrationResult['originalSize'] as int;
          results['compressedSizeBytes'] +=
              migrationResult['compressedSize'] as int;
        } else {
          results['failed'].add(imageUrl);
        }
      } catch (e) {
        debugPrint('Error migrando imagen de grupo ${entry.key}: $e');
        results['failed'].add(entry.value);
      }

      onProgress?.call();
      await Future.delayed(Duration(milliseconds: 300));
    }

    return results;
  }

  /// Función principal de migración de una imagen individual
  static Future<Map<String, dynamic>> _migrateImage({
    required String imageUrl,
    required String entityId,
    required String imageType,
    required Future<String?> Function(File file, String type, String id)
    uploadFunction,
  }) async {
    try {
      // 1. Descargar imagen original
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return {'success': false, 'error': 'Failed to download image'};
      }

      final originalBytes = response.bodyBytes;
      final originalSize = originalBytes.length;

      // 2. Comprimir imagen
      final compressedBytes = await ImageCompressionService.compressImageBytes(
        originalBytes,
      );
      if (compressedBytes == null) {
        return {'success': false, 'error': 'Failed to compress image'};
      }

      // 3. Crear archivo temporal
      final tempFile = await _createTempFile(compressedBytes);
      if (tempFile == null) {
        return {'success': false, 'error': 'Failed to create temp file'};
      }

      // 4. Subir imagen optimizada
      final newUrl = await uploadFunction(tempFile, imageType, entityId);

      // 5. Limpiar archivo temporal
      await _cleanupTempFile(tempFile);

      if (newUrl == null) {
        return {'success': false, 'error': 'Failed to upload compressed image'};
      }

      // 6. Eliminar imagen original (opcional, comentado para seguridad)
      // await OptimizedStorageService.deleteImage(imageUrl);

      return {
        'success': true,
        'newUrl': newUrl,
        'originalSize': originalSize,
        'compressedSize': compressedBytes.length,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Crea archivo temporal desde bytes
  static Future<File?> _createTempFile(Uint8List bytes) async {
    try {
      final tempDir = Directory.systemTemp;
      final file = File(
        '${tempDir.path}/temp_migration_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error creando archivo temporal: $e');
      return null;
    }
  }

  /// Limpia archivo temporal
  static Future<void> _cleanupTempFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error limpiando archivo temporal: $e');
    }
  }

  /// Estima ahorros potenciales sin realizar migración
  static Future<Map<String, dynamic>> estimateSavings(
    List<String> imageUrls,
  ) async {
    int totalOriginalSize = 0;
    int estimatedCompressedSize = 0;
    int processedImages = 0;

    for (final url in imageUrls.take(5)) {
      // Solo procesar 5 para estimación
      try {
        final response = await http.head(Uri.parse(url));
        if (response.headers['content-length'] != null) {
          final size = int.parse(response.headers['content-length']!);
          totalOriginalSize += size;

          // Estimación: compresión reduce ~70% del tamaño
          estimatedCompressedSize += (size * 0.3).round();
          processedImages++;
        }
      } catch (e) {
        debugPrint('Error estimando tamaño de $url: $e');
      }
    }

    // Extrapolar a todas las imágenes
    if (processedImages > 0) {
      final avgOriginal = totalOriginalSize / processedImages;
      final avgCompressed = estimatedCompressedSize / processedImages;

      totalOriginalSize = (avgOriginal * imageUrls.length).round();
      estimatedCompressedSize = (avgCompressed * imageUrls.length).round();
    }

    final savings = totalOriginalSize - estimatedCompressedSize;
    final savingsPercentage =
        totalOriginalSize > 0 ? (savings / totalOriginalSize * 100) : 0.0;

    return {
      'totalImages': imageUrls.length,
      'originalSizeBytes': totalOriginalSize,
      'estimatedCompressedSizeBytes': estimatedCompressedSize,
      'estimatedSavingsBytes': savings,
      'estimatedSavingsPercentage': savingsPercentage,
      'estimatedMonthlyCostSavings': _calculateMonthlyCostSavings(savings),
    };
  }

  /// Calcula ahorro mensual estimado en USD
  static double _calculateMonthlyCostSavings(int savingsBytes) {
    // Precios Firebase Storage (aproximados)
    const double storagePerGB = 0.026; // USD por GB por mes
    const double transferPerGB = 0.12; // USD por GB transferido

    final savingsGB = savingsBytes / (1024 * 1024 * 1024);

    // Ahorro en almacenamiento + estimación de transferencia (asumiendo 10x al mes)
    return (savingsGB * storagePerGB) + (savingsGB * transferPerGB * 10);
  }

  /// Migración masiva con reporte de progreso
  static Future<void> performBulkMigration({
    required Map<String, List<String>> userImages, // userId -> imageUrls
    required Map<String, Map<String, String>>
    groupImages, // groupId -> imageMap
    required Function(double progress, String status) onProgress,
  }) async {
    final totalOperations = userImages.length + groupImages.length;
    int completedOperations = 0;

    // Migrar imágenes de usuarios
    for (final entry in userImages.entries) {
      onProgress(
        completedOperations / totalOperations,
        'Migrando usuario ${entry.key}',
      );

      await migrateUserImages(userId: entry.key, imageUrls: entry.value);

      completedOperations++;
    }

    // Migrar imágenes de grupos
    for (final entry in groupImages.entries) {
      onProgress(
        completedOperations / totalOperations,
        'Migrando grupo ${entry.key}',
      );

      await migrateGroupImages(groupId: entry.key, imageMap: entry.value);

      completedOperations++;
    }

    onProgress(1.0, 'Migración completada');
  }

  /// Genera reporte de migración
  static String generateMigrationReport(Map<String, dynamic> results) {
    final migrated = (results['migrated'] as List).length;
    final failed = (results['failed'] as List).length;
    final originalSize = results['originalSizeBytes'] as int;
    final compressedSize = results['compressedSizeBytes'] as int;
    final savings = results['savingsBytes'] as int;
    final savingsPercentage = results['savingsPercentage'] as double;

    return '''
📊 REPORTE DE MIGRACIÓN DE IMÁGENES

✅ Migradas exitosamente: $migrated
❌ Fallidas: $failed
📂 Total procesadas: ${migrated + failed}

💾 AHORROS DE ALMACENAMIENTO:
• Tamaño original: ${_formatBytes(originalSize)}
• Tamaño comprimido: ${_formatBytes(compressedSize)}
• Ahorro total: ${_formatBytes(savings)} (${savingsPercentage.toStringAsFixed(1)}%)

💰 AHORRO ESTIMADO MENSUAL: \$${_calculateMonthlyCostSavings(savings).toStringAsFixed(2)} USD

🚀 BENEFICIOS:
• Transferencias más rápidas
• Menor uso de datos móviles
• Mejor experiencia de usuario
• Costos reducidos de Firebase
    ''';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
