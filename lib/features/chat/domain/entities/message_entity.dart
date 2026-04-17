import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  video,
  voice,
  location,
  deleted,
  gif,
  file,
  poll,
}

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
  // Nuevos campos
  final bool isEdited;
  final bool isPinned;
  final bool isStarred;
  final String? forwardedFrom;
  final DateTime? expiresAt;
  final String? fileName;
  final int? fileSize;
  final List<String> starredBy;

  // Poll fields
  final String? pollQuestion;
  final List<String>? pollOptions;
  final Map<String, List<String>>? pollVotes; // optionIndex -> list of userIds
  final bool pollAllowMultiple;

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
    this.isEdited = false,
    this.isPinned = false,
    this.isStarred = false,
    this.forwardedFrom,
    this.expiresAt,
    this.fileName,
    this.fileSize,
    this.starredBy = const [],
    this.pollQuestion,
    this.pollOptions,
    this.pollVotes,
    this.pollAllowMultiple = false,
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
      isEdited: data['isEdited'] ?? false,
      isPinned: data['isPinned'] ?? false,
      isStarred: data['isStarred'] ?? false,
      forwardedFrom: data['forwardedFrom'],
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      starredBy: List<String>.from(data['starredBy'] ?? []),
      pollQuestion: data['pollQuestion'],
      pollOptions: data['pollOptions'] != null
          ? List<String>.from(data['pollOptions'])
          : null,
      pollVotes: data['pollVotes'] != null
          ? (data['pollVotes'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            )
          : null,
      pollAllowMultiple: data['pollAllowMultiple'] ?? false,
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
      'isEdited': isEdited,
      'isPinned': isPinned,
      'isStarred': isStarred,
      if (forwardedFrom != null) 'forwardedFrom': forwardedFrom,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      'starredBy': starredBy,
      if (pollQuestion != null) 'pollQuestion': pollQuestion,
      if (pollOptions != null) 'pollOptions': pollOptions,
      if (pollVotes != null) 'pollVotes': pollVotes,
      if (pollAllowMultiple) 'pollAllowMultiple': pollAllowMultiple,
    };
  }

  MessageEntity copyWith({
    String? content,
    bool? isRead,
    bool? isDelivered,
    bool? deleted,
    Map<String, String>? reactions,
    bool? isEdited,
    bool? isPinned,
    bool? isStarred,
    List<String>? starredBy,
    List<String>? deletedFor,
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
      deletedFor: deletedFor ?? this.deletedFor,
      replyToId: replyToId,
      replyPreview: replyPreview,
      reactions: reactions ?? this.reactions,
      mediaUrl: mediaUrl,
      audioDurationSeconds: audioDurationSeconds,
      locationLat: locationLat,
      locationLng: locationLng,
      isEdited: isEdited ?? this.isEdited,
      isPinned: isPinned ?? this.isPinned,
      isStarred: isStarred ?? this.isStarred,
      forwardedFrom: forwardedFrom,
      expiresAt: expiresAt,
      fileName: fileName,
      fileSize: fileSize,
      starredBy: starredBy ?? this.starredBy,
      pollQuestion: pollQuestion,
      pollOptions: pollOptions,
      pollVotes: pollVotes,
      pollAllowMultiple: pollAllowMultiple,
    );
  }
}
