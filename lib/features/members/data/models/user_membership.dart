import 'package:biux/features/members/data/models/membership.dart';
import 'package:biux/features/users/data/models/user.dart';

class UserMembership {
  bool? stateMembership;
  int? id;
  String? startMembership;
  Membership? membership;
  int? membershipId;
  String? updatedAt;
  BiuxUser? user;
  int? userId;
  String? expirationMembership;

  UserMembership({
    this.id,
    this.stateMembership,
    this.startMembership,
    this.membershipId,
    this.membership,
    this.updatedAt,
    this.user,
    this.userId,
    this.expirationMembership,
  });

  UserMembership.fromJsonMap(Map json) {
    this.id = json["id"];
    this.stateMembership = json["stateMembership"];
    this.startMembership = json["startMembership"];
    this.membershipId = json["membershipId"];
    this.membership = Membership.fromJsonMap(json["membership"]);
    this.updatedAt = json["updatedAt"];
    this.user = BiuxUser.fromJsonMap(json["user"]);
    this.userId = json["userId"];
    this.expirationMembership = json["expirationMembership"];
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "stateMembership": stateMembership,
    "startMembership": startMembership,
    "membershipId": membershipId,
    "updatedAt": updatedAt,
    "userId": userId,
    "expirationMembership": expirationMembership,
  };
}
