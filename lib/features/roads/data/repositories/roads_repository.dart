import 'dart:io';
import 'package:biux/data/models/competitor_road.dart';
import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/roads/data/models/road.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

var now = DateTime.now();
var formatter = DateFormat('yyyy-MM-dd');
String formattedDate = formatter.format(now);

class RoadsRepository {
  final URL_BASE = "https://biux-prod.ibacrea.com/api/v1/rodadas";
  final URLParticipant =
      "https://biux-prod.ibacrea.com/api/v1/participantesRodada";
  Future<List<Road>> getRoads(
    int limit,
    int offset,
    String cityId,
  ) async {
    var url =
        '$URL_BASE?ciudadId=$cityId&sort=fechaHora.asc&fechaHora.gt=$formattedDate,format=yyyy-MM-dd&limit=$limit&offset=$offset';
    var response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    List roadsJson = responseData["data"];
    List<Road> roads = roadsJson
        .map((roadJson) => Road.fromJson(
              json: roadJson,
              id: roadJson,
            ))
        .toList();

    return roads;
  }

  Future uploadProfileCoverRoad(
    String id,
    File filePhoto,
  ) async {
    Dio dio = Dio();
    // dio.options.headers["authorization"] = await LocalStorage().getToken();
    FormData formData = FormData.fromMap({
      "fileImagen": await MultipartFile.fromFile(
        filePhoto.path,
      ),
    });
    Response response = await dio.patch(
      'https://biux-prod.ibacrea.com/api/v1/rodadas/$id',
      data: formData,
    );
  }

  Future<Road> updateRoad(Road road) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };

    var body = jsonEncode(road.toJson());

    var url = '$URL_BASE/${road.id}';
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
      throw Exception('Fallo en actualizar grupo');
    }

    //Map<String, dynamic> responseData = json.decode(response.body);
    //return Usuario.fromJsonMap(responseData);

    //return Usuario.fromJsonMap(personasJson.first);
  }

  Future<List<CompetitorRoad>> getListParticipantRoad(
    String id,
  ) async {
    // var headers = {
    //   HttpHeaders.contentTypeHeader: 'application/json',
    // };
    var url = '$URLParticipant?rodada.id=$id';
    var response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    List roadsJson = responseData["data"];
    List<CompetitorRoad> listCompetitorRoad = roadsJson
        .map((roadJson) => CompetitorRoad.fromJsonMap(json: roadJson))
        .toList();

    return listCompetitorRoad;
  }

  Future<List<Road>> getRoadsGroups(
    String id,
    int limit,
    int offset,
  ) async {
    var url = '$URL_BASE?grupo.id=$id&limit=$limit&offset=$offset';
    var response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    List roadsJson = responseData["data"];
    List<Road> roadsGroup = roadsJson
        .map((roadJson) => Road.fromJson(
              json: roadJson,
              id: roadJson,
            ))
        .toList();

    return roadsGroup;
  }

  Future joinMeRoad(
    String userId,
    String roadId,
  ) async {
    var uriResponse = await http.post(
      Uri.parse(URLParticipant),
      body: jsonEncode(
        {
          "usuarioId": userId,
          "rodadaId": roadId,
        },
      ),
      headers: {
        'Content-type': 'application/json',
        // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
      },
    );
    if (uriResponse.statusCode == 200) {
      final data = json.decode(uriResponse.body);
      int id = data["id"];
      // LocalStorage().saveJoinRoad(id.toString());

      return;
    } else if (uriResponse.statusCode == 409) {
      return 'Debes unirte al grupo para poder participar en esta rodada';
    }
  }

  Future deleteRoad(Road road, Group group) async {
    {
      var uriResponse = await http.delete(
        Uri.parse('$URL_BASE/${road.id}'),
        headers: {
          'Content-type': 'application/json',
          // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
        },
      );
      if (uriResponse.statusCode == 200) {
        final data = json.decode(uriResponse.body);
        return "se elimino con exito";
      } else {}
      // return Rodada.fromJson(json.decode(response.body));
    }
  }

  Future<CompetitorRoad> getParticipantRoad(
    String id,
    String userId,
  ) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    var url = '$URLParticipant?rodada.id=$id&usuarioId=$userId';

    var response = await http.get(Uri.parse(url), headers: headers);

    var responseData = json.decode(response.body);

    List participant = responseData["data"];

    return CompetitorRoad.fromJsonMap(json: participant.first);
  }

  Future<CompetitorRoad> deleteCompetitorRoad(
    CompetitorRoad competitorRoad,
  ) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };

    var body = jsonEncode(competitorRoad.toJson());

    var url = '$URLParticipant/${competitorRoad.userId}';
    final http.Response response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    return CompetitorRoad.fromJsonMap(json: json.decode(response.body));
  }
}
