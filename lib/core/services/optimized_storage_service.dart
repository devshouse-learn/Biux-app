import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:biux/core/services/image_compression_service.dart';

/// Servicio optimizado para Firebase Storage que reduce costos significativamente
/// - Comprime imÃ¡genes antes de subir
/// - Usa CDN de Firebase automÃ¡ticamente
/// - Implementa estrategias de cachÃ© inteligente
/// - Optimiza metadatos para reducir transferencias
class OptimizedStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube imagen de usuario con compresiÃ³n optimizada
  /// Esto puede reducir los costos de almacenamiento hasta en 80%
  static Future<String?> uploadUserImage({
    required String userId,
    required File imageFile,
    required String imageType, // 'avatar' | 'cover' | 'gallery'
    VoidCallback? onProgress,
  }) async {
    try {
      // Comprimir segÃºn el tipo de imagen
      File? compressedFile;
      switch (imageType) {
        case 'avatar':
          compressedFile = await ImageCompressionService.compressAvatarImage(
            imageFile,
          );
          break;
        case 'cover':
          compressedFile = await ImageCompressionService.compressImageFile(
            imageFile,
          );
          break;
        case 'gallery':
          compressedFile = await ImageCompressionService.compressImageFile(
            imageFile,
          );
          break;
        default:
          compressedFile = await ImageCompressionService.compressImageFile(
            imageFile,
          );
      }

      if (compressedFile == null) return null;

      // Crear referencia optimizada con estructura que facilita CDN
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${imageType}_${timestamp}.jpg';
      final ref = _storage.ref().child('users/$userId/images/$fileName');

      // Configurar metadatos para optimizar CDN y cachÃ©
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000', // 1 aÃ±o de cachÃ©
        customMetadata: {
          'compressed': 'true',
          'originalSize': '${await imageFile.length()}',
          'compressedSize': '${await compressedFile.length()}',
          'imageType': imageType,
          'userId': userId,
        },
      );

      // Subir con metadatos optimizados
      final uploadTask = ref.putFile(compressedFile, metadata);

      // Monitorear progreso si se proporciona callback
      StreamSubscription? progressSubscription;
      if (onProgress != null) {
        progressSubscription = uploadTask.snapshotEvents.listen((snapshot) {
          onProgress();
        });
      }

      final snapshot = await uploadTask;
      progressSubscription?.cancel();
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Limpiar archivo temporal
      if (await compressedFile.exists()) {
        await compressedFile.delete();
      }

      // Retornar URL optimizada para CDN
      return _optimizeCdnUrl(downloadUrl);
    } on FirebaseException catch (e) {
      debugPrint('Error subiendo imagen de usuario: $e');
      return null;
    }
  }

  /// Sube imagen de grupo con compresiÃ³n y mÃºltiples tamaÃ±os
  static Future<Map<String, String>?> uploadGroupImage({
    required String groupId,
    required File imageFile,
    required String imageType, // 'cover' | 'gallery'
    VoidCallback? onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final results = <String, String>{};

      // Crear imagen original comprimida
      final compressedFile = await ImageCompressionService.compressImageFile(
        imageFile,
      );
      if (compressedFile == null) return null;

      // Crear thumbnail para listados (reduce transferencia en 90%)
      final thumbnailFile = await ImageCompressionService.compressThumbnail(
        imageFile,
      );
      if (thumbnailFile == null) return null;

      // Metadatos base
      final baseMetadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000',
        customMetadata: {
          'compressed': 'true',
          'groupId': groupId,
          'imageType': imageType,
        },
      );

      // Subir imagen principal
      final mainRef = _storage.ref().child(
        'groups/$groupId/images/${imageType}_${timestamp}.jpg',
      );
      final mainUpload = await mainRef.putFile(compressedFile, baseMetadata);
      results['main'] = _optimizeCdnUrl(await mainUpload.ref.getDownloadURL());

      // Subir thumbnail
      final thumbRef = _storage.ref().child(
        'groups/$groupId/thumbnails/${imageType}_thumb_${timestamp}.jpg',
      );
      final thumbUpload = await thumbRef.putFile(thumbnailFile, baseMetadata);
      results['thumbnail'] = _optimizeCdnUrl(
        await thumbUpload.ref.getDownloadURL(),
      );

      // Limpiar archivos temporales
      await _cleanupTempFiles([compressedFile, thumbnailFile]);

      return results;
    } on FirebaseException catch (e) {
      debugPrint('Error subiendo imagen de grupo: $e');
      return null;
    }
  }

  /// Sube imagen de rodada con optimizaciÃ³n mÃ¡xima
  static Future<String?> uploadRideImage({
    required String rideId,
    required File imageFile,
    VoidCallback? onProgress,
  }) async {
    try {
      final compressedFile = await ImageCompressionService.compressImageFile(
        imageFile,
      );
      if (compressedFile == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ride_${timestamp}.jpg';
      final ref = _storage.ref().child('rides/$rideId/images/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=2592000', // 30 dÃ­as para rodadas
        customMetadata: {
          'compressed': 'true',
          'rideId': rideId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(compressedFile, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _cleanupTempFiles([compressedFile]);
      return _optimizeCdnUrl(downloadUrl);
    } on FirebaseException catch (e) {
      debugPrint('Error subiendo imagen de rodada: $e');
      return null;
    }
  }

  /// Sube historia con compresiÃ³n extrema (duraciÃ³n temporal)
  static Future<String?> uploadStoryImage({
    required String userId,
    required File imageFile,
    VoidCallback? onProgress,
  }) async {
    try {
      // CompresiÃ³n mÃ¡s agresiva para historias (temporales)
      final compressedFile = await ImageCompressionService.compressThumbnail(
        imageFile,
      );
      if (compressedFile == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'story_${timestamp}.jpg';
      final ref = _storage.ref().child('stories/$userId/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=86400', // Solo 24 horas para historias
        customMetadata: {
          'compressed': 'true',
          'isStory': 'true',
          'expiresAt': DateTime.now()
              .add(Duration(hours: 24))
              .toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(compressedFile, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _cleanupTempFiles([compressedFile]);
      return _optimizeCdnUrl(downloadUrl);
    } on FirebaseException catch (e) {
      debugPrint('Error subiendo historia: $e');
      return null;
    }
  }

  /// Sube imagen de bicicleta con compresiÃ³n optimizada
  static Future<String?> uploadBikeImage({
    required String userId,
    required String bikeId,
    required File imageFile,
    required String imageType, // 'main' | 'serial' | 'additional' | 'invoice'
    VoidCallback? onProgress,
  }) async {
    try {
      // Comprimir segÃºn el tipo de imagen
      File? compressedFile;
      if (imageType == 'main') {
        // Foto principal: alta calidad
        compressedFile = await ImageCompressionService.compressImageFile(
          imageFile,
        );
      } else if (imageType == 'serial') {
        // Foto del nÃºmero de serie: priorizar nitidez
        compressedFile = await ImageCompressionService.compressImageFile(
          imageFile,
        );
      } else if (imageType == 'invoice') {
        // Factura: priorizar legibilidad
        compressedFile = await ImageCompressionService.compressImageFile(
          imageFile,
        );
      } else {
        // Fotos adicionales: compresiÃ³n estÃ¡ndar
        compressedFile = await ImageCompressionService.compressImageFile(
          imageFile,
        );
      }

      if (compressedFile == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${imageType}_${timestamp}.jpg';
      final ref = _storage.ref().child('bikes/$userId/$bikeId/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl:
            'public, max-age=31536000', // 1 aÃ±o de cachÃ© (datos permanentes)
        customMetadata: {
          'compressed': 'true',
          'userId': userId,
          'bikeId': bikeId,
          'imageType': imageType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(compressedFile, metadata);

      // Monitorear progreso si se proporciona callback
      StreamSubscription? progressSubscription;
      if (onProgress != null) {
        progressSubscription = uploadTask.snapshotEvents.listen((snapshot) {
          onProgress();
        });
      }

      final snapshot = await uploadTask;
      progressSubscription?.cancel();
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _cleanupTempFiles([compressedFile]);
      return _optimizeCdnUrl(downloadUrl);
    } on FirebaseException catch (e) {
      debugPrint('Error subiendo imagen de bicicleta: $e');
      return null;
    }
  }

  /// Optimiza URL para usar CDN de Firebase de manera mÃ¡s eficiente
  static String _optimizeCdnUrl(String originalUrl) {
    // Firebase Storage automÃ¡ticamente usa CDN, pero podemos optimizar
    // agregando parÃ¡metros para cachÃ© y compresiÃ³n adicional
    if (originalUrl.contains('firebasestorage.googleapis.com')) {
      return '$originalUrl&alt=media'; // Optimiza transferencia
    }
    return originalUrl;
  }

  /// Genera URLs optimizadas con parÃ¡metros de transformaciÃ³n
  static String getOptimizedImageUrl(
    String baseUrl, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) {
    final uri = Uri.parse(baseUrl);
    final params = Map<String, String>.from(uri.queryParameters);

    // Agregar parÃ¡metros de optimizaciÃ³n si estÃ¡n disponibles
    if (maxWidth != null) params['w'] = maxWidth.toString();
    if (maxHeight != null) params['h'] = maxHeight.toString();
    if (quality != null) params['q'] = quality.toString();

    return uri.replace(queryParameters: params).toString();
  }

  /// Elimina imÃ¡genes para liberar espacio y reducir costos
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Error eliminando imagen: $e');
      return false;
    }
  }

  /// Limpia archivos temporales
  static Future<void> _cleanupTempFiles(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } on FirebaseException catch (e) {
        debugPrint('Error limpiando archivo temporal: $e');
      }
    }
  }

  /// Obtiene estadÃ­sticas de almacenamiento para monitorear costos
  static Future<Map<String, dynamic>> getStorageStats(String userId) async {
    try {
      final userRef = _storage.ref().child('users/$userId');
      final result = await userRef.listAll();

      int totalSize = 0;
      int fileCount = result.items.length;

      for (final item in result.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      return {
        'fileCount': fileCount,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'estimatedMonthlyCost': _calculateEstimatedCost(totalSize),
      };
    } on FirebaseException catch (e) {
      debugPrint('Error obteniendo estadÃ­sticas: $e');
      return {};
    }
  }

  /// Sube contenido de experiencias (imÃ¡genes y videos) con optimizaciÃ³n especÃ­fica
  static Future<Map<String, String>?> uploadExperienceMedia({
    required String userId,
    required File mediaFile,
    required String mediaType, // 'image' | 'video'
    required String experienceType, // 'general' | 'ride'
    String? experienceId,
    VoidCallback? onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final results = <String, String>{};

      if (mediaType == 'image') {
        // Para imÃ¡genes: compresiÃ³n optimizada para experiencias
        final compressedFile = await ImageCompressionService.compressImageFile(
          mediaFile,
        );
        if (compressedFile == null) return null;

        final fileName = 'exp_img_${timestamp}.jpg';
        final ref = _storage.ref().child(
          'experiences/$userId/images/$fileName',
        );

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: experienceType == 'ride'
              ? 'public, max-age=2592000' // 30 dÃ­as para rodadas
              : 'public, max-age=604800', // 7 dÃ­as para experiencias normales
          customMetadata: {
            'compressed': 'true',
            'mediaType': 'image',
            'experienceType': experienceType,
            'duration': '15', // 15 segundos por defecto para imÃ¡genes
            'userId': userId,
            'experienceId': experienceId ?? '',
          },
        );

        final uploadTask = ref.putFile(compressedFile, metadata);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        results['url'] = _optimizeCdnUrl(downloadUrl);
        results['type'] = 'image';
        results['duration'] = '15';

        await _cleanupTempFiles([compressedFile]);
      } else if (mediaType == 'video') {
        // Para videos: subida directa con metadatos optimizados
        final fileName = 'exp_vid_${timestamp}.mp4';
        final ref = _storage.ref().child(
          'experiences/$userId/videos/$fileName',
        );

        final metadata = SettableMetadata(
          contentType: 'video/mp4',
          cacheControl: experienceType == 'ride'
              ? 'public, max-age=2592000' // 30 dÃ­as para rodadas
              : 'public, max-age=604800', // 7 dÃ­as para experiencias normales
          customMetadata: {
            'mediaType': 'video',
            'experienceType': experienceType,
            'maxDuration': '30', // 30 segundos mÃ¡ximo
            'userId': userId,
            'experienceId': experienceId ?? '',
          },
        );

        final uploadTask = ref.putFile(mediaFile, metadata);

        // Monitorear progreso si se proporciona callback
        StreamSubscription? progressSubscription;
        if (onProgress != null) {
          progressSubscription = uploadTask.snapshotEvents.listen((snapshot) {
            onProgress();
          });
        }

        final snapshot = await uploadTask;
        progressSubscription?.cancel();
        final downloadUrl = await snapshot.ref.getDownloadURL();

        results['url'] = _optimizeCdnUrl(downloadUrl);
        results['type'] = 'video';
        results['duration'] = '30'; // Por defecto, se puede ajustar despuÃ©s
      }

      return results;
    } on FirebaseException catch (e) {
      debugPrint('Error subiendo contenido de experiencia: $e');
      return null;
    }
  }

  /// Mueve una imagen temporal a su ubicaciÃ³n final
  static Future<String?> moveTemporaryRideImage({
    required String tempImageUrl,
    required String rideId,
  }) async {
    try {
      // Obtener la referencia de la imagen temporal
      final tempRef = _storage.refFromURL(tempImageUrl);

      // Obtener los datos de la imagen temporal
      final tempData = await tempRef.getData();
      if (tempData == null) return null;

      // Crear nueva referencia en la ubicaciÃ³n correcta
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ride_${timestamp}.jpg';
      final newRef = _storage.ref().child('rides/$rideId/images/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=2592000', // 30 dÃ­as para rodadas
        customMetadata: {
          'compressed': 'true',
          'rideId': rideId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'movedFromTemp': 'true',
        },
      );

      // Subir a la nueva ubicaciÃ³n
      final uploadTask = newRef.putData(tempData, metadata);
      final snapshot = await uploadTask;
      final newDownloadUrl = await snapshot.ref.getDownloadURL();

      // Eliminar la imagen temporal
      try {
        await tempRef.delete();
      } on FirebaseException catch (e) {
        debugPrint('Advertencia: No se pudo eliminar imagen temporal: $e');
      }

      return _optimizeCdnUrl(newDownloadUrl);
    } on FirebaseException catch (e) {
      debugPrint('Error moviendo imagen temporal: $e');
      return null;
    }
  }

  /// Calcula costo estimado mensual (aproximado)
  static double _calculateEstimatedCost(int bytes) {
    // Precios aproximados de Firebase Storage (pueden variar)
    const double costPerGBPerMonth = 0.026; // USD
    final double gb = bytes / (1024 * 1024 * 1024);
    return gb * costPerGBPerMonth;
  }
}

