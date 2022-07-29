import 'package:biux/data/models/user.dart';

class Story {
  String id;
  String fileUrl1;
  String fileUrl2;
  String fileUrl3;
  String description;
  String userId;

  Story({
    this.id = '',
    this.fileUrl1 = '',
    this.fileUrl2 = '',
    this.fileUrl3 = '',
    this.description = '',
    this.userId = '',
  });

  factory Story.fromJson(Map json) => Story(
        id: json["id"],
        fileUrl1: json["fileUrl1"],
        fileUrl2: json["fileUrl2"],
        fileUrl3: json["fileUrl3"],
        description: json["description"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fileUrl1": fileUrl1,
        "fileUrl2": fileUrl2,
        "fileUrl3": fileUrl3,
        "description": description,
        "userId": userId,
      };
}
