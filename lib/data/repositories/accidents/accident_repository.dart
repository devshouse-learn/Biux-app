import 'dart:convert';
import 'dart:io';
import 'package:biux/data/models/situation_accident.dart';
import 'package:http/http.dart' as http;


class AccidentRepository {
  final urlBase = "https://biux-prod.ibacrea.com/api/v1/situacionesAccidentes";
  Future<List<SituationAccident>> getListAccident() async {
    var url = '$urlBase?';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List groupsJson = responseData["data"];
    List<SituationAccident> groups = groupsJson
        .map((groupsJson) => SituationAccident.fromJsonMap(groupsJson))
        .toList();
    return groups;
  }

  Future getAccident() async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
    };
    var response = await http.get(Uri.parse(urlBase), headers: headers);
    return response;
  }

  Future sendDatesAccident(SituationAccident situationAccident) async {
    var headers = {
      'Content-type': 'application/json',
      // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var body = jsonEncode(situationAccident.toJson());
    final http.Response response = await http.post(
      Uri.parse(urlBase),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {}
  }

  Future sendDatesEps(String eps) async {
    var urlEps = 'https://biux-prod.ibacrea.com/api/v1/eps';
    var headers = {
      'Content-type': 'application/json',
      //  HttpHeaders.authorizationHeader: await LocalStorage().obtenerToken(),
    };
    var body = jsonEncode(eps).toString();
    final http.Response response = await http.post(
      Uri.parse(urlEps),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {}
  }
}
