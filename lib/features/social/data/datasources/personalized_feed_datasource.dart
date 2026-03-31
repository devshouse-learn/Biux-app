
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalizedFeedDatasource {
  static final _db = FirebaseFirestore.instance;
  static const int _pageSize = 15;

  // ── Feed personalizado basado en seguidos + intereses ─────────
  static Future<List<Map<String, dynamic>>> getFeed({
    DocumentSnapshot? lastDoc,
    List<String>? followingIds,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    // Obtener IDs de seguidos si no se pasan
    final following = followingIds ?? await _getFollowingIds(uid);
    if (following.isEmpty) return _getTrendingPosts(lastDoc: lastDoc);

    // Posts de seguidos con paginación
    Query query = _db
        .collection('posts')
        .where('userId', whereIn: following.take(10).toList())
        .orderBy('createdAt', descending: true)
        .limit(_pageSize);

    if (lastDoc != null) query = query.startAfterDocument(lastDoc);

    final snap = await query.get();
    return snap.docs
        .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
        .toList();
  }

  // ── Posts trending (para nuevos usuarios) ────────────────────
  static Future<List<Map<String, dynamic>>> _getTrendingPosts({
    DocumentSnapshot? lastDoc,
  }) async {
    Query query = _db
        .collection('posts')
        .orderBy('likesCount', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(_pageSize);

    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    final snap = await query.get();
    return snap.docs
        .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
        .toList();
  }

  static Future<List<String>> _getFollowingIds(String uid) async {
    final snap = await _db
        .collection('follows')
        .where('followerId', isEqualTo: uid)
        .get();
    return snap.docs.map((d) => d.data()['followingId'] as String).toList();
  }

  // ── Stream de posts de seguidos ───────────────────────────────
  static Stream<List<Map<String, dynamic>>> feedStream(
      List<String> followingIds) {
    if (followingIds.isEmpty) {
      return _db
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize)
          .snapshots()
          .map((s) => s.docs
              .map((d) =>
                  {...d.data(), 'id': d.id})
              .toList());
    }
    return _db
        .collection('posts')
        .where('userId', whereIn: followingIds.take(10).toList())
        .orderBy('createdAt', descending: true)
        .limit(_pageSize)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  // ── Registrar interacción para personalización ────────────────
  static Future<void> trackInteraction({
    required String postId,
    required String action, // 'view' | 'like' | 'comment' | 'share'
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('feed_interactions').add({
      'uid': uid,
      'postId': postId,
      'action': action,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
