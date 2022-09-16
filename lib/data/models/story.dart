class Story {
  String id;
  List<String> files;
  String description;
  List<String> tags;
  String userId;
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
    this.userId = '',
    this.tags = const [],
    this.files = const [],
  });

  factory Story.fromJson(Map json) => Story(
        id: json['id'],
        files: json['files'],
        description: json['description'],
        userId: json['userId'],
        tags: json['tags'],
      );

  Map<String, dynamic> toJson() => {
        'files': files,
        'description': description,
        'userId': userId,
        'tags': tags,
      };
}
