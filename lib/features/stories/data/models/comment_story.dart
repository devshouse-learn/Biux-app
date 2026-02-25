class CommentStory {
  String id;
  String userId;
  String userName;
  String userPhoto;
  String text;
  String createdAt;
  int likesCount;

  CommentStory({
    this.id = '',
    this.userId = '',
    this.userName = '',
    this.userPhoto = '',
    this.text = '',
    this.createdAt = '',
    this.likesCount = 0,
  });

  factory CommentStory.fromJson(Map json) => CommentStory(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    userPhoto: json['userPhoto'],
    text: json['text'],
    createdAt: json['createdAt'],
    likesCount: json['likesCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userPhoto': userPhoto,
    'text': text,
    'createdAt': createdAt,
    'likesCount': likesCount,
  };
}
