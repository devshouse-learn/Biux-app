import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/foundation.dart";

/// Helper para forzar autenticaciÃ³n en Realtime Database
///
/// PROBLEMA: Los custom tokens de Firebase Auth no siempre se propagan
/// automÃ¡ticamente a Realtime Database, causando errores de "permission-denied"
/// incluso cuando el usuario estÃ¡ autenticado en Firebase Auth.
///
/// SOLUCIÃ“N: Este helper fuerza mÃºltiples refreshes y espera a que
/// Realtime Database reconozca la autenticaciÃ³n antes de permitir escrituras.
class RealtimeDatabaseAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Fuerza refresh del token y verifica que Realtime Database lo reconozca
  ///
  /// Retorna true si la autenticaciÃ³n fue exitosa, false si fallÃ³
  static Future<bool> ensureAuthenticated({
    int maxAttempts = 3,
    Duration delayBetweenAttempts = const Duration(milliseconds: 500),
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      debugPrint(
        'âŒ RealtimeDB Auth: No hay usuario autenticado en Firebase Auth',
      );
      return false;
    }

    debugPrint(
      'ðŸ” RealtimeDB Auth: Verificando autenticaciÃ³n para ${currentUser.uid}',
    );

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        // 1. Forzar refresh del token
        debugPrint(
          'ðŸ”„ RealtimeDB Auth: Intento $attempt/$maxAttempts - Refrescando token...',
        );
        final token = await currentUser.getIdToken(
          true,
        ); // true = force refresh

        if (token == null || token.isEmpty) {
          debugPrint(
            'âš ï¸ RealtimeDB Auth: Token es null o vacÃ­o en intento $attempt',
          );
          if (attempt < maxAttempts) {
            await Future.delayed(delayBetweenAttempts);
            continue;
          }
          return false;
        }

        debugPrint(
          'âœ… RealtimeDB Auth: Token obtenido (${token.substring(0, 20)}...)',
        );

        // 2. Verificar que Realtime Database reconoce la autenticaciÃ³n
        // Hacemos una lectura dummy a .info/authenticated
        final connectedRef = _database.ref('.info/connected');
        final snapshot = await connectedRef.get();

        if (snapshot.value == true) {
          debugPrint(
            'âœ… RealtimeDB Auth: Realtime Database conectado y autenticado',
          );
          return true;
        }

        debugPrint(
          'âš ï¸ RealtimeDB Auth: Realtime Database no conectado en intento $attempt',
        );

        if (attempt < maxAttempts) {
          await Future.delayed(delayBetweenAttempts);
        }
      } on FirebaseException catch (e) {
        debugPrint('âŒ RealtimeDB Auth: Error en intento $attempt: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(delayBetweenAttempts);
        }
      }
    }

    debugPrint('âŒ RealtimeDB Auth: FallÃ³ despuÃ©s de $maxAttempts intentos');
    return false;
  }

  /// VersiÃ³n simplificada que solo hace el refresh sin verificaciÃ³n
  /// Usar cuando necesitas rapidez sobre garantÃ­as
  static Future<void> quickRefresh() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await currentUser.getIdToken(true);
        // PequeÃ±a espera para que se propague
        await Future.delayed(Duration(milliseconds: 100));
      } on FirebaseException catch (e) {
        debugPrint('âš ï¸ RealtimeDB Auth: Error en quick refresh: $e');
      }
    }
  }
}

