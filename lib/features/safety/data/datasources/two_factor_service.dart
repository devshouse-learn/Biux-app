import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/app_logger.dart';

class TwoFactorService {
  static final _db = FirebaseFirestore.instance;

  // Máximo de intentos fallidos antes de bloquear
  static const int MAX_ATTEMPTS = 5;
  // Tiempo de expiración del código en minutos
  static const int CODE_EXPIRATION_MINUTES = 10;
  // Tiempo de bloqueo después de exceder intentos (minutos)
  static const int LOCKOUT_MINUTES = 15;

  /// Genera un código OTP aleatorio de 6 dígitos
  static String _generateOTP() {
    final random = Random.secure();
    return '${100000 + random.nextInt(900000)}';
  }

  /// CRÍTICO #8 y #9: Rate limiting en OTP y OTP seguro (no hardcodeado)
  static Future<void> sendCode({
    required String method,
    String? contact,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      // Verificar si el usuario está bloqueado por muchos intentos fallidos
      final existingDoc = await _db.collection('two_factor_codes').doc(uid).get();

      if (existingDoc.exists) {
        final data = existingDoc.data();
        final failedAttempts = data?['failedAttempts'] ?? 0;
        final lastFailedAt = data?['lastFailedAt'] as Timestamp?;

        if (failedAttempts >= MAX_ATTEMPTS && lastFailedAt != null) {
          final now = DateTime.now();
          final lastFailed = lastFailedAt.toDate();
          final minutesSinceFailure = now.difference(lastFailed).inMinutes;

          if (minutesSinceFailure < LOCKOUT_MINUTES) {
            AppLogger.warning(
              'Usuario $uid bloqueado por múltiples intentos fallidos',
              tag: 'TwoFactorService',
            );
            throw RateLimitException(
              'Demasiados intentos fallidos. Intenta en ${LOCKOUT_MINUTES - minutesSinceFailure} minutos.',
            );
          }
        }
      }

      // Generar nuevo código OTP seguro (no hardcodeado)
      final newCode = _generateOTP();

      // Guardar con expiración y metadata
      await _db.collection('two_factor_codes').doc(uid).set({
        'code': newCode,
        'method': method,
        'contact': contact,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: CODE_EXPIRATION_MINUTES))
        ),
        'verified': false,
        'failedAttempts': 0,
        'lastFailedAt': null,
      }, SetOptions(merge: true));

      AppLogger.info(
        'Código OTP generado para $method',
        tag: 'TwoFactorService',
      );

      // TODO: En producción, enviar código via SMS/Email usando Twilio, SendGrid, etc.
      // Por ahora solo se almacena en Firestore
    } catch (e) {
      AppLogger.error(
        'Error generando código OTP: $e',
        tag: 'TwoFactorService',
        error: e,
      );
      rethrow;
    }
  }

  static Future<bool> verifyCode(String code) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final doc = await _db.collection('two_factor_codes').doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data();
      final stored = data?['code'] as String?;
      final expiresAt = data?['expiresAt'] as Timestamp?;
      final failedAttempts = (data?['failedAttempts'] ?? 0) as int;

      // Verificar si el código ha expirado
      if (expiresAt != null &&
          DateTime.now().isAfter(expiresAt.toDate())) {
        AppLogger.warning(
          'Código OTP expirado para usuario $uid',
          tag: 'TwoFactorService',
        );
        return false;
      }

      // Verificar si el código es correcto
      if (stored == code) {
        await _db.collection('two_factor_codes').doc(uid).update({
          'verified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
          'failedAttempts': 0,
        });
        await _db
            .collection('users')
            .doc(uid)
            .update({'twoFactorEnabled': true});

        AppLogger.info(
          'Código OTP verificado exitosamente',
          tag: 'TwoFactorService',
        );
        return true;
      } else {
        // Incrementar contador de intentos fallidos
        final newFailedAttempts = failedAttempts + 1;
        await _db.collection('two_factor_codes').doc(uid).update({
          'failedAttempts': newFailedAttempts,
          'lastFailedAt': FieldValue.serverTimestamp(),
        });

        AppLogger.warning(
          'Intento fallido de verificación OTP (intento $newFailedAttempts/$MAX_ATTEMPTS)',
          tag: 'TwoFactorService',
        );

        if (newFailedAttempts >= MAX_ATTEMPTS) {
          throw RateLimitException(
            'Demasiados intentos fallidos. Intenta en $LOCKOUT_MINUTES minutos.',
          );
        }
        return false;
      }
    } catch (e) {
      AppLogger.error(
        'Error verificando código OTP: $e',
        tag: 'TwoFactorService',
        error: e,
      );
      rethrow;
    }
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
