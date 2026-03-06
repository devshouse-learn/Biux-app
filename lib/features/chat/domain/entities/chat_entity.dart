class ChatEntity {
  final String id;
  final List<String> participants;
  final String? groupId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String type; // direct, group

  const ChatEntity({
    required this.id,
    required this.participants,
    this.groupId,
    this.lastMessage,
    this.lastMessageTime,
    this.type = 'direct',
  });
}

class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final String type; // text, image, location
  final DateTime createdAt;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = 'text',
    required this.createdAt,
    this.isRead = false,
  });
}
