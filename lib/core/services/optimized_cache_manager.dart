import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Implementación concreta de ImageCacheManager
class _OptimizedImageCacheManager extends CacheManager with ImageCacheManager {
  _OptimizedImageCacheManager._(Config config) : super(config);
}

/// Cache Manager optimizado para máximo rendimiento y ahorro de costos
class OptimizedCacheManager {
  static const key = 'biux_optimized_cache';

  static _OptimizedImageCacheManager? _instance;
  static _OptimizedImageCacheManager? _thumbnailInstance;
  static _OptimizedImageCacheManager? _avatarInstance;

  static _OptimizedImageCacheManager get instance {
    _instance ??= _OptimizedImageCacheManager._(
      Config(
        key,
        stalePeriod: const Duration(days: 30), // Caché por 30 días
        maxNrOfCacheObjects: 1000, // Máximo 1000 imágenes en caché
        repo: JsonCacheInfoRepository(databaseName: key),
        fileSystem: IOFileSystem(key),
        fileService: HttpFileService(),
      ),
    );
    return _instance!;
  }

  /// Cache manager específico para thumbnails (caché más largo)
  static _OptimizedImageCacheManager get thumbnailInstance {
    _thumbnailInstance ??= _OptimizedImageCacheManager._(
      Config(
        '${key}_thumbnails',
        stalePeriod: const Duration(days: 90), // Thumbnails por 90 días
        maxNrOfCacheObjects: 2000, // Más thumbnails
        repo: JsonCacheInfoRepository(databaseName: '${key}_thumbnails'),
        fileSystem: IOFileSystem('${key}_thumbnails'),
        fileService: HttpFileService(),
      ),
    );
    return _thumbnailInstance!;
  }

  /// Cache manager para avatares (caché muy largo)
  static _OptimizedImageCacheManager get avatarInstance {
    _avatarInstance ??= _OptimizedImageCacheManager._(
      Config(
        '${key}_avatars',
        stalePeriod: const Duration(days: 180), // Avatares por 6 meses
        maxNrOfCacheObjects: 500,
        repo: JsonCacheInfoRepository(databaseName: '${key}_avatars'),
        fileSystem: IOFileSystem('${key}_avatars'),
        fileService: HttpFileService(),
      ),
    );
    return _avatarInstance!;
  }

  /// Limpia todo el caché si es necesario
  static Future<void> clearAll() async {
    await instance.emptyCache();
    await thumbnailInstance.emptyCache();
    await avatarInstance.emptyCache();
  }

  /// Obtiene el cache manager apropiado según el tipo de imagen
  static _OptimizedImageCacheManager getCacheManager(String imageType) {
    switch (imageType) {
      case 'avatar':
        return avatarInstance;
      case 'thumbnail':
        return thumbnailInstance;
      default:
        return instance;
    }
  }
}
