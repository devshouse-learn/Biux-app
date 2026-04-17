import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:biux/features/chat/data/datasources/chat_datasource.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';

class ChatProvider extends ChangeNotifier {
  final _ds = ChatDatasource();

  List<ChatEntity> _chats = [];
  List<MessageEntity> _messages = [];
  ChatEntity? _activeChat;
  bool _loading = false;
  String? _error;
  String? _activeChatId;
  MessageEntity? _replyingTo;
  Map<String, bool> _otherTyping = {};
  Timer? _typingTimer;
  StreamSubscription<Map<String, bool>>? _typingSub;

  // IDs de mensajes optimistas pendientes de confirmación
  final Set<String> _pendingOptimisticIds = {};

  StreamSubscription<List<ChatEntity>>? _chatsSub;
  StreamSubscription<List<MessageEntity>>? _messagesSub;
  StreamSubscription<ChatEntity?>? _activeChatSub;

  List<ChatEntity> get chats => _chats;
  List<MessageEntity> get messages => _messages;
  ChatEntity? get activeChat => _activeChat;
  bool get loading => _loading;
  String? get error => _error;
  String? get activeChatId => _activeChatId;
  MessageEntity? get replyingTo => _replyingTo;
  Map<String, bool> get otherTyping => _otherTyping;
  bool get someoneIsTyping => _otherTyping.values.any((v) => v);
  ChatDatasource get ds => _ds;

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
    _activeChatSub?.cancel();
    _messagesSub = _ds
        .getMessages(chatId)
        .listen(
          (list) {
            // Merge: keep optimistic messages not yet confirmed by Firestore
            final serverIds = list.map((m) => m.id).toSet();
            final stillPending = _messages
                .where(
                  (m) =>
                      _pendingOptimisticIds.contains(m.id) &&
                      !serverIds.contains(m.id),
                )
                .toList();
            // Remove confirmed optimistic IDs
            _pendingOptimisticIds.removeWhere(serverIds.contains);
            _messages = _applyReadStatus([...list, ...stillPending]);
            notifyListeners();
          },
          onError: (error) {
            debugPrint('❌ Error al escuchar mensajes del chat $chatId: $error');
            _error =
                'No se pudieron cargar los mensajes. Verifica tu conexión.';
            notifyListeners();
          },
        );
    _activeChatSub = _ds.getChatStream(chatId).listen((chat) {
      _activeChat = chat;
      // Re-aplicar estado de lectura con los timestamps actualizados
      _messages = _applyReadStatus(_messages);
      notifyListeners();
    }, onError: (e) => debugPrint('❌ Error en getChatStream $chatId: $e'));
    _ds.markMessagesAsRead(chatId);

    // Escuchar typing de otros participantes
    _typingSub?.cancel();
    _typingSub = _ds.getTypingStream(chatId).listen((map) {
      _otherTyping = Map.from(map)..remove(currentUid);
      notifyListeners();
    });
  }

  void closeChat() {
    if (_activeChatId != null) {
      _ds.setTyping(chatId: _activeChatId!, isTyping: false);
    }
    _typingTimer?.cancel();
    _otherTyping = {};
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

  void onTypingChanged(bool typing) {
    if (_activeChatId == null) return;
    _typingTimer?.cancel();
    _ds.setTyping(chatId: _activeChatId!, isTyping: typing);
    if (typing) {
      _typingTimer = Timer(const Duration(seconds: 4), () {
        if (_activeChatId != null) {
          _ds.setTyping(chatId: _activeChatId!, isTyping: false);
        }
      });
    }
  }

  // ── Optimistic insert: muestra mensaje al instante en la UI ────────────
  int _tempIdCounter = 0;

  String _nextTempId() =>
      '__optimistic_${_tempIdCounter++}_${DateTime.now().millisecondsSinceEpoch}';

  void _optimisticInsert(MessageEntity msg) {
    _pendingOptimisticIds.add(msg.id);
    _messages = [..._messages, msg];
    notifyListeners();
  }

  void _removeOptimistic(String tempId) {
    _pendingOptimisticIds.remove(tempId);
    _messages = _messages.where((m) => m.id != tempId).toList();
  }

  Future<void> sendImageMessage({
    required String chatId,
    required File imageFile,
    required String senderName,
    String? senderAvatar,
  }) async {
    final tempId = _nextTempId();
    final replyId = _replyingTo?.id;
    final replyPrev = _replyingTo?.content;
    _replyingTo = null;

    // Optimistic: mostrar placeholder inmediatamente con ruta local
    final optimistic = MessageEntity(
      id: tempId,
      chatId: chatId,
      senderId: currentUid,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: '',
      type: MessageType.image,
      sentAt: DateTime.now(),
      mediaUrl: imageFile.path, // ruta local como placeholder
      replyToId: replyId,
      replyPreview: replyPrev,
    );
    _optimisticInsert(optimistic);

    try {
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Uint8List? compressed = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 50,
        format: CompressFormat.jpeg,
      );
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(chatId)
          .child(fileName);
      final uploadData = compressed ?? await imageFile.readAsBytes();
      await ref.putData(
        uploadData,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await ref.getDownloadURL();
      _removeOptimistic(tempId);
      final message = MessageEntity(
        id: '',
        chatId: chatId,
        senderId: currentUid,
        senderName: senderName,
        senderAvatar: senderAvatar,
        content: '',
        type: MessageType.image,
        sentAt: DateTime.now(),
        mediaUrl: url,
        replyToId: replyId,
        replyPreview: replyPrev,
      );
      await _ds.sendMessage(chatId: chatId, message: message);
    } catch (e) {
      _removeOptimistic(tempId);
      _error = 'No se pudo enviar la imagen';
      notifyListeners();
    }
  }

  Future<void> sendVideoMessage({
    required String chatId,
    required File videoFile,
    required String senderName,
    String? senderAvatar,
  }) async {
    final tempId = _nextTempId();
    final replyId = _replyingTo?.id;
    final replyPrev = _replyingTo?.content;
    _replyingTo = null;

    final optimistic = MessageEntity(
      id: tempId,
      chatId: chatId,
      senderId: currentUid,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: '',
      type: MessageType.video,
      sentAt: DateTime.now(),
      mediaUrl: videoFile.path,
      replyToId: replyId,
      replyPreview: replyPrev,
    );
    _optimisticInsert(optimistic);

    try {
      final ext = videoFile.path.split('.').last;
      final fileName = 'vid_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final mime = lookupMimeType(videoFile.path) ?? 'video/mp4';
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_videos')
          .child(chatId)
          .child(fileName);
      await ref.putFile(videoFile, SettableMetadata(contentType: mime));
      final url = await ref.getDownloadURL();
      _removeOptimistic(tempId);
      final message = MessageEntity(
        id: '',
        chatId: chatId,
        senderId: currentUid,
        senderName: senderName,
        senderAvatar: senderAvatar,
        content: '',
        type: MessageType.video,
        sentAt: DateTime.now(),
        mediaUrl: url,
        replyToId: replyId,
        replyPreview: replyPrev,
      );
      await _ds.sendMessage(chatId: chatId, message: message);
    } catch (e) {
      _removeOptimistic(tempId);
      _error = 'No se pudo enviar el video';
      notifyListeners();
    }
  }

  /// Envía múltiples archivos de media (imágenes, videos y/o audios) en paralelo.
  Future<void> sendMediaFiles({
    required String chatId,
    required List<File> files,
    required String senderName,
    String? senderAvatar,
  }) async {
    final futures = <Future>[];
    for (final file in files) {
      final mime = lookupMimeType(file.path) ?? '';
      if (mime.startsWith('video')) {
        futures.add(
          sendVideoMessage(
            chatId: chatId,
            videoFile: file,
            senderName: senderName,
            senderAvatar: senderAvatar,
          ),
        );
      } else if (mime.startsWith('audio')) {
        futures.add(
          sendAudioFileMessage(
            chatId: chatId,
            audioFile: file,
            senderName: senderName,
            senderAvatar: senderAvatar,
          ),
        );
      } else {
        futures.add(
          sendImageMessage(
            chatId: chatId,
            imageFile: file,
            senderName: senderName,
            senderAvatar: senderAvatar,
          ),
        );
      }
    }
    await Future.wait(futures);
  }

  /// Envía un archivo de audio almacenado (no grabación de voz).
  Future<void> sendAudioFileMessage({
    required String chatId,
    required File audioFile,
    required String senderName,
    String? senderAvatar,
  }) async {
    final tempId = _nextTempId();
    final replyId = _replyingTo?.id;
    final replyPrev = _replyingTo?.content;
    _replyingTo = null;

    final optimistic = MessageEntity(
      id: tempId,
      chatId: chatId,
      senderId: currentUid,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: '',
      type: MessageType.voice,
      sentAt: DateTime.now(),
      mediaUrl: audioFile.path,
      fileName: audioFile.path.split('/').last,
      replyToId: replyId,
      replyPreview: replyPrev,
    );
    _optimisticInsert(optimistic);

    try {
      final ext = audioFile.path.split('.').last;
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final mime = lookupMimeType(audioFile.path) ?? 'audio/mpeg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_audio')
          .child(chatId)
          .child(fileName);
      await ref.putFile(audioFile, SettableMetadata(contentType: mime));
      final url = await ref.getDownloadURL();
      _removeOptimistic(tempId);
      final message = MessageEntity(
        id: '',
        chatId: chatId,
        senderId: currentUid,
        senderName: senderName,
        senderAvatar: senderAvatar,
        content: '',
        type: MessageType.voice,
        sentAt: DateTime.now(),
        mediaUrl: url,
        fileName: audioFile.path.split('/').last,
        replyToId: replyId,
        replyPreview: replyPrev,
      );
      await _ds.sendMessage(chatId: chatId, message: message);
    } catch (e) {
      _removeOptimistic(tempId);
      _error = 'No se pudo enviar el audio';
      notifyListeners();
    }
  }

  Future<void> sendLocationMessage({
    required String chatId,
    required double lat,
    required double lng,
    required String senderName,
    String? senderAvatar,
  }) async {
    final tempId = _nextTempId();
    final message = MessageEntity(
      id: tempId,
      chatId: chatId,
      senderId: currentUid,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: '',
      type: MessageType.location,
      sentAt: DateTime.now(),
      locationLat: lat,
      locationLng: lng,
      replyToId: _replyingTo?.id,
      replyPreview: _replyingTo?.content,
    );
    _replyingTo = null;
    _optimisticInsert(message);
    // Fire-and-forget
    _ds.sendMessage(chatId: chatId, message: message.copyWith()).catchError((
      _,
    ) {
      _removeOptimistic(tempId);
      notifyListeners();
    });
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
    final tempId = _nextTempId();
    final message = MessageEntity(
      id: tempId,
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
    _optimisticInsert(message);
    // Fire-and-forget
    _ds.sendMessage(chatId: chatId, message: message.copyWith()).catchError((
      _,
    ) {
      _removeOptimistic(tempId);
      notifyListeners();
    });
  }

  Future<void> sendVoiceMessage({
    required String chatId,
    required String audioUrl,
    required int durationSeconds,
    required String senderName,
    String? senderAvatar,
  }) async {
    final tempId = _nextTempId();
    final message = MessageEntity(
      id: tempId,
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
    _optimisticInsert(message);
    _ds.sendMessage(chatId: chatId, message: message.copyWith()).catchError((
      _,
    ) {
      _removeOptimistic(tempId);
      notifyListeners();
    });
  }

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newContent,
  }) async {
    if (newContent.trim().isEmpty) return;
    await _ds.editMessage(
      chatId: chatId,
      messageId: messageId,
      newContent: newContent.trim(),
    );
  }

  Future<void> pinMessage({
    required String chatId,
    required String messageId,
    required bool pin,
  }) async {
    await _ds.pinMessage(chatId: chatId, messageId: messageId, pin: pin);
  }

  Future<void> starMessage({
    required String chatId,
    required String messageId,
    required bool star,
  }) async {
    await _ds.starMessage(chatId: chatId, messageId: messageId, star: star);
  }

  Future<void> forwardMessage({
    required MessageEntity message,
    required String targetChatId,
    required String senderName,
    String? senderAvatar,
  }) async {
    await _ds.forwardMessage(
      message: message,
      targetChatId: targetChatId,
      senderName: senderName,
      senderAvatar: senderAvatar,
    );
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

  Future<void> deleteMessageForMe({
    required String chatId,
    required String messageId,
  }) async {
    await _ds.deleteMessageForMe(chatId: chatId, messageId: messageId);
  }

  /// Stream directo de Firestore (compatibilidad con chat_list_screen)
  Stream<QuerySnapshot> getChatsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .snapshots();
  }

  /// Crea o recupera un chat directo (compatibilidad legacy)
  Future<String> startDirectChat(String myUid, String otherUid) async {
    // Buscar en Firestore si ya existe un chat directo entre estos dos usuarios
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: myUid)
        .where('type', isEqualTo: 'direct')
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final ids = List<String>.from(data['participantIds'] ?? []);
      if (ids.contains(otherUid) && ids.length == 2) {
        return doc.id;
      }
    }

    return _ds.createChat(
      participantIds: [myUid, otherUid],
      type: ChatType.direct,
      name: otherUid,
    );
  }

  /// Envío legacy con parámetros posicionales (compatibilidad)

  Future<void> sendPollMessage({
    required String chatId,
    required String question,
    required List<String> options,
    required bool allowMultiple,
    required String senderName,
    String? senderAvatar,
  }) async {
    final tempId = _nextTempId();
    final votes = <String, List<String>>{};
    for (int i = 0; i < options.length; i++) {
      votes[i.toString()] = [];
    }
    final message = MessageEntity(
      id: tempId,
      chatId: chatId,
      senderId: currentUid,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: '📊 $question',
      type: MessageType.poll,
      sentAt: DateTime.now(),
      pollQuestion: question,
      pollOptions: options,
      pollVotes: votes,
      pollAllowMultiple: allowMultiple,
      replyToId: _replyingTo?.id,
      replyPreview: _replyingTo?.content,
    );
    _replyingTo = null;
    _optimisticInsert(message);
    _ds.sendMessage(chatId: chatId, message: message.copyWith()).catchError((
      _,
    ) {
      _removeOptimistic(tempId);
      notifyListeners();
    });
  }

  Future<void> votePoll({
    required String chatId,
    required String messageId,
    required int optionIndex,
  }) async {
    final uid = currentUid;
    final ref = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data()!;
    final allowMultiple = data['pollAllowMultiple'] ?? false;
    final votes = <String, List<String>>{};
    final rawVotes = data['pollVotes'] as Map<String, dynamic>? ?? {};
    for (final entry in rawVotes.entries) {
      votes[entry.key] = List<String>.from(entry.value);
    }
    final key = optionIndex.toString();

    // Toggle vote on the selected option
    if (votes[key]?.contains(uid) == true) {
      votes[key]!.remove(uid);
    } else {
      if (!allowMultiple) {
        // Remove from all other options first
        for (final v in votes.values) {
          v.remove(uid);
        }
      }
      votes[key] = [...(votes[key] ?? []), uid];
    }
    await ref.update({'pollVotes': votes});
  }

  Future<void> sendMessage(
    String chatId, {
    required String senderId,
    required String senderName,
    required String content,
    List<String> participants = const [],
  }) async {
    final tempId = _nextTempId();
    final msg = MessageEntity(
      id: tempId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: MessageType.text,
      sentAt: DateTime.now(),
    );
    _optimisticInsert(msg);
    _ds.sendMessage(chatId: chatId, message: msg.copyWith()).catchError((_) {
      _removeOptimistic(tempId);
      notifyListeners();
    });
  }

  /// Aplica isRead/isDelivered en memoria según los timestamps del chat doc.
  /// No necesita escribir en Firestore — funciona en tiempo real.
  List<MessageEntity> _applyReadStatus(List<MessageEntity> messages) {
    if (_activeChat == null) return messages;
    final uid = currentUid;
    final otherUid = _activeChat!.participantIds.firstWhere(
      (id) => id != uid,
      orElse: () => '',
    );
    if (otherUid.isEmpty) return messages;
    final theirReadAt = _activeChat!.lastReadAt[otherUid];
    final theirDeliveredAt = _activeChat!.lastDeliveredAt[otherUid];
    return messages.map((m) {
      if (m.senderId != uid) return m;
      final computedRead =
          m.isRead || (theirReadAt != null && !m.sentAt.isAfter(theirReadAt));
      final computedDelivered =
          computedRead ||
          m.isDelivered ||
          (theirDeliveredAt != null && !m.sentAt.isAfter(theirDeliveredAt));
      if (computedRead == m.isRead && computedDelivered == m.isDelivered) {
        return m;
      }
      return m.copyWith(isRead: computedRead, isDelivered: computedDelivered);
    }).toList();
  }

  @override
  void dispose() {
    _chatsSub?.cancel();
    _messagesSub?.cancel();
    _activeChatSub?.cancel();
    super.dispose();
  }
}
