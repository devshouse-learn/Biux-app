import 'dart:io';
import 'package:biux/data/models/sites.dart';
import 'package:biux/data/models/types_sites.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SitesRepository {
  final URL_BASE = "https://biux-prod.ibacrea.com/api/v1/sitios";
  final urlfilter =
      "https://biux-prod.ibacrea.com/api/v1/sitios?tipoSitio.tipo=Negocio";
  Future<List<Sites>> getSites() async {
    var url = '$URL_BASE?';
    var response = await http.get(  Uri.parse( url) );
    Map responseData = json.decode(response.body);
    List sitesJson = responseData["data"];
    List<Sites> sites =
        sitesJson.map((sites) => Sites.fromJson(json: sites)).toList();
    return sites;
  }

  Future<List<Sites>> getSitesFilter() async {
    var url = '$urlfilter';
    var response = await http.get(  Uri.parse( url ) );
    Map responseData = json.decode(response.body);
    List sitesJson = responseData["data"];
    List<Sites> sites =
        sitesJson.map((sites) => Sites.fromJson(json: sites)).toList();
    return sites;
  }

  Future<TypesSites> getTypesSites() async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    var url = '$URL_BASE';
    final http.Response response = await http.get(
      Uri.parse( url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return TypesSites.fromJsonMap(json: json.decode(response.body));
    } else {
      throw Exception('Fallo en actualizar grupo');
    }
  }
}
