import 'package:firebase_database/firebase_database.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

/// Datasource para posts guardados/marcados por el usuario
class BookmarksDatasource {
  final _db = FirebaseDatabase.instance.ref();

  /// ALTO: Validar entrada y agregar logging
  /// Verificar si un post está guardado
  Future<bool> isBookmarked(String userId, String postId) async {
    try {
      if (userId.isEmpty || postId.isEmpty) {
        throw ValidationException('ids', 'User ID y Post ID son requeridos');
      }

      final snap = await _db.child('bookmarks/$userId/$postId').get();
      return snap.exists;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'BookmarksDatasource',
      );
      return false;
    } catch (e) {
      AppLogger.error(
        'Error verificando bookmark: $e',
        tag: 'BookmarksDatasource',
        error: e,
      );
      return false;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  /// Guardar un post
  Future<void> addBookmark(String userId, String postId) async {
    try {
      if (userId.isEmpty || postId.isEmpty) {
        throw ValidationException('ids', 'User ID y Post ID son requeridos');
      }

      await _db.child('bookmarks/$userId/$postId').set({
        'savedAt': ServerValue.timestamp,
      });

      AppLogger.info('Post guardado: $postId', tag: 'BookmarksDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'BookmarksDatasource',
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error guardando bookmark: $e',
        tag: 'BookmarksDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  /// Quitar un post guardado
  Future<void> removeBookmark(String userId, String postId) async {
    try {
      if (userId.isEmpty || postId.isEmpty) {
        throw ValidationException('ids', 'User ID y Post ID son requeridos');
      }

      await _db.child('bookmarks/$userId/$postId').remove();

      AppLogger.info('Bookmark removido: $postId', tag: 'BookmarksDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'BookmarksDatasource',
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error removiendo bookmark: $e',
        tag: 'BookmarksDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  /// Alternar bookmark
  Future<bool> toggleBookmark(String userId, String postId) async {
    try {
      if (userId.isEmpty || postId.isEmpty) {
        throw ValidationException('ids', 'User ID y Post ID son requeridos');
      }

      final exists = await isBookmarked(userId, postId);
      if (exists) {
        await removeBookmark(userId, postId);
        return false;
      } else {
        await addBookmark(userId, postId);
        return true;
      }
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'BookmarksDatasource',
      );
      return false;
    } catch (e) {
      AppLogger.error(
        'Error toggling bookmark: $e',
        tag: 'BookmarksDatasource',
        error: e,
      );
      return false;
    }
  }

  /// ALTO: Validar entrada y error handling
  /// Obtener todos los post IDs guardados por un usuario
  Future<List<String>> getBookmarkedPostIds(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException('userId', 'User ID no puede estar vacío');
      }

      final snap = await _db.child('bookmarks/$userId').get();
      if (!snap.exists || snap.value == null) {
        AppLogger.debug(
          'Sin bookmarks para usuario: $userId',
          tag: 'BookmarksDatasource',
        );
        return [];
      }

      final data = snap.value as Map<dynamic, dynamic>;
      final postIds = data.keys.cast<String>().toList();

      AppLogger.debug(
        'Bookmarks encontrados: ${postIds.length}',
        tag: 'BookmarksDatasource',
      );
      return postIds;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'BookmarksDatasource',
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error obteniendo bookmarks: $e',
        tag: 'BookmarksDatasource',
        error: e,
      );
      return [];
    }
  }
}
