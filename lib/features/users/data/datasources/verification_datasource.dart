import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum VerificationStatus { none, pending, verified, rejected }

class VerificationDatasource {
  static final _db = FirebaseFirestore.instance;

  static Future<VerificationStatus> getStatus(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final raw = doc.data()?['verificationStatus'] ?? 'none';
    return VerificationStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => VerificationStatus.none,
    );
  }

  static Future<void> submitRequest({
    required String reason,
    required String socialLinks,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('verification_requests').doc(uid).set({
      'uid': uid,
      'reason': reason,
      'socialLinks': socialLinks,
      'status': VerificationStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(uid).update({
      'verificationStatus': VerificationStatus.pending.name,
    });
  }

  static Future<bool> isVerified(String uid) async {
    final status = await getStatus(uid);
    return status == VerificationStatus.verified;
  }
}
