import 'dart:convert';
import 'dart:io';
import 'package:biux/features/advertisements/data/models/advertising.dart';
import 'package:biux/core/config/api_config.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:http/http.dart' as http;

class AdvertisingRepository {
  /// ALTO: Mejor error handling y logging
  Future<Advertising> getAdvertising() async {
    final url = ApiConfig.publicidadesAleatorias;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        AppLogger.warning('Timeout obteniendo publicidad aleatoria',
            tag: 'AdvertisingRepo');
        throw Exception('Request timeout');
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List dataList = responseData['data'] ?? [];
        if (dataList.isEmpty) {
          AppLogger.warning('No hay publicidades disponibles',
              tag: 'AdvertisingRepo');
          throw Exception('No advertisements available');
        }
        final adJson = dataList.first;
        final docId = adJson['_id'] ?? adJson['docId'] ?? '';
        return Advertising.fromJsonMap(docId: docId, json: adJson);
      } else {
        AppLogger.warning(
            'Error obteniendo publicidad: código ${response.statusCode}',
            tag: 'AdvertisingRepo');
        throw Exception('Failed to fetch advertisement');
      }
    } on SocketException catch (e) {
      AppLogger.error(
        'Error de red obteniendo publicidad',
        tag: 'AdvertisingRepo',
        error: e,
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado obteniendo publicidad',
        tag: 'AdvertisingRepo',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada en paginación
  Future<List<Advertising>> getAdvertisements({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Validar límites de paginación
      if (limit < 1 || limit > 100) {
        AppLogger.warning('Límite inválido: $limit', tag: 'AdvertisingRepo');
        throw ValidationException('limit', 'Límite debe estar entre 1 y 100');
      }
      if (offset < 0) {
        AppLogger.warning('Offset inválido: $offset', tag: 'AdvertisingRepo');
        throw ValidationException('offset', 'Offset no puede ser negativo');
      }

      final url = ApiConfig.publicidadesConPaginacion(
        limit: limit,
        offset: offset,
      );

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        AppLogger.warning('Timeout obteniendo publicidades', tag: 'AdvertisingRepo');
        throw Exception('Request timeout');
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List dataList = responseData['data'] ?? [];
        return dataList.map((adJson) {
          final docId = adJson['_id'] ?? adJson['docId'] ?? '';
          return Advertising.fromJsonMap(docId: docId, json: adJson);
        }).toList();
      } else {
        AppLogger.warning(
          'Error obteniendo publicidades: código ${response.statusCode}',
          tag: 'AdvertisingRepo',
        );
        return [];
      }
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}', tag: 'AdvertisingRepo');
      return [];
    } on SocketException catch (e) {
      AppLogger.error(
        'Error de red obteniendo publicidades',
        tag: 'AdvertisingRepo',
        error: e,
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error inesperado obteniendo publicidades',
        tag: 'AdvertisingRepo',
        error: e,
      );
      return [];
    }
  }

  /// ALTO: Validar entrada y mejorar error handling
  Future<Advertising> updateSites(Advertising advertising) async {
    try {
      // Validar que docId no esté vacío
      if (advertising.docId.isEmpty) {
        AppLogger.warning('docId vacío', tag: 'AdvertisingRepo');
        throw ValidationException('docId', 'ID de publicidad requerido');
      }

      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      final body = json.encode({
        'description': advertising.description,
        'title': advertising.title,
        'url': advertising.url,
        'textButton': advertising.textButton,
        'photoAd': advertising.photoAd,
        'costOpen': advertising.costOpen,
        'costWatch': advertising.costWatch,
        'money': advertising.money,
      });
      final url = ApiConfig.publicidadById(advertising.docId);

      final response = await http
          .patch(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        AppLogger.warning('Timeout actualizando publicidad', tag: 'AdvertisingRepo');
        throw Exception('Request timeout');
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        return Advertising.fromJsonMap(
          docId: advertising.docId,
          json: data is Map<String, dynamic> ? data : {},
        );
      } else {
        AppLogger.warning(
            'Error actualizando publicidad: código ${response.statusCode}',
            tag: 'AdvertisingRepo');
        throw Exception('Failed to update advertisement');
      }
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}', tag: 'AdvertisingRepo');
      rethrow;
    } on SocketException catch (e) {
      AppLogger.error(
        'Error de red actualizando publicidad',
        tag: 'AdvertisingRepo',
        error: e,
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado actualizando publicidad',
        tag: 'AdvertisingRepo',
        error: e,
      );
      rethrow;
    }
  }
}

