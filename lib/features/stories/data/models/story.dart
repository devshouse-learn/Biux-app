import 'package:biux/features/stories/data/models/reaction_story.dart';
import 'package:biux/features/users/data/models/user.dart';

class Story {
  String id;
  List<String> files;
  String description;
  List<String> tags;
  BiuxUser user;
  String creationDate;
  List<ReactionStory> listReactions;
  bool isAdvertisement;
  String get fileUrl1 {
    try {
      return files.first;
    } catch (e) {
      return '';
    }
  }

  String get fileUrl2 {
    try {
      return files[1];
    } catch (e) {
      return '';
    }
  }

  String get fileUrl3 {
    try {
      return files[2];
    } catch (e) {
      return '';
    }
  }

  Story({
    this.id = '',
    this.description = '',
    this.user = const BiuxUser(),
    this.tags = const [],
    this.files = const [],
    this.listReactions = const [],
    this.creationDate = '',
    this.isAdvertisement = false,
  });

  factory Story.fromJson(Map json, String id) => Story(
    id: id,
    files: (json['files'] as List<dynamic>).map((e) => e.toString()).toList(),
    description: json['description'],
    user: BiuxUser.fromMapStory(json['user']),
    tags: json['tags'] != null
        ? (json['tags'] as List<dynamic>).map((e) => e.toString()).toList()
        : [],
    creationDate: json['creationDate'],
    listReactions: json['listReactions'] != null
        ? (json['listReactions'] as List<dynamic>)
              .map((e) => ReactionStory.fromJson(e))
              .toList()
        : [],
    isAdvertisement: json['isAdvertisement'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'files': files,
    'description': description,
    'user': user.toMapStory(),
    'tags': tags,
    'creationDate': creationDate,
    'listReactions': listReactions.map((e) => e.toJson()).toList(),
    'isAdvertisement': isAdvertisement,
  };
}
