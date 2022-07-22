import 'dart:io';
import 'package:biux/data/models/advertising.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdvertisingRepository {
  final URL_BASE =
      "https://biux-prod.ibacrea.com/api/v1/publicidades?randomValues=true&dinero.gt=0.0";
  Future<Advertising> getAdvertising() async {
    var url = '$URL_BASE';
    // '$URL_BASE?fechaHora.gt=$formattedDate%2000:00,format=dd-MM-yyyy%20HH:mm&sort=fechaHora.asc&limit=$limit&offset=$offset';
    var response = await http.get(
      Uri.parse(url),
    );
    var responseData = json.decode(response.body);
    List roadsJson = responseData["data"];
    // List<Advertising> roads = roadsJson
    //     .map((roadsJson) => Advertising.fromJsonMap(roadsJson))
    //     .toList();
    return [].first;
  }

  Future<Advertising> updateSites(Advertising advertising) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var body = {
      //jsonEncode(advertising.toJson());
    };
    var url =
        'https://biux-prod.ibacrea.com/api/v1/publicidades/${advertising.docId}';
    final http.Response response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return Advertising.fromJsonMap(
        docId: '1',
          json: {
      }
      );
    } else {
      throw Exception('Fallo en actualizar grupo');
    }
  }
}
