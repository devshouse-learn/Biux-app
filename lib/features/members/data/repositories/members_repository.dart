import 'dart:io';
import 'package:biux/features/members/data/models/member.dart';
import 'package:biux/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MembersRepository {
  Future<List<Member>> getMembers(int offset) async {
    var url = '${ApiConfig.miembros}?&offset=$offset';
    var response = await http.get(Uri.parse(url));

    Map responseData = json.decode(response.body);
    List memberJson = responseData["data"];
    List<Member> members = memberJson
        .map((memberJson) => Member.fromJson(memberJson))
        .toList();

    return members;
  }

  Future<List<Member>> getMembersGroup(String id, int offset) async {
    var url = '${ApiConfig.miembrosPorGrupo(id)}&offset=$offset';

    var response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);
    List membersJson = responseData["data"];
    List<Member> roadsGroup = membersJson
        .map((membersJson) => Member.fromJson(membersJson))
        .toList();

    return roadsGroup;
  }

  Future<bool> joinGroups(String userId, String groupId) async {
    var uriResponse = await http.post(
      Uri.parse(ApiConfig.miembros),
      body: jsonEncode({"userId": userId, "groupId": groupId}),
      headers: {'Content-type': 'application/json'},
    );

    if (uriResponse.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Member> getApproved(String id, String userId) async {
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var url = '${ApiConfig.miembros}?grupo.id=$id&usuarioId=$userId';

    var response = await http.get(Uri.parse(url), headers: headers);

    Map<String, dynamic> responseData = json.decode(response.body);

    List personsJson = responseData["data"];

    return Member.fromJson(personsJson.first);
  }

  Future<List<Member>> getMyGroups(String id) async {
    var url = ApiConfig.miembrosPorUsuario(id);

    var response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);
    List membersJson = responseData["data"];
    List<Member> myGroups = membersJson
        .map((membersJson) => Member.fromJson(membersJson))
        .toList();

    return myGroups;
  }

  Future<Member> getMyGroupsUser(String id) async {
    var url = ApiConfig.miembrosPorAdmin(id);

    final http.Response response = await http.get(Uri.parse(url));

    Map<String, dynamic> responseData = json.decode(response.body);
    var memberVoid = Member(approved: false);
    List groupJson = responseData["data"].toList();
    if (groupJson.length != 0) {
      return Member.fromJson(groupJson.length == 0 ? null : groupJson.first);
    } else {
      return memberVoid;
    }
  }

  Future<Member> deleteMember(Member member) async {
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var url = ApiConfig.miembroById(member.id);
    final http.Response response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    return Member.fromJson(json.decode(response.body));
  }
}
