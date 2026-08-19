import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/foundation.dart";
import 'package:biux/core/services/app_logger.dart';

/// Helper para forzar autenticación en Realtime Database
///
/// PROBLEMA: Los custom tokens de Firebase Auth no siempre se propagan
/// automáticamente a Realtime Database, causando errores de "permission-denied"
/// incluso cuando el usuario está autenticado en Firebase Auth.
///
/// SOLUCIÃ“N: Este helper fuerza mÃºltiples refreshes y espera a que
/// Realtime Database reconozca la autenticación antes de permitir escrituras.
class RealtimeDatabaseAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Fuerza refresh del token y verifica que Realtime Database lo reconozca
  ///
  /// Retorna true si la autenticación fue exitosa, false si falló
  static Future<bool> ensureAuthenticated({
    int maxAttempts = 3,
    Duration delayBetweenAttempts = const Duration(milliseconds: 500),
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      AppLogger.error(
        'RealtimeDB Auth: No hay usuario autenticado en Firebase Auth',
        tag: 'RealtimeDatabaseAuthHelper',
      );
      return false;
    }

    AppLogger.debug(
      'RealtimeDB Auth: Verificando autenticación para ${currentUser.uid}',
      tag: 'RealtimeDatabaseAuthHelper',
    );

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        // 1. Forzar refresh del token
        AppLogger.debug(
          'RealtimeDB Auth: Intento $attempt/$maxAttempts - Refrescando token...',
          tag: 'RealtimeDatabaseAuthHelper',
        );
        final token = await currentUser.getIdToken(
          true,
        ); // true = force refresh

        if (token == null || token.isEmpty) {
          AppLogger.warning(
            'RealtimeDB Auth: Token es null o vacío en intento $attempt',
            tag: 'RealtimeDatabaseAuthHelper',
          );
          if (attempt < maxAttempts) {
            await Future.delayed(delayBetweenAttempts);
            continue;
          }
          return false;
        }

        AppLogger.info(
          'RealtimeDB Auth: Token obtenido (${token.substring(0, 20)}...)',
          tag: 'RealtimeDatabaseAuthHelper',
        );

        // 2. Verificar que Realtime Database reconoce la autenticación
        // Hacemos una lectura dummy a .info/authenticated
        final connectedRef = _database.ref('.info/connected');
        final snapshot = await connectedRef.get();

        if (snapshot.value == true) {
          AppLogger.info(
            'RealtimeDB Auth: Realtime Database conectado y autenticado',
            tag: 'RealtimeDatabaseAuthHelper',
          );
          return true;
        }

        AppLogger.warning(
          'RealtimeDB Auth: Realtime Database no conectado en intento $attempt',
          tag: 'RealtimeDatabaseAuthHelper',
        );

        if (attempt < maxAttempts) {
          await Future.delayed(delayBetweenAttempts);
        }
      } on FirebaseException catch (e) {
        AppLogger.error(
          'RealtimeDB Auth: Error en intento $attempt',
          error: e,
          tag: 'RealtimeDatabaseAuthHelper',
        );
        if (attempt < maxAttempts) {
          await Future.delayed(delayBetweenAttempts);
        }
      }
    }

    AppLogger.error(
      'RealtimeDB Auth: Falló después de $maxAttempts intentos',
      tag: 'RealtimeDatabaseAuthHelper',
    );
    return false;
  }

  /// Versión simplificada que solo hace el refresh sin verificación
  /// Usar cuando necesitas rapidez sobre garantías
  static Future<void> quickRefresh() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await currentUser.getIdToken(true);
        // Pequeña espera para que se propague
        await Future.delayed(Duration(milliseconds: 100));
      } on FirebaseException catch (e) {
        AppLogger.error(
          'RealtimeDB Auth: Error en quick refresh',
          error: e,
          tag: 'RealtimeDatabaseAuthHelper',
        );
      }
    }
  }
}
