import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/chat/data/datasources/chat_datasource.dart';
import 'package:biux/features/chat/domain/entities/chat_entity.dart';

class ChatProvider with ChangeNotifier {
  final ChatDatasource _datasource = ChatDatasource();
  List<ChatEntity> _chats = [];
  List<MessageEntity> _messages = [];
  bool _isLoading = false;
  String? _activeChatId;
  String? _error;

  List<ChatEntity> get chats => _chats;
  List<MessageEntity> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get activeChatId => _activeChatId;
  String? get error => _error;
  int get unreadCount => _chats.where((c) => c.lastMessage != null).length;

  Stream<QuerySnapshot> getChatsStream(String userId) {
    return _datasource.getChats(userId);
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    _activeChatId = chatId;
    return _datasource.getMessages(chatId);
  }

  Future<String> startDirectChat(String userId, String otherUserId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final chatId = await _datasource.createChat([userId, otherUserId]);
      _activeChatId = chatId;
      return chatId;
    } catch (e) {
      _error = 'Error al crear chat: \$e';
      return '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> startGroupChat(String groupId, List<String> members) async {
    try {
      return await _datasource.createChat(members, groupId: groupId, type: 'group');
    } catch (e) {
      _error = 'Error: \$e';
      notifyListeners();
      return '';
    }
  }

  Future<void> sendMessage(String chatId, {
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
  }) async {
    try {
      await _datasource.sendMessage(chatId,
        senderId: senderId, senderName: senderName,
        content: content, type: type);
    } catch (e) {
      _error = 'Error al enviar: \$e';
      notifyListeners();
    }
  }
}
