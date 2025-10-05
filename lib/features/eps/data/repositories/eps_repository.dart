import 'dart:io';
import 'package:biux/features/eps/data/models/eps.dart';
import 'package:http/http.dart' as http;

class EpsRepository {
  final urlBase = "https://biux-prod.ibacrea.com/api/v1/eps";

  Future<List<Eps>> getEPS() async {
    return [];
    // var url = '$urlBase?';
    // var response = await http.get(Uri.parse(url));
    // Map responseData = json.decode(response.body);
    // List groupsJson = responseData["data"];
    // List<Eps> groups =
    //     groupsJson.map((groupJson) => Eps.fromJsonMap(groupJson)).toList();
    // return groups;
  }

  Future getEps() async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
    };
    var response = await http.get(
      Uri.parse(urlBase),
      headers: headers,
    );
    return response;
  }

  Future sendDatesEps(Eps eps) async {
    // var headers = {
    //   HttpHeaders.contentTypeHeader: 'aplication/json',
    //   HttpHeaders.authorizationHeader: await LocalStorage().getToken()
    // };
    // var body = jsonEncode(eps.toJson());
    // final http.Response response = await http.post(
    //   Uri.parse(urlBase),
    //   headers: headers,
    //   body: body,
    // );
    // if (response.statusCode == 200) {
    //   return response.body;
    // } else {}
  }
}
