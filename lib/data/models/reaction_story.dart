class ReactionStory {
  String id;
  String username;

  ReactionStory({
    this.id = '',
    this.username = '',
  });

  factory ReactionStory.fromJson(Map json) => ReactionStory(
        id: json["id"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
      };
}
