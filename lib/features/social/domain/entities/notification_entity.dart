/// Tipos de notificaciones soportadas
enum NotificationType {
  likePost('like_post'),
  likeComment('like_comment'),
  likeStory('like_story'),
  commentPost('comment_post'),
  commentRide('comment_ride'),
  replyComment('reply_comment'),
  rideJoin('ride_join'),
  mention('mention'),
  follow('follow');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.likePost,
    );
  }
}

/// Tipos de objetivo de notificación
enum NotificationTargetType {
  post('post'),
  comment('comment'),
  story('story'),
  ride('ride'),
  user('user');

  final String value;
  const NotificationTargetType(this.value);

  static NotificationTargetType fromString(String value) {
    return NotificationTargetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationTargetType.post,
    );
  }
}

/// Entidad de notificación
class NotificationEntity {
  final String id;
  final NotificationType type;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhoto;
  final NotificationTargetType? targetType;
  final String? targetId;
  final String? targetPreview;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhoto,
    this.targetType,
    this.targetId,
    this.targetPreview,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.metadata,
  });

  /// Crea una copia con campos modificados
  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? fromUserId,
    String? fromUserName,
    String? fromUserPhoto,
    NotificationTargetType? targetType,
    String? targetId,
    String? targetPreview,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserPhoto: fromUserPhoto ?? this.fromUserPhoto,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetPreview: targetPreview ?? this.targetPreview,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
