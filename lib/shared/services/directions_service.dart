import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Resultado de una consulta de direcciones
class DirectionsResult {
  final List<LatLng> points;

  const DirectionsResult({required this.points});
}

/// Servicio para obtener direcciones/rutas usando Google Directions API.
class DirectionsService {
  /// Obtiene direcciones con detalles entre dos puntos.
  static Future<DirectionsResult?> getDirectionsWithDetails({
    required LatLng origin,
    required LatLng destination,
    required String travelMode,
  }) async {
    try {
      const apiKey = String.fromEnvironment(
        'GOOGLE_MAPS_API_KEY',
        defaultValue: '',
      );
      if (apiKey.isEmpty) {
        debugPrint('⚠️ DirectionsService: GOOGLE_MAPS_API_KEY no configurada');
        return null;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=$travelMode'
        '&language=es'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint('⚠️ DirectionsService: HTTP ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status != 'OK') {
        debugPrint('⚠️ DirectionsService: API status=$status');
        return null;
      }

      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes[0] as Map<String, dynamic>;
      final overviewPolyline =
          route['overview_polyline'] as Map<String, dynamic>?;
      final encodedPoints = overviewPolyline?['points'] as String?;
      if (encodedPoints == null) return null;

      final points = _decodePolyline(encodedPoints);
      return DirectionsResult(points: points);
    } catch (e) {
      debugPrint('⚠️ DirectionsService.getDirectionsWithDetails() error: $e');
      return null;
    }
  }

  /// Decodifica una polyline encoded string en lista de LatLng.
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
