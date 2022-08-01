import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';

class Member {
  bool approved;
  String id;
  String userId;

  Member({
    this.approved = false,
    this.id = '',
    this.userId = '',
  });

  factory Member.fromJson(Map json) => Member(
        approved: json["approved"],
        id: json["id"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "approved": approved,
        "id": id,
        "userId": userId,
      };
}
