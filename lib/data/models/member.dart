import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';

class Member {
  bool? approved;
  Group? group;
  int? groupId;
  int? id;
  BiuxUser? user;
  int? userId;
  Member({
    this.approved,
    this.group,
    this.groupId,
    this.id,
    this.user,
    this.userId,
  });

  Member.fromJson(Map json) {
    if (json != null) {
      this.approved = json["approved"];
      this.group = Group.fromJson(json: json["group"]);
      this.groupId = json["groupId"];
      this.id = json["id"];
      this.user = BiuxUser.fromJsonMap(json["user"]);
      this.userId = json["userId"];
    }
  }

  Map<String, dynamic> toJson() => {
        "approved": approved,
        "groupId": groupId,
        "id": id,
        "userId": userId,
      };
}
