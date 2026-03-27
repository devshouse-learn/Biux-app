import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:biux/features/maps/data/datasources/directions_service.dart'
    as maps;

/// Resultado de una consulta de direcciones
class DirectionsResult {
  final List<LatLng> points;

  const DirectionsResult({required this.points});
}

/// Proxy que delega al DirectionsService real en features/maps.
class DirectionsService {
  /// Obtiene direcciones con detalles entre dos puntos.
  static Future<DirectionsResult?> getDirectionsWithDetails({
    required LatLng origin,
    required LatLng destination,
    required String travelMode,
  }) async {
    final result = await maps.DirectionsService.getDirectionsWithDetails(
      origin: origin,
      destination: destination,
      travelMode: travelMode,
    );

    if (result == null) return null;

    return DirectionsResult(points: result.points);
  }
}
