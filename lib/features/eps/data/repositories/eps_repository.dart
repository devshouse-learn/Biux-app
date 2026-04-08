import 'dart:io';
import 'package:biux/features/eps/data/models/eps.dart';
import 'package:biux/core/config/api_config.dart';
import 'package:http/http.dart' as http;

class EpsRepository {
  Future<List<Eps>> getEPS() async {
    return [];
  }

  Future getEps() async {
    var headers = {HttpHeaders.contentTypeHeader: 'aplication/json'};
    var response = await http.get(Uri.parse(ApiConfig.eps), headers: headers);
    return response;
  }

  Future sendDatesEps(Eps eps) async {
    // TODO: Implementar envío de datos EPS
  }
}
