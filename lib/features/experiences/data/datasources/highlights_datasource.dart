import 'package:cloud_firestore/cloud_firestore.dart';

/// Datasource para historias destacadas del usuario
class HighlightsDatasource {
  final _fs = FirebaseFirestore.instance;

  /// Obtener los highlights de un usuario
  Future<List<Map<String, dynamic>>> getHighlights(String userId) async {
    final snap = await _fs
        .collection('users')
        .doc(userId)
        .collection('highlights')
        .orderBy('createdAt', descending: false)
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return data;
    }).toList();
  }

  /// Crear un nuevo highlight
  Future<String> createHighlight({
    required String userId,
    required String title,
    required String coverUrl,
    required List<String> storyIds,
  }) async {
    final doc = await _fs
        .collection('users')
        .doc(userId)
        .collection('highlights')
        .add({
          'title': title,
          'coverUrl': coverUrl,
          'storyIds': storyIds,
          'createdAt': FieldValue.serverTimestamp(),
        });
    return doc.id;
  }

  /// Actualizar un highlight (agregar/quitar historias)
  Future<void> updateHighlight({
    required String userId,
    required String highlightId,
    String? title,
    String? coverUrl,
    List<String>? storyIds,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (coverUrl != null) updates['coverUrl'] = coverUrl;
    if (storyIds != null) updates['storyIds'] = storyIds;

    await _fs
        .collection('users')
        .doc(userId)
        .collection('highlights')
        .doc(highlightId)
        .update(updates);
  }

  /// Eliminar un highlight
  Future<void> deleteHighlight({
    required String userId,
    required String highlightId,
  }) async {
    await _fs
        .collection('users')
        .doc(userId)
        .collection('highlights')
        .doc(highlightId)
        .delete();
  }
}
