import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/safety/domain/entities/block_report_entity.dart';

class SafetyDatasource {
  final FirebaseFirestore _firestore;
  SafetyDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> blockUser(String blockerId, String blockedId) async {
    final batch = _firestore.batch();
    batch
        .set(_firestore.collection('blocks').doc('${blockerId}_${blockedId}'), {
          'blockerId': blockerId,
          'blockedId': blockedId,
          'createdAt': FieldValue.serverTimestamp(),
        });
    batch.update(_firestore.collection('users').doc(blockerId), {
      'blockedUsers': FieldValue.arrayUnion([blockedId]),
    });
    await batch.commit();

    // Remover relación de seguidores en ambas direcciones
    await _removeFollowRelation(blockerId, blockedId);
    await _removeFollowRelation(blockedId, blockerId);
  }

  /// Remueve la relación de follow entre dos usuarios si existe.
  Future<void> _removeFollowRelation(String followerId, String followedId) async {
    try {
      final followerRef = _firestore.collection('users').doc(followerId);
      final followedRef = _firestore.collection('users').doc(followedId);

      final followerDoc = await followerRef.get();
      final followedDoc = await followedRef.get();
      if (!followerDoc.exists || !followedDoc.exists) return;

      final followerData = followerDoc.data() ?? {};
      final followedData = followedDoc.data() ?? {};

      final following = Map<String, dynamic>.from(followerData['following'] ?? {});
      final followers = Map<String, dynamic>.from(followedData['followers'] ?? {});

      if (!following.containsKey(followedId) && !followers.containsKey(followerId)) return;

      following.remove(followedId);
      followers.remove(followerId);

      await followerRef.update({
        'following': following,
        'followingCount': following.length,
      });
      await followedRef.update({
        'followers': followers,
        'followerS': followers.length,
      });
    } catch (_) {}
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    final batch = _firestore.batch();
    batch.delete(
      _firestore.collection('blocks').doc('${blockerId}_${blockedId}'),
    );
    batch.update(_firestore.collection('users').doc(blockerId), {
      'blockedUsers': FieldValue.arrayRemove([blockedId]),
    });
    await batch.commit();
  }

  Future<bool> isBlocked(String blockerId, String blockedId) async {
    final doc = await _firestore
        .collection('blocks')
        .doc('${blockerId}_${blockedId}')
        .get();
    return doc.exists;
  }

  /// Verifica si existe un bloqueo en cualquier dirección entre dos usuarios.
  Future<bool> isBlockedEitherWay(String userA, String userB) async {
    final a = await _firestore
        .collection('blocks')
        .doc('${userA}_${userB}')
        .get();
    if (a.exists) return true;
    final b = await _firestore
        .collection('blocks')
        .doc('${userB}_${userA}')
        .get();
    return b.exists;
  }

  Future<List<String>> getBlockedUsers(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null) return [];
    return List<String>.from(data['blockedUsers'] ?? []);
  }

  Future<void> reportUser({
    required String reporterId,
    required String reportedId,
    required ReportReason reason,
    String? description,
  }) async {
    await _firestore.collection('reports').add({
      'reporterId': reporterId,
      'reportedId': reportedId,
      'reason': reason.name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
    await _firestore.collection('users').doc(reportedId).update({
      'reportCount': FieldValue.increment(1),
    });
  }
}
