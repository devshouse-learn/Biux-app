import '../../domain/entities/notification_entity.dart';

/// Modelo de notificación para Firebase Realtime Database
class NotificationModel {
  final String id;
  final String type;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhoto;
  final String? targetType;
  final String? targetId;
  final String? targetPreview;
  final String message;
  final bool isRead;
  final int timestamp;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
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
    required this.timestamp,
    this.metadata,
  });

  /// Convierte de JSON (Firebase) a modelo
  factory NotificationModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return NotificationModel(
      id: id,
      type: json['type'] as String? ?? 'like_post',
      fromUserId: json['fromUserId'] as String? ?? '',
      fromUserName: json['fromUserName'] as String? ?? '',
      fromUserPhoto: json['fromUserPhoto'] as String?,
      targetType: json['targetType'] as String?,
      targetId: json['targetId'] as String?,
      targetPreview: json['targetPreview'] as String?,
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      timestamp:
          json['createdAt'] as int? ??
          json['timestamp'] as int? ??
          0, // Soporta ambos nombres por compatibilidad
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Convierte de modelo a JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id, // ⚠️ REQUERIDO por las reglas de Firebase
      'type': type,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      if (fromUserPhoto != null) 'fromUserPhoto': fromUserPhoto,
      if (targetType != null) 'targetType': targetType,
      if (targetId != null) 'targetId': targetId,
      if (targetPreview != null) 'targetPreview': targetPreview,
      'message': message,
      'isRead': isRead,
      'createdAt': timestamp, // ⚠️ Las reglas de Firebase esperan 'createdAt'
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Convierte de modelo a entidad
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: NotificationType.fromString(type),
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserPhoto: fromUserPhoto,
      targetType: targetType != null
          ? NotificationTargetType.fromString(targetType!)
          : null,
      targetId: targetId,
      targetPreview: targetPreview,
      message: message,
      isRead: isRead,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      metadata: metadata,
    );
  }

  /// Convierte de entidad a modelo
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type.value,
      fromUserId: entity.fromUserId,
      fromUserName: entity.fromUserName,
      fromUserPhoto: entity.fromUserPhoto,
      targetType: entity.targetType?.value,
      targetId: entity.targetId,
      targetPreview: entity.targetPreview,
      message: entity.message,
      isRead: entity.isRead,
      timestamp: entity.createdAt.millisecondsSinceEpoch,
      metadata: entity.metadata,
    );
  }
}
