import 'dart:convert';
import 'dart:io';
import 'package:biux/features/advertisements/data/models/advertising.dart';
import 'package:biux/core/config/api_config.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:http/http.dart' as http;

class AdvertisingRepository {
  /// Obtiene una publicidad aleatoria con dinero disponible.
  Future<Advertising> getAdvertising() async {
    final url = ApiConfig.publicidadesAleatorias;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List dataList = responseData['data'] ?? [];
        if (dataList.isEmpty) {
          throw Exception('No hay publicidades disponibles');
        }
        final adJson = dataList.first;
        final docId = adJson['_id'] ?? adJson['docId'] ?? '';
        return Advertising.fromJsonMap(docId: docId, json: adJson);
      } else {
        throw Exception('Error al obtener publicidad: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error(
        'Error obteniendo publicidad',
        tag: 'AdvertisingRepo',
        error: e,
      );
      rethrow;
    }
  }

  /// Obtiene una lista de publicidades.
  Future<List<Advertising>> getAdvertisements({
    int limit = 10,
    int offset = 0,
  }) async {
    final url = ApiConfig.publicidadesConPaginacion(
      limit: limit,
      offset: offset,
    );
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List dataList = responseData['data'] ?? [];
        return dataList.map((adJson) {
          final docId = adJson['_id'] ?? adJson['docId'] ?? '';
          return Advertising.fromJsonMap(docId: docId, json: adJson);
        }).toList();
      } else {
        AppLogger.warning(
          'Error obteniendo publicidades: ${response.statusCode}',
          tag: 'AdvertisingRepo',
        );
        return [];
      }
    } catch (e) {
      AppLogger.error(
        'Error obteniendo publicidades',
        tag: 'AdvertisingRepo',
        error: e,
      );
      return [];
    }
  }

  /// Actualiza los datos de una publicidad.
  Future<Advertising> updateSites(Advertising advertising) async {
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
    try {
      final response = await http
          .patch(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        return Advertising.fromJsonMap(
          docId: advertising.docId,
          json: data is Map<String, dynamic> ? data : {},
        );
      } else {
        throw Exception(
          'Fallo al actualizar publicidad: ${response.statusCode}',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Error actualizando publicidad',
        tag: 'AdvertisingRepo',
        error: e,
      );
      rethrow;
    }
  }
}
