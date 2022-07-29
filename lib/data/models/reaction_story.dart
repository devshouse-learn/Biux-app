import 'package:biux/data/models/story.dart';
import 'package:biux/data/models/user.dart';

class ReactionStory {
  int? id;
  int? userId;

  ReactionStory({
    this.id,
    this.userId,
  });

  ReactionStory.fromJson(Map json) {
    this.id = json["id"];
    this.userId = json["userId"];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
      };
}
