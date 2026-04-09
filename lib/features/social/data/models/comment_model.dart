import 'package:biux/features/social/domain/entities/comment_entity.dart';

/// Modelo de comentario para Firebase Realtime Database
class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String text;
  final int createdAt;
  final int? updatedAt;
  final int likesCount;
  final int repliesCount;
  final bool isEdited;
  final bool isDeleted;
  final String? parentCommentId;
  final List<String> mentions;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.text,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isEdited = false,
    this.isDeleted = false,
    this.parentCommentId,
    this.mentions = const [],
  });

  /// Convierte de JSON (Firebase) a modelo
  factory CommentModel.fromJson(String id, Map<dynamic, dynamic> json) {
    final mentionsList = json['mentions'] as List<dynamic>?;

    return CommentModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userPhoto: json['userPhoto'] as String?,
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
      likesCount: json['likesCount'] as int? ?? 0,
      repliesCount: json['repliesCount'] as int? ?? 0,
      isEdited: json['isEdited'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      parentCommentId: json['parentCommentId'] as String?,
      mentions: mentionsList?.map((e) => e.toString()).toList() ?? [],
    );
  }

  /// Convierte de modelo a JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id, // ← AGREGAR ID
      'userId': userId,
      'userName': userName,
      if (userPhoto != null) 'userPhoto': userPhoto,
      'text': text,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      if (mentions.isNotEmpty) 'mentions': mentions,
    };
  }

  /// Convierte de modelo a entidad
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      text: text,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: updatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAt!)
          : null,
      likesCount: likesCount,
      repliesCount: repliesCount,
      isEdited: isEdited,
      isDeleted: isDeleted,
      parentCommentId: parentCommentId,
      mentions: mentions,
    );
  }

  /// Convierte de entidad a modelo
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userPhoto: entity.userPhoto,
      text: entity.text,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch,
      likesCount: entity.likesCount,
      repliesCount: entity.repliesCount,
      isEdited: entity.isEdited,
      isDeleted: entity.isDeleted,
      parentCommentId: entity.parentCommentId,
      mentions: entity.mentions,
    );
  }
}
