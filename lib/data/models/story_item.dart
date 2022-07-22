

import 'package:biux/data/models/story.dart';

class StoryItem {
  int? id;
  String? fileUrl1;
  String? fileUrl2;
  String? fileUrl3;
  int? storyId;
  Story? story;

  StoryItem({
    this.id,
    this.fileUrl1,
    this.fileUrl2,
    this.fileUrl3,
    this.storyId,
    this.story,
  });

  factory StoryItem.fromJsonMap(Map json) {
    return StoryItem(
      id: json["id"],
      fileUrl1: json["fileUrl1"],
      fileUrl2: json["fileUrl2"],
      fileUrl3: json["fileUrl3"],
      storyId: json["storyId"],
      story: Story.fromJson(
        json["story"],
      ),
    );
  }

  StoryItem.fromJson(Map json) {}

  Map<String, dynamic> toJson() => {
        "id": id,
        "fileUrl1": fileUrl1,
        "fileUrl2": fileUrl2,
        "fileUrl3": fileUrl3,
        "storyId": storyId,
      };
}
