import 'dart:io';
import 'package:biux/features/sites/data/models/sites.dart';
import 'package:biux/features/sites/data/models/types_sites.dart';
import 'package:biux/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SitesRepository {
  Future<List<Sites>> getSites() async {
    var url = '${ApiConfig.sitios}?';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List sitesJson = responseData["data"];
    List<Sites> sites = sitesJson
        .map((sites) => Sites.fromJson(json: sites))
        .toList();
    return sites;
  }

  Future<List<Sites>> getSitesFilter() async {
    var url = ApiConfig.sitiosNegocios;
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List sitesJson = responseData["data"];
    List<Sites> sites = sitesJson
        .map((sites) => Sites.fromJson(json: sites))
        .toList();
    return sites;
  }

  Future<TypesSites> getTypesSites() async {
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var url = ApiConfig.sitios;
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return TypesSites.fromJsonMap(json: json.decode(response.body));
    } else {
      throw Exception('Fallo en actualizar grupo');
    }
  }
}
