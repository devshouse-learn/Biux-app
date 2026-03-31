import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/chat/data/datasources/chat_datasource.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';

class ChatProvider extends ChangeNotifier {
  final _ds = ChatDatasource();

  List<ChatEntity> _chats = [];
  List<MessageEntity> _messages = [];
  bool _loading = false;
  String? _error;
  String? _activeChatId;
  MessageEntity? _replyingTo;

  StreamSubscription<List<ChatEntity>>? _chatsSub;
  StreamSubscription<List<MessageEntity>>? _messagesSub;

  List<ChatEntity> get chats => _chats;
  List<MessageEntity> get messages => _messages;
  bool get loading => _loading;
  String? get error => _error;
  String? get activeChatId => _activeChatId;
  MessageEntity? get replyingTo => _replyingTo;

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  void listenChats() {
    _chatsSub?.cancel();
    _chatsSub = _ds.getChats().listen((list) {
      _chats = list;
      notifyListeners();
    });
  }

  void openChat(String chatId) {
    _activeChatId = chatId;
    _messagesSub?.cancel();
    _messagesSub = _ds.getMessages(chatId).listen((list) {
      _messages = list;
      notifyListeners();
    });
    _ds.markMessagesAsRead(chatId);
  }

  void closeChat() {
    // Mantenemos el stream activo y los mensajes en memoria
    // para que persistan al volver al chat
    _activeChatId = null;
  }

  Future<String> createDirectChat({
    required String otherUserId,
    required String otherUserName,
    String? otherUserAvatar,
  }) async {
    final uid = currentUid;
    return _ds.createChat(
      participantIds: [uid, otherUserId],
      type: ChatType.direct,
      name: otherUserName,
      photoUrl: otherUserAvatar,
    );
  }

  Future<String> createGroupChat({
    required List<String> participantIds,
    required String name,
    String? photoUrl,
    String? rideId,
  }) async {
    final uid = currentUid;
    final allIds = [uid, ...participantIds.where((id) => id != uid)];
    return _ds.createChat(
      participantIds: allIds,
      type: rideId != null ? ChatType.ride : ChatType.group,
      name: name,
      photoUrl: photoUrl,
      rideId: rideId,
    );
  }

  void setReplyingTo(MessageEntity? message) {
    _replyingTo = message;
    notifyListeners();
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String text,
    required String senderName,
    String? senderAvatar,
  }) async {
    if (text.trim().isEmpty) return;
    final message = MessageEntity(
      id: '',
      chatId: chatId,
      senderId: currentUid,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: text.trim(),
      type: MessageType.text,
      sentAt: DateTime.now(),
      replyToId: _replyingTo?.id,
      replyPreview: _replyingTo?.content,
    );
    _replyingTo = null;
    notifyListeners();
    await _ds.sendMessage(chatId: chatId, message: message);
  }

  Future<void> sendVoiceMessage({
    required String chatId,
    required String audioUrl,
    required int durationSeconds,
    required String senderName,
    String? senderAvatar,
  }) async {
    final message = MessageEntity(
      id: '',
      chatId: chatId,
      senderId: currentUid,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: '',
      type: MessageType.voice,
      sentAt: DateTime.now(),
      mediaUrl: audioUrl,
      audioDurationSeconds: durationSeconds,
    );
    await _ds.sendMessage(chatId: chatId, message: message);
  }

  Future<void> markAsRead(String chatId) async {
    await _ds.markMessagesAsRead(chatId);
  }

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    await _ds.addReaction(chatId: chatId, messageId: messageId, emoji: emoji);
  }

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
  }) async {
    await _ds.removeReaction(chatId: chatId, messageId: messageId);
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _ds.deleteMessage(chatId: chatId, messageId: messageId);
  }


  /// Stream directo de Firestore (compatibilidad con chat_list_screen)
  Stream<QuerySnapshot> getChatsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// Crea o recupera un chat directo (compatibilidad legacy)
  Future<String> startDirectChat(String myUid, String otherUid) async {
    // Buscar si ya existe
    final existing = _chats.where((c) =>
        c.type == ChatType.direct &&
        c.participantIds.contains(myUid) &&
        c.participantIds.contains(otherUid)).toList();
    if (existing.isNotEmpty) return existing.first.id;
    return _ds.createChat(
      participantIds: [myUid, otherUid],
      type: ChatType.direct,
      name: otherUid,
    );
  }

  /// Envío legacy con parámetros posicionales (compatibilidad)
  Future<void> sendMessage(
    String chatId, {
    required String senderId,
    required String senderName,
    required String content,
    List<String> participants = const [],
  }) async {
    final msg = MessageEntity(
      id: '',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: MessageType.text,
      sentAt: DateTime.now(),
    );
    await _ds.sendMessage(chatId: chatId, message: msg);
  }

  @override
  void dispose() {
    _chatsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}
