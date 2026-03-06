
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReportDatasource {
  final _fs = FirebaseFirestore.instance;

  Future<void> reportContent({
    required String reporterId,
    required String reportedUserId,
    required String contentId,
    required String type,
    required String reason,
    String? details,
  }) async {
    await _fs.collection('reports').add({
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reportedContentId': contentId,
      'reportType': type,
      'reason': reason,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> blockUser(String currentUid, String blockedUid) async {
    await _fs.collection('users').doc(currentUid).collection('blocked').doc(blockedUid).set({
      'uid': blockedUid,
      'blockedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unblockUser(String currentUid, String blockedUid) async {
    await _fs.collection('users').doc(currentUid).collection('blocked').doc(blockedUid).delete();
  }

  Future<bool> isBlocked(String currentUid, String targetUid) async {
    final doc = await _fs.collection('users').doc(currentUid).collection('blocked').doc(targetUid).get();
    return doc.exists;
  }

  Future<List<String>> getBlockedUsers(String uid) async {
    final snap = await _fs.collection('users').doc(uid).collection('blocked').get();
    return snap.docs.map((d) => d.id).toList();
  }
}
