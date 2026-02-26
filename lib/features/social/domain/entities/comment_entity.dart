/// Entidad de comentario
class CommentEntity {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int repliesCount;
  final bool isEdited;
  final bool isDeleted;
  final String? parentCommentId;
  final List<String> mentions;

  const CommentEntity({
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

  /// Verifica si es un comentario principal (no es respuesta)
  bool get isMainComment => parentCommentId == null;

  /// Verifica si es una respuesta a otro comentario
  bool get isReply => parentCommentId != null;

  /// Obtiene el texto para mostrar (censurado si está eliminado)
  String get displayText {
    return isDeleted ? '' : text;
  }

  /// Indica si el comentario debe ser mostrado en la UI
  bool get shouldDisplay {
    return !isDeleted;
  }

  /// Crea una copia con campos modificados
  CommentEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhoto,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? repliesCount,
    bool? isEdited,
    bool? isDeleted,
    String? parentCommentId,
    List<String>? mentions,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      mentions: mentions ?? this.mentions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
