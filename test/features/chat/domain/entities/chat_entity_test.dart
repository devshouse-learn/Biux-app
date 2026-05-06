import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/chat/domain/entities/chat_entity.dart';

void main() {
  group('ChatEntity', () {
    test('debe crear chat directo por defecto', () {
      final chat = ChatEntity(id: 'chat-1', participants: ['user1', 'user2']);
      expect(chat.type, 'direct');
      expect(chat.participants.length, 2);
      expect(chat.groupId, isNull);
      expect(chat.lastMessage, isNull);
    });

    test('debe crear chat grupal', () {
      final chat = ChatEntity(
        id: 'chat-2',
        participants: ['u1', 'u2', 'u3'],
        groupId: 'group-1',
        type: 'group',
      );
      expect(chat.type, 'group');
      expect(chat.groupId, 'group-1');
    });

    test('debe almacenar último mensaje', () {
      final now = DateTime.now();
      final chat = ChatEntity(
        id: 'chat-3',
        participants: ['u1', 'u2'],
        lastMessage: 'Hola!',
        lastMessageTime: now,
      );
      expect(chat.lastMessage, 'Hola!');
      expect(chat.lastMessageTime, now);
    });
  });

  group('MessageEntity', () {
    test('debe crear mensaje de texto por defecto', () {
      final msg = MessageEntity(
        id: 'msg-1',
        chatId: 'chat-1',
        senderId: 'user1',
        senderName: 'Juan',
        content: 'Hola mundo',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(msg.type, 'text');
      expect(msg.isRead, false);
      expect(msg.content, 'Hola mundo');
    });

    test('debe crear mensaje de imagen', () {
      final msg = MessageEntity(
        id: 'msg-2',
        chatId: 'chat-1',
        senderId: 'user1',
        senderName: 'Juan',
        content: 'foto.jpg',
        type: 'image',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(msg.type, 'image');
    });

    test('debe crear mensaje leído', () {
      final msg = MessageEntity(
        id: 'msg-3',
        chatId: 'chat-1',
        senderId: 'user1',
        senderName: 'Juan',
        content: 'Leído',
        createdAt: DateTime(2025, 1, 1),
        isRead: true,
      );
      expect(msg.isRead, true);
    });
  });
}
