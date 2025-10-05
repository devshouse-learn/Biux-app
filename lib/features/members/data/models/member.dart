class Member {
  bool approved;
  String id;
  String userId;
  String groupId;

  Member({
    this.approved = false,
    this.id = '',
    this.userId = '',
    this.groupId = '',
  });

  factory Member.fromJson(Map json) => Member(
        approved: json["approved"],
        id: json["id"],
        userId: json["userId"],
        groupId: json["groupId"],
      );

  Map<String, dynamic> toJson() => {
        "approved": approved,
        "id": id,
        "userId": userId,
        "groupId": groupId,
      };
}
