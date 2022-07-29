import 'package:biux/data/models/story.dart';
import 'package:biux/data/models/user.dart';

class ReactionStory {
  String id;
  String userId;

  ReactionStory({
    this.id = '',
    this.userId = '',
  });

 factory ReactionStory.fromJson(Map json) => ReactionStory(
    id: json["id"] ?? '',
    userId: json["userId"] ?? '',
  );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
      };
}
