import 'dart:convert';
import 'dart:io';
import 'package:biux/data/models/trademark_bike.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:http/http.dart' as http;

class TrademarkBikeRepository {
  final urlBase = "https://biux-prod.ibacrea.com/api/v1/marcasBicicletas";

  Future<List<TrademarkBike>> getListTrademarks() async {
    var url = '$urlBase?';
    var response = await http.get(Uri.parse(url));

    Map responseData = json.decode(response.body);
    List groupsJson = responseData["data"];
    List<TrademarkBike> groups = groupsJson
        .map((groupJson) => TrademarkBike.fromJsonMap(groupJson))
        .toList();
    return groups;
  }

  Future getTrademarksBike() async {
    var headers = {HttpHeaders.contentTypeHeader: 'aplication/json'};
    var response = await http.get(
      Uri.parse(urlBase),
      headers: headers,
    );
    Map<String, dynamic> responseData = json.decode(response.body);
    List groupsJson = responseData["data"].toList();
    List<TrademarkBike> groups = groupsJson
        .map((groupJson) => TrademarkBike.fromJsonMap(groupJson))
        .toList();
    return groups;
  }

  Future sendDatesTrademarkBike(TrademarkBike trademarkBike) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var body = jsonEncode(trademarkBike.toJson());
    final http.Response response =
        await http.post(Uri.parse(urlBase), headers: headers, body: body);

    if (response.statusCode == 200) {
      return response.body;
    } else {}
  }
}
