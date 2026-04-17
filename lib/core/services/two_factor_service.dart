import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorService {
  static final _db = FirebaseFirestore.instance;
  static const _key = '2fa_enabled';

  // ── Generar y enviar código ───────────────────────────────────
  static Future<String> generateAndSendCode({
    required String method, // 'email' | 'sms'
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No autenticado');
    final code = (100000 + Random().nextInt(900000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));

    await _db.collection('two_factor_codes').doc(user.uid).set({
      'code': code,
      'method': method,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'verified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Guardar en notificaciones para que n8n lo envíe
    await _db.collection('notifications').add({
      'type': '2fa_code',
      'userId': user.uid,
      'email': user.email,
      'phone': user.phoneNumber,
      'code': code,
      'method': method,
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });

    return code;
  }

  // ── Verificar código ──────────────────────────────────────────
  static Future<bool> verifyCode(String inputCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await _db.collection('two_factor_codes').doc(user.uid).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(expiresAt)) return false;
    if (data['code'] != inputCode) return false;
    await doc.reference.update({'verified': true});
    return true;
  }

  // ── Habilitar/deshabilitar 2FA ────────────────────────────────
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update({
        'twoFactorEnabled': value,
      });
    }
  }
}
