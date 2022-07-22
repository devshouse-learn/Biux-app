import 'dart:io';

import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupsRepository {
  final URL_BASE = "https://biux-prod.ibacrea.com/api/v1/grupos";
  final URLMembers = "https://biux-prod.ibacrea.com/api/v1/miembros";
  Future<List<Group>> getGroups(String cityId) async {
    var url =
        'https://biux-prod.ibacrea.com/api/v1/grupos?administrador.ciudad.nombre=$cityId&export=true';
    var response = await http.get(Uri.parse(url));

    Map responseData = json.decode(response.body);
    List<dynamic> groupsJson = responseData["data"];
    List<Group> groups =
        groupsJson.map((grupoJson) => Group.fromJson(grupoJson)).toList();

    return groups;
  }

  Future uploadLogoGroup(String id, File filePhoto) async {
    Dio dio = Dio();
    // dio.options.headers["Content-Type"] = "multipart/form-data";
    var token = await LocalStorage().getToken();
    dio.options.headers["authorization"] = token;

    FormData formData = FormData.fromMap({
      "fileLogo": await MultipartFile.fromFile(
        filePhoto.path,
      ),
    });

    Response response = await dio.patch('$URL_BASE/$id', data: formData);

    //return response.data;
  }

  Future uploadGroupProfileCover(String id, File fileProfileCover) async {
    Dio dio = Dio();
    // dio.options.headers["Content-Type"] = "multipart/form-data";
    var token = await LocalStorage().getToken();
    dio.options.headers["authorization"] = token;

    FormData formData = FormData.fromMap({
      "fileProfileCover": await MultipartFile.fromFile(
        fileProfileCover.path,
      ),
    });

    Response response = await dio.patch('$URL_BASE/$id', data: formData);

    //return response.data;
  }

  Future<Group> getSpecificGroup(String id) async {
    var url = '$URL_BASE?id=$id';
    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> responseData = json.decode(response.body);
    List groupJson = responseData["data"].toList();
    return Group.fromJson(groupJson.first);
  }

  Future<Group> getMembers(id) async {
    var url = '$URLMembers?grupo.id=$id';

    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> responseData = json.decode(response.body);
    List groupJson = responseData["data"].toList();
    return Group.fromJson(groupJson.first);
  }

  Future<List<Group>> getNamesGroups() async {
    var url = '$URL_BASE?&fields=nombre';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List groupsJson = responseData["data"];

    List<Group> groups =
        groupsJson.map((groupsJson) => Group.fromJson(groupsJson)).toList();

    if (response.statusCode == 200) {
      return groups;
    } else {
      throw Exception('Failed to submit Contact the Devolopers please ');
    }
  }

  Future<Group> updateGroup(Group group) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };

    var body = jsonEncode(group.toJson());

    var url = '$URL_BASE/${group.id}';
    final http.Response response =
        await http.patch(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return Group.fromJson(json.decode(response.body));
    } else {
      throw Exception('Fallo en actualizar grupo');
    }

    //Map<String, dynamic> responseData = json.decode(response.body);
    //return Usuario.fromJsonMap(responseData);

    //return Usuario.fromJsonMap(personasJson.first);
  }

  Future<Member> deleteGroup(Group group) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };

    var url = '$URL_BASE/${group.id}';
    final http.Response response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    return Member.fromJson(json.decode(response.body));

    //Map<String, dynamic> responseData = json.decode(response.body);
    //return Usuario.fromJsonMap(responseData);

    //return Usuario.fromJsonMap(personasJson.first);
  }
}
