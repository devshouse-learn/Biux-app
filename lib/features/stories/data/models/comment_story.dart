class CommentStory {
  String id;
  String userId;
  String userName;
  String userPhoto;
  String text;
  String createdAt;
  int likesCount;
  bool isDeleted; // Campo para marcar comentarios eliminados

  CommentStory({
    this.id = '',
    this.userId = '',
    this.userName = '',
    this.userPhoto = '',
    this.text = '',
    this.createdAt = '',
    this.likesCount = 0,
    this.isDeleted = false,
  });

  factory CommentStory.fromJson(Map json) => CommentStory(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    userPhoto: json['userPhoto'],
    text: json['text'],
    createdAt: json['createdAt'],
    likesCount: json['likesCount'] ?? 0,
    isDeleted: json['isDeleted'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userPhoto': userPhoto,
    'text': text,
    'createdAt': createdAt,
    'likesCount': likesCount,
    'isDeleted': isDeleted,
  };

  /// Indica si el comentario debe ser mostrado en la UI
  bool get shouldDisplay {
    return !isDeleted;
  }
}
