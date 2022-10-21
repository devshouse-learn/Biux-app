import 'package:biux/data/models/stole_bikes.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class StoleBikesRepository {
  final urlBase = "https://biux-prod.ibacrea.com/api/v1/robosBicicleta";

  Future<StoleBikes> getStoleBikes(int id) async {
    var url = '$urlBase?bike.user.id=$id';
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
    };
    var response = await http.get(Uri.parse(url), headers: headers);
    Map<String, dynamic> responseData = json.decode(response.body);
    Map stoleBikesJson = responseData['data'][0];
    StoleBikes stoleBikes = StoleBikes.fromjson(stoleBikesJson);
    return stoleBikes;
  }

  Future getBike() async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
    };
    var response = await http.get(
      Uri.parse(urlBase),
      headers: headers,
    );
    return response;
  }

  Future sendDatesStoleBikes(StoleBikes stoleBikes) async {
    var headers = {
      'Content-type': 'application/json',
      // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var body = jsonEncode(stoleBikes.toJson());
    final http.Response response = await http.post(
      Uri.parse(urlBase),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return response.statusCode;
    } else {}
  }

  Future updateDatesStoleBikes(StoleBikes stoleBikes) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
      // HttpHeaders.authorizationHeader: await LocalStorage().getToken()
    };
    var body = jsonEncode(stoleBikes.toJson());
    final http.Response response = await http.patch(
      Uri.parse(urlBase),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {}
  }
}
