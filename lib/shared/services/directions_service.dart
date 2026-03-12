import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

/// Resultado de una consulta de direcciones
class DirectionsResult {
  final List<LatLng> points;

  const DirectionsResult({required this.points});
}

/// Servicio para obtener direcciones/rutas usando Google Directions API.
/// STUB — pendiente de implementación real.
class DirectionsService {
  /// Obtiene direcciones con detalles entre dos puntos.
  static Future<DirectionsResult?> getDirectionsWithDetails({
    required LatLng origin,
    required LatLng destination,
    required String travelMode,
  }) async {
    debugPrint(
      '⚠️ DirectionsService.getDirectionsWithDetails() — STUB: sin implementar',
    );
    // TODO: Implementar llamada real a Google Directions API
    return null;
  }
}
