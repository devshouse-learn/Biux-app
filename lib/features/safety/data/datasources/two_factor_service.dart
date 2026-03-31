import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoFactorService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> sendCode({
    required String method,
    String? contact,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    // In production: call backend to send code via SMS/email
    // For now, store a mock code in Firestore
    await _db.collection('two_factor_codes').doc(uid).set({
      'code': '123456',
      'method': method,
      'contact': contact,
      'createdAt': FieldValue.serverTimestamp(),
      'verified': false,
    });
  }

  static Future<bool> verifyCode(String code) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _db.collection('two_factor_codes').doc(uid).get();
    if (!doc.exists) return false;
    final stored = doc.data()?['code'];
    if (stored == code) {
      await _db.collection('two_factor_codes').doc(uid).update({'verified': true});
      await _db.collection('users').doc(uid).update({'twoFactorEnabled': true});
      return true;
    }
    return false;
  }

  static Future<bool> isEnabled(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['twoFactorEnabled'] == true;
  }

  static Future<void> disable() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'twoFactorEnabled': false});
    await _db.collection('two_factor_codes').doc(uid).delete();
  }
}
