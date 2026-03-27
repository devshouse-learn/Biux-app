import 'package:firebase_database/firebase_database.dart';

/// Datasource para posts guardados/marcados por el usuario
class BookmarksDatasource {
  final _db = FirebaseDatabase.instance.ref();

  /// Verificar si un post está guardado
  Future<bool> isBookmarked(String userId, String postId) async {
    final snap = await _db.child('bookmarks/$userId/$postId').get();
    return snap.exists;
  }

  /// Guardar un post
  Future<void> addBookmark(String userId, String postId) async {
    await _db.child('bookmarks/$userId/$postId').set({
      'savedAt': ServerValue.timestamp,
    });
  }

  /// Quitar un post guardado
  Future<void> removeBookmark(String userId, String postId) async {
    await _db.child('bookmarks/$userId/$postId').remove();
  }

  /// Alternar bookmark
  Future<bool> toggleBookmark(String userId, String postId) async {
    final exists = await isBookmarked(userId, postId);
    if (exists) {
      await removeBookmark(userId, postId);
      return false;
    } else {
      await addBookmark(userId, postId);
      return true;
    }
  }

  /// Obtener todos los post IDs guardados por un usuario
  Future<List<String>> getBookmarkedPostIds(String userId) async {
    final snap = await _db.child('bookmarks/$userId').get();
    if (!snap.exists || snap.value == null) return [];
    final data = snap.value as Map<dynamic, dynamic>;
    return data.keys.cast<String>().toList();
  }
}
