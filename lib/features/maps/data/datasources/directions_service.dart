import 'dart:convert';
import 'dart:io';

import 'package:biux/core/config/env_config.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import "package:flutter/foundation.dart";

class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String _apiKey = EnvConfig.mapsApiKey;

  static Future<List<LatLng>?> getDirections({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'bicycling', // Cambiado de 'driving' a 'bicycling'
  }) async {
    final String url =
        '$_baseUrl?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=$travelMode&'
        'key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];

          // Decodificar la polyline usando nuestra implementación
          final List<LatLng> decoded = _decodePolyline(polylinePoints);

          return decoded;
        }
      }
    } on SocketException catch (e) {
      AppLogger.error(
        'Error getting directions',
        error: e,
        tag: 'DirectionsService',
      );
    }

    return null;
  }

  static Future<DirectionResult?> getDirectionsWithDetails({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'bicycling', // Cambiado de 'driving' a 'bicycling'
  }) async {
    final String url =
        '$_baseUrl?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=$travelMode&'
        'key=$_apiKey';

    AppLogger.debug('URL: $url', tag: 'DirectionsService');

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            Duration(seconds: 10), // Timeout de 10 segundos
            onTimeout: () {
              AppLogger.warning(
                'Timeout en la petición a Google Directions API',
                tag: 'DirectionsService',
              );
              throw Exception('Timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          final polylinePoints = route['overview_polyline']['points'];

          debugPrint(
            '✅ Route found! Polyline length: ${polylinePoints.length}',
          );
          debugPrint(
            '🔗“ Distance: ${leg['distance']['text']}, Duration: ${leg['duration']['text']}',
          );

          final List<LatLng> points = _decodePolyline(polylinePoints);

          return DirectionResult(
            points: points,
            distance: leg['distance']['text'],
            duration: leg['duration']['text'],
            distanceValue: leg['distance']['value'],
            durationValue: leg['duration']['value'],
          );
        } else {
          AppLogger.warning(
            'API Error: ${data['status']}',
            tag: 'DirectionsService',
          );
          if (data['error_message'] != null) {
            AppLogger.warning(
              'Error message: ${data['error_message']}',
              tag: 'DirectionsService',
            );
          }
        }
      } else {
        AppLogger.error(
          'HTTP Error: ${response.statusCode}',
          tag: 'DirectionsService',
        );
        AppLogger.debug(
          'Response body: ${response.body}',
          tag: 'DirectionsService',
        );
      }
    } on SocketException catch (e) {}

    return null;
  }

  // Implementación manual de decodificación de polylines de Google
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }
}

class DirectionResult {
  final List<LatLng> points;
  final String distance;
  final String duration;
  final int distanceValue; // en metros
  final int durationValue; // en segundos

  DirectionResult({
    required this.points,
    required this.distance,
    required this.duration,
    required this.distanceValue,
    required this.durationValue,
  });
}
