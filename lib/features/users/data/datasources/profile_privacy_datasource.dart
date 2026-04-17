import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ProfileVisibility { public, friendsOnly, private }

class ProfilePrivacyDatasource {
  static final _db = FirebaseFirestore.instance;

  static Future<ProfileVisibility> getVisibility(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final raw = doc.data()?['profileVisibility'] ?? 'public';
    return ProfileVisibility.values.firstWhere(
      (v) => v.name == raw,
      orElse: () => ProfileVisibility.public,
    );
  }

  static Future<void> setVisibility(ProfileVisibility visibility) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'profileVisibility': visibility.name,
    });
  }

  static Future<bool> canViewProfile(
    String viewerUid,
    String profileUid,
  ) async {
    if (viewerUid == profileUid) return true;
    final visibility = await getVisibility(profileUid);
    if (visibility == ProfileVisibility.public) return true;
    if (visibility == ProfileVisibility.private) return false;
    // friendsOnly: verificar si son seguidores mutuos
    final doc = await _db
        .collection('follows')
        .where('followerId', isEqualTo: viewerUid)
        .where('followingId', isEqualTo: profileUid)
        .get();
    return doc.docs.isNotEmpty;
  }

  static Future<void> updatePrivacySettings({
    required bool showRides,
    required bool showStats,
    required bool showGroups,
    required bool showFollowers,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'privacy': {
        'showRides': showRides,
        'showStats': showStats,
        'showGroups': showGroups,
        'showFollowers': showFollowers,
      },
    });
  }
}
