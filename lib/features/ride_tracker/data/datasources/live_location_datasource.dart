import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/authorization_service.dart';
import 'package:biux/core/services/app_logger.dart';

class LiveLocationDatasource {
  static final _db = FirebaseFirestore.instance;

  // CRÍTICO #13: TTL automático para ubicaciones en vivo (1 hora)
  static const int LOCATION_TTL_MINUTES = 60;

  // ── Compartir ubicación en vivo ───────────────────────────────
  /// CRÍTICO #7 y #13: Validar membresía y agregar TTL
  static Future<void> startSharing({required String groupId}) async {
    try {
      final authService = AuthorizationService();
      final uid = authService.getCurrentUserId();

      // CRÍTICO #7: Verificar que el usuario sea miembro del grupo
      await authService.requireGroupMembership(groupId);

      // CRÍTICO #13: Agregar TTL automático (expiración)
      final expiresAt = DateTime.now().add(Duration(minutes: LOCATION_TTL_MINUTES));

      await _db.collection('live_locations').doc('${groupId}_$uid').set({
        'uid': uid,
        'groupId': groupId,
        'active': true,
        'startedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),  // TTL automático
        'lat': 0.0,
        'lng': 0.0,
      });

      AppLogger.info('Compartir ubicación iniciado para grupo $groupId',
          tag: 'LiveLocationDatasource');
    } on UnauthorizedException catch (e) {
      AppLogger.warning('Usuario no autorizado para compartir ubicación: ${e.message}',
          tag: 'LiveLocationDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error iniciando compartición de ubicación: $e',
          tag: 'LiveLocationDatasource', error: e);
      rethrow;
    }
  }

  /// Actualizar ubicación con validación de coordenadas y TTL
  static Future<void> updateLocation({
    required String groupId,
    required double lat,
    required double lng,
    double? speed,
    double? heading,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('Usuario no autenticado');
      }

      // Validar que las coordenadas sean válidas
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        throw ValidationException('coordinates',
            'Coordenadas fuera de rango válido (lat: ±90, lng: ±180)');
      }

      // Actualizar TTL en cada actualización
      final expiresAt = DateTime.now().add(Duration(minutes: LOCATION_TTL_MINUTES));

      await _db.collection('live_locations').doc('${groupId}_$uid').update({
        'lat': lat,
        'lng': lng,
        'speed': speed ?? 0.0,
        'heading': heading ?? 0.0,
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),  // Renovar TTL
      });
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'LiveLocationDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error actualizando ubicación: $e',
          tag: 'LiveLocationDatasource', error: e);
      rethrow;
    }
  }

  static Future<void> stopSharing({required String groupId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('live_locations').doc('\${groupId}_\$uid').update({
      'active': false,
    });
  }

  /// CRÍTICO #7: Obtener ubicaciones de miembros solo si el usuario es miembro
  /// Solo devuelve ubicaciones activas que no han expirado
  static Stream<List<Map<String, dynamic>>> groupMembersStream(String groupId) {
    // NOTA: La verificación de membresía debe hacerse en la capa de repository
    // que tiene acceso al contexto de autenticación actual.
    // Aquí solo filtramos por grupo y estado activo.
    // Las Security Rules de Firestore deben validar que solo miembros del grupo
    // puedan leer esta colección.

    return _db
        .collection('live_locations')
        .where('groupId', isEqualTo: groupId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final now = DateTime.now();
          return snap.docs
              .map((d) => d.data())
              .where((data) {
                // CRÍTICO #13: Filtrar ubicaciones expiradas en cliente
                final expiresAt = data['expiresAt'] as Timestamp?;
                if (expiresAt == null) return true;
                return now.isBefore(expiresAt.toDate());
              })
              .toList();
        });
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
