import 'dart:io';
import 'package:biux/features/roads/data/models/competitor_road.dart';
import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/roads/data/models/road.dart';
import 'package:biux/core/config/api_config.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

var now = DateTime.now();
var formatter = DateFormat('yyyy-MM-dd');
String formattedDate = formatter.format(now);

class RoadsRepository {
  Future<List<Road>> getRoads(int limit, int offset, String cityId) async {
    var url = ApiConfig.rodadasPorCiudad(
      cityId,
      fechaDesde: formattedDate,
      limit: limit,
      offset: offset,
    );
    var response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    List roadsJson = responseData["data"];
    List<Road> roads = roadsJson
        .map((roadJson) => Road.fromJson(json: roadJson, id: roadJson))
        .toList();

    return roads;
  }

  Future uploadProfileCoverRoad(String id, File filePhoto) async {
    Dio dio = Dio();
    FormData formData = FormData.fromMap({
      "fileImagen": await MultipartFile.fromFile(filePhoto.path),
    });
    await dio.patch(ApiConfig.rodadaById(id), data: formData);
  }

  Future<Road> updateRoad(Road road) async {
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var body = jsonEncode(road.toJson());

    var url = ApiConfig.rodadaById(road.id);
    final http.Response response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return Road.fromJson(
        json: json.decode(response.body),
        id: json.decode(response.body),
      );
    } else {
      throw Exception('error_update_group');
    }
  }

  Future<List<CompetitorRoad>> getListParticipantRoad(String id) async {
    var url = '${ApiConfig.participantesRodada}?rodada.id=$id';
    var response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    List roadsJson = responseData["data"];
    List<CompetitorRoad> listCompetitorRoad = roadsJson
        .map((roadJson) => CompetitorRoad.fromJsonMap(json: roadJson))
        .toList();

    return listCompetitorRoad;
  }

  Future<List<Road>> getRoadsGroups(String id, int limit, int offset) async {
    var url = ApiConfig.rodadasPorGrupo(id, limit: limit, offset: offset);
    var response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    List roadsJson = responseData["data"];
    List<Road> roadsGroup = roadsJson
        .map((roadJson) => Road.fromJson(json: roadJson, id: roadJson))
        .toList();

    return roadsGroup;
  }

  Future joinMeRoad(String userId, String roadId) async {
    var uriResponse = await http.post(
      Uri.parse(ApiConfig.participantesRodada),
      body: jsonEncode({"usuarioId": userId, "rodadaId": roadId}),
      headers: {'Content-type': 'application/json'},
    );
    if (uriResponse.statusCode == 200) {
      return;
    } else if (uriResponse.statusCode == 409) {
      return 'must_join_group_for_ride';
    }
  }

  Future deleteRoad(Road road, Group group) async {
    {
      var uriResponse = await http.delete(
        Uri.parse(ApiConfig.rodadaById(road.id)),
        headers: {'Content-type': 'application/json'},
      );
      if (uriResponse.statusCode == 200) {
        json.decode(uriResponse.body);
        return 'deleted_successfully';
      } else {}
    }
  }

  Future<CompetitorRoad> getParticipantRoad(String id, String userId) async {
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var url = ApiConfig.participanteRodada(id, userId);

    var response = await http.get(Uri.parse(url), headers: headers);

    var responseData = json.decode(response.body);

    List participant = responseData["data"];

    return CompetitorRoad.fromJsonMap(json: participant.first);
  }

  Future<CompetitorRoad> deleteCompetitorRoad(
    CompetitorRoad competitorRoad,
  ) async {
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var url = '${ApiConfig.participantesRodada}/${competitorRoad.userId}';
    final http.Response response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    return CompetitorRoad.fromJsonMap(json: json.decode(response.body));
  }
}
