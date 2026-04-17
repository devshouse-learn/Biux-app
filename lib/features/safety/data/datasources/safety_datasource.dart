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
