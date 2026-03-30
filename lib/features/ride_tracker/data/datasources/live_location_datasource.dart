
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocationDatasource {
  static final _db = FirebaseFirestore.instance;

  // ── Compartir ubicación en vivo ───────────────────────────────
  static Future<void> startSharing({required String groupId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('live_locations')
        .doc('\${groupId}_\$uid')
        .set({
      'uid': uid,
      'groupId': groupId,
      'active': true,
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lat': 0.0,
      'lng': 0.0,
    });
  }

  static Future<void> updateLocation({
    required String groupId,
    required double lat,
    required double lng,
    double? speed,
    double? heading,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('live_locations')
        .doc('\${groupId}_\$uid')
        .update({
      'lat': lat,
      'lng': lng,
      'speed': speed ?? 0.0,
      'heading': heading ?? 0.0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> stopSharing({required String groupId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('live_locations')
        .doc('\${groupId}_\$uid')
        .update({'active': false});
  }

  static Stream<List<Map<String, dynamic>>> groupMembersStream(
      String groupId) {
    return _db
        .collection('live_locations')
        .where('groupId', isEqualTo: groupId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ── Verificar permisos ────────────────────────────────────────
  static Future<bool> checkPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }
}
