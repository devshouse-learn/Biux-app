import 'package:biux/data/models/story.dart';
import 'package:biux/data/models/user.dart';

class ReactionStory {
  int? id;
  int? storyId;
  BiuxUser? user;
  Story? story;
  int? userId;

  ReactionStory({
    this.id,
    this.user,
    this.userId,
    this.story,
    this.storyId,
  });

  ReactionStory.fromJson(Map json) {
    this.id = json["id"];
    this.userId = json["userId"];
    this.story = Story.fromJson(json["story"]);
    this.storyId = json["storyId"];
    this.user = BiuxUser.fromJsonMap(json["user"]);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "storyId": storyId,
        "userId": userId,
      };
}
