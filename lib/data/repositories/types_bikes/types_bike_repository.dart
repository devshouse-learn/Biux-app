import 'dart:convert';
import 'dart:io';
import 'package:biux/data/models/type_bike.dart';
import 'package:http/http.dart' as http;

class TypesBikeRepository {
  final urlBase = "https://biux-prod.ibacrea.com/api/v1/tiposBicicletas";
  Future<List<TypeBike>> getListTradeMarks() async {
    var url = '$urlBase?';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List groupsJson = responseData["data"];
    List<TypeBike> groups =
        groupsJson.map((groupJson) => TypeBike.fromJsonMap(groupJson)).toList();
    return groups;
  }

  Future getTypesBike() async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
    };
    var response = await http.get(
      Uri.parse(urlBase),
      headers: headers,
    );
    Map<String, dynamic> responseData = json.decode(response.body);
    List groupsJson = responseData["data"].toList();
    List<TypeBike> groups =
        groupsJson.map((groupJson) => TypeBike.fromJsonMap(groupJson)).toList();
    return groups;
  }

  Future sendDatesTypesBike(TypeBike typeBike) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
      // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var body = jsonEncode(typeBike.toJson());
    final http.Response response = await http.post(
      Uri.parse(urlBase),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {}
  }
}
