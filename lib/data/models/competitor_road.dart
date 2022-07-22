import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/user.dart';

class CompetitorRoad {
  int? id;
  Road? road;
  int? roadId;
  BiuxUser? user;
  int? userId;
  CompetitorRoad({
    this.road,
    this.roadId,
    this.id,
    this.user,
    this.userId,
  });

  CompetitorRoad.fromJson(Map json) {
    this.id = json["id"];
    this.road = Road.fromJson(json["road"]);
    this.roadId = json["roadId"];
    this.user = BiuxUser.fromJsonMap(json["user"]);
    this.userId = json["userId"];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "roadId": roadId,
        "userId": userId,
      };
}
