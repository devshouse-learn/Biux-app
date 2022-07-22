

import 'package:biux/data/models/group.dart';

class Road {
  String? id;
  int? numberParticipants;
  String? name;
  String? dateTime;
  String? pointmeeting;
  String? route;
  List? modality = [];
  String? image;
  String? description;
  int? routeLevel;
  int? numberLikes;
  Group? group;
  double? distance;
  String? groupId;
  String? cityId;
  bool? type;
  bool? status;

  Road({
    this.id,
    this.numberParticipants,
    //  this.comentarios,
    this.name,
    this.dateTime,
    this.pointmeeting,
    this.route,
    this.modality,
    this.routeLevel,
    this.image,
    this.description,
    //  this.numeroLikes,
    this.distance,
    this.groupId,
    this.cityId,
    this.group,
    this.type,
    this.status,
  });

  Road.fromJson(Map json) {
    this.id = json["id"];
    this.numberParticipants = json["numberParticipants"];
    // this.comentarios = json["comentarios"];
    this.name = json["name"];
    this.dateTime = json["dateTime"];
    this.pointmeeting = json["pointmeeting"];
    this.route = json["route"] ?? '';
    this.modality = json["modality"];
    this.image = json["image"];
    this.description = json["description"];
    this.numberLikes = json["numberLikes"];
    this.routeLevel = json["routeLevel"];
    this.distance = json["distance"];
    this.groupId = json["groupId"];
    this.cityId = json["cityId"];
    this.group = Group.fromJson(json["group"]);
    this.type = json["type"];
    this.status = json["status"];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "numberParticipants": numberParticipants,
        //  "comentarios": comentarios,
        "name": name,
        "dateTime": dateTime,
        "pointmeeting": pointmeeting,
        "route": route,
        "modality": modality,
        "image": image,
        "description": description,
        "numberLikes": numberLikes,
        "routeLevel": routeLevel,
        "distance": distance,
        "groupId": groupId,
        "cityId": cityId,
        "type": type,
        "status": status,
      };
}
