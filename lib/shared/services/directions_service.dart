import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Resultado de una consulta de direcciones con
/// información completa de la ruta.
class DirectionsResult {
  final List<LatLng> points;
  final String? totalDistance;
  final String? totalDuration;
  final String? startAddress;
  final String? endAddress;

  const DirectionsResult({
    required this.points,
    this.totalDistance,
    this.totalDuration,
    this.startAddress,
    this.endAddress,
  });
}

/// Servicio para obtener direcciones/rutas usando
/// Google Directions API.
///
/// Uso:
/// ```dart
/// final result = await DirectionsService
///     .getDirectionsWithDetails(
///   origin: LatLng(4.6097, -74.0817),
///   destination: LatLng(4.6486, -74.0628),
/// );
/// ```
class DirectionsService {
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// Obtiene direcciones con detalles entre dos puntos.
  ///
  /// [origin] Punto de inicio de la ruta.
  /// [destination] Punto de destino de la ruta.
  /// [travelMode] Modo de viaje: bicycling, driving,
  /// walking, transit. Por defecto 'bicycling'.
  static Future<DirectionsResult?> getDirectionsWithDetails({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'bicycling',
  }) async {
    try {
      const apiKey = String.fromEnvironment(
        'GOOGLE_MAPS_API_KEY',
        defaultValue: '',
      );
      if (apiKey.isEmpty) {
        debugPrint(
          '⚠️ DirectionsService: '
          'GOOGLE_MAPS_API_KEY no configurada',
        );
        return null;
      }

      // Validar travelMode
      const validModes = ['bicycling', 'driving', 'walking', 'transit'];
      final mode = validModes.contains(travelMode) ? travelMode : 'bicycling';

      final url =
          Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
            'origin': '${origin.latitude},${origin.longitude}',
            'destination':
                '${destination.latitude},'
                '${destination.longitude}',
            'mode': mode,
            'language': 'es',
            'key': apiKey,
          });

      final response = await http
          .get(url)
          .timeout(
            _requestTimeout,
            onTimeout: () {
              debugPrint(
                '⚠️ DirectionsService: '
                'Timeout después de $_requestTimeout',
              );
              return http.Response('{"status":"TIMEOUT"}', 408);
            },
          );

      if (response.statusCode != 200) {
        debugPrint(
          '⚠️ DirectionsService: '
          'HTTP ${response.statusCode}',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status != 'OK') {
        _logApiError(status);
        return null;
      }

      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes[0] as Map<String, dynamic>;
      final overviewPolyline =
          route['overview_polyline'] as Map<String, dynamic>?;
      final encodedPoints = overviewPolyline?['points'] as String?;
      if (encodedPoints == null || encodedPoints.isEmpty) {
        return null;
      }

      final points = _decodePolyline(encodedPoints);
      if (points.isEmpty) return null;

      // Extraer información de la ruta
      String? totalDistance;
      String? totalDuration;
      String? startAddress;
      String? endAddress;

      final legs = route['legs'] as List<dynamic>?;
      if (legs != null && legs.isNotEmpty) {
        final firstLeg = legs.first as Map<String, dynamic>;
        final lastLeg = legs.last as Map<String, dynamic>;

        int distMeters = 0;
        int durSeconds = 0;
        for (final leg in legs) {
          final l = leg as Map<String, dynamic>;
          distMeters += (l['distance']?['value'] as int?) ?? 0;
          durSeconds += (l['duration']?['value'] as int?) ?? 0;
        }

        totalDistance = _formatDistance(distMeters);
        totalDuration = _formatDuration(durSeconds);
        startAddress = firstLeg['start_address'] as String?;
        endAddress = lastLeg['end_address'] as String?;
      }

      return DirectionsResult(
        points: points,
        totalDistance: totalDistance,
        totalDuration: totalDuration,
        startAddress: startAddress,
        endAddress: endAddress,
      );
    } catch (e) {
      debugPrint(
        '⚠️ DirectionsService'
        '.getDirectionsWithDetails() error: $e',
      );
      return null;
    }
  }

  /// Registra errores específicos de la API.
  static void _logApiError(String? status) {
    switch (status) {
      case 'ZERO_RESULTS':
        debugPrint(
          '⚠️ DirectionsService: '
          'No se encontró ruta entre los puntos',
        );
        break;
      case 'OVER_QUERY_LIMIT':
        debugPrint(
          '⚠️ DirectionsService: '
          'Límite de consultas excedido',
        );
        break;
      case 'REQUEST_DENIED':
        debugPrint(
          '⚠️ DirectionsService: '
          'API key sin permisos para Directions',
        );
        break;
      default:
        debugPrint(
          '⚠️ DirectionsService: '
          'API status=$status',
        );
    }
  }

  /// Formatea metros a texto legible.
  static String _formatDistance(int meters) {
    if (meters >= 1000) {
      final km = (meters / 1000).toStringAsFixed(1);
      return '$km km';
    }
    return '$meters m';
  }

  /// Formatea segundos a texto legible.
  static String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '$minutes min';
  }

  /// Decodifica una polyline encoded string en lista
  /// de LatLng con protección contra datos corruptos.
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    try {
      while (index < encoded.length) {
        int shift = 0;
        int result = 0;
        int b;
        do {
          if (index >= encoded.length) return points;
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1F) << shift;
          shift += 5;
        } while (b >= 0x20);
        final dlat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          if (index >= encoded.length) return points;
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1F) << shift;
          shift += 5;
        } while (b >= 0x20);
        final dlng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
        lng += dlng;

        points.add(LatLng(lat / 1e5, lng / 1e5));
      }
    } catch (e) {
      debugPrint(
        '⚠️ DirectionsService'
        '._decodePolyline() error: $e',
      );
    }

    return points;
  }
}
