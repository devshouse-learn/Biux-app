import 'package:biux/data/models/user.dart';

class Story {
  String? id;
  String? description;
  BiuxUser? user;
  String? userId;

  Story({
    this.id,
    this.user,
    this.userId,
    this.description,
  });

  Story.fromJson(Map json) {
    this.id = json["id"];
    this.userId = json["userId"];
    this.description = json["description"];
    this.user = BiuxUser.fromJsonMap(json["user"]);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "userId": userId,
      };
}
