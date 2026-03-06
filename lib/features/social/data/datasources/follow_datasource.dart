
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FollowDatasource {
  final _fs = FirebaseFirestore.instance;

  Future<void> followUser(String currentUid, String targetUid) async {
    final batch = _fs.batch();

    // Add to following collection
    batch.set(
      _fs.collection('users').doc(currentUid).collection('following').doc(targetUid),
      {'uid': targetUid, 'createdAt': FieldValue.serverTimestamp()},
    );

    // Add to followers collection
    batch.set(
      _fs.collection('users').doc(targetUid).collection('followers').doc(currentUid),
      {'uid': currentUid, 'createdAt': FieldValue.serverTimestamp()},
    );

    // Update counts
    batch.update(_fs.collection('users').doc(currentUid), {'followingCount': FieldValue.increment(1)});
    batch.update(_fs.collection('users').doc(targetUid), {'followersCount': FieldValue.increment(1)});

    await batch.commit();
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    final batch = _fs.batch();

    batch.delete(_fs.collection('users').doc(currentUid).collection('following').doc(targetUid));
    batch.delete(_fs.collection('users').doc(targetUid).collection('followers').doc(currentUid));
    batch.update(_fs.collection('users').doc(currentUid), {'followingCount': FieldValue.increment(-1)});
    batch.update(_fs.collection('users').doc(targetUid), {'followersCount': FieldValue.increment(-1)});

    await batch.commit();
  }

  Future<bool> isFollowing(String currentUid, String targetUid) async {
    final doc = await _fs.collection('users').doc(currentUid).collection('following').doc(targetUid).get();
    return doc.exists;
  }

  Future<List<String>> getFollowers(String uid) async {
    final snap = await _fs.collection('users').doc(uid).collection('followers').orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => d.id).toList();
  }

  Future<List<String>> getFollowing(String uid) async {
    final snap = await _fs.collection('users').doc(uid).collection('following').orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => d.id).toList();
  }

  Stream<int> followersCountStream(String uid) {
    return _fs.collection('users').doc(uid).snapshots().map((s) => (s.data()?['followersCount'] as num?)?.toInt() ?? 0);
  }

  Stream<int> followingCountStream(String uid) {
    return _fs.collection('users').doc(uid).snapshots().map((s) => (s.data()?['followingCount'] as num?)?.toInt() ?? 0);
  }
}
