import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, voice, location, deleted }

class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final bool isRead;
  final bool isDelivered;
  final bool deleted;
  final List<String> deletedFor;
  final String? replyToId;
  final String? replyPreview;
  final Map<String, String> reactions;
  final String? mediaUrl;
  final int? audioDurationSeconds;
  final double? locationLat;
  final double? locationLng;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    this.type = MessageType.text,
    required this.sentAt,
    this.isRead = false,
    this.isDelivered = false,
    this.deleted = false,
    this.deletedFor = const [],
    this.replyToId,
    this.replyPreview,
    this.reactions = const {},
    this.mediaUrl,
    this.audioDurationSeconds,
    this.locationLat,
    this.locationLng,
  });

  factory MessageEntity.fromMap(Map<String, dynamic> data, String id) {
    return MessageEntity(
      id: id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'],
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => MessageType.text,
      ),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      isDelivered: data['isDelivered'] ?? false,
      deleted: data['deleted'] ?? false,
      deletedFor: List<String>.from(data['deletedFor'] ?? []),
      replyToId: data['replyToId'],
      replyPreview: data['replyPreview'],
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      mediaUrl: data['mediaUrl'],
      audioDurationSeconds: data['audioDurationSeconds'],
      locationLat: (data['locationLat'] as num?)?.toDouble(),
      locationLng: (data['locationLng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.name,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'deleted': deleted,
      'deletedFor': deletedFor,
      if (replyToId != null) 'replyToId': replyToId,
      if (replyPreview != null) 'replyPreview': replyPreview,
      'reactions': reactions,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (audioDurationSeconds != null)
        'audioDurationSeconds': audioDurationSeconds,
      if (locationLat != null) 'locationLat': locationLat,
      if (locationLng != null) 'locationLng': locationLng,
    };
  }

  MessageEntity copyWith({
    String? content,
    bool? isRead,
    bool? isDelivered,
    bool? deleted,
    Map<String, String>? reactions,
  }) {
    return MessageEntity(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content ?? this.content,
      type: type,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      deleted: deleted ?? this.deleted,
      replyToId: replyToId,
      replyPreview: replyPreview,
      reactions: reactions ?? this.reactions,
      mediaUrl: mediaUrl,
      audioDurationSeconds: audioDurationSeconds,
      locationLat: locationLat,
      locationLng: locationLng,
    );
  }
}
