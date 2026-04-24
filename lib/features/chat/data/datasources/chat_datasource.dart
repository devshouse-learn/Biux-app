import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';

enum ChatType { direct, group, ride }

class ChatEntity {
  final String id;
  final String name;
  final String? photoUrl;
  final ChatType type;
  final List<String> participantIds;
  final MessageEntity? lastMessage;
  final DateTime updatedAt;
  final Map<String, int> unreadCount;
  final Map<String, DateTime> lastReadAt;
  final Map<String, DateTime> lastDeliveredAt;

  /// Alias de participantIds (compatibilidad)
  List<String> get participants => participantIds;
  String get typeString => type.name;

  const ChatEntity({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.type,
    required this.participantIds,
    this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
    this.lastReadAt = const {},
    this.lastDeliveredAt = const {},
  });
}

class ChatDatasource {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String _previewForType(String type, String content) {
    switch (type) {
      case 'voice':
        return '🎵 Nota de voz';
      case 'image':
        return '🖼️ Imagen';
      case 'video':
        return '🎬 Video';
      case 'location':
        return '📍 Ubicación';
      case 'gif':
        return '🎞️ GIF';
      case 'file':
        return '📎 Archivo';
      case 'poll':
        return '📊 Encuesta';
      case 'deleted':
        return '🚫 Mensaje eliminado';
      default:
        return content;
    }
  }

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<List<ChatEntity>> getChats() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) {
          final chats = snap.docs.map((d) => _chatFromDoc(d)).toList();
          chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return chats;
        });
  }

  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MessageEntity.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  Future<String> createChat({
    required List<String> participantIds,
    required ChatType type,
    required String name,
    String? photoUrl,
    String? rideId,
  }) async {
    final ref = _db.collection('chats').doc();
    await ref.set({
      'id': ref.id,
      'name': name,
      'photoUrl': photoUrl,
      'type': type.name,
      'participantIds': participantIds,
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCount': {for (final id in participantIds) id: 0},
      if (rideId != null) 'rideId': rideId,
    });
    return ref.id;
  }

  Future<void> sendMessage({
    required String chatId,
    required MessageEntity message,
  }) async {
    final ref = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    final data = message.toMap();
    data['id'] = ref.id;
    await ref.set(data);

    // Obtener participantIds para incrementar unread del receptor
    final chatDoc = await _db.collection('chats').doc(chatId).get();
    final participants = List<String>.from(
      chatDoc.data()?['participantIds'] ?? [],
    );
    final unreadUpdate = <String, dynamic>{};
    for (final uid in participants) {
      if (uid != message.senderId) {
        unreadUpdate['unreadCount.$uid'] = FieldValue.increment(1);
      }
    }

    // Preview de última mensaje para la lista de chats
    final previewContent = _previewForType(message.type.name, message.content);

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': {
        'id': data['id'],
        'senderId': message.senderId,
        'senderName': message.senderName,
        'content': previewContent,
        'type': message.type.name,
        'sentAt': FieldValue.serverTimestamp(),
        if (message.mediaUrl != null) 'mediaUrl': message.mediaUrl,
      },
      'updatedAt': FieldValue.serverTimestamp(),
      ...unreadUpdate,
    });
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('chats').doc(chatId).update({
      'unreadCount.$uid': 0,
      'lastReadAt.$uid': FieldValue.serverTimestamp(),
      'lastDeliveredAt.$uid': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markMessagesAsDelivered(String chatId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('chats').doc(chatId).update({
      'lastDeliveredAt.$uid': FieldValue.serverTimestamp(),
    });
  }

  Stream<ChatEntity?> getChatStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.exists ? _chatFromDoc(doc) : null);
  }

  /// El remitente actualiza sus PROPIOS mensajes con isRead/isDelivered
  /// basándose en el lastReadAt/lastDeliveredAt del otro usuario.
  /// Solo el propietario del mensaje puede actualizarlo (senderId == currentUid).
  Future<void> syncMyMessageReadStatus({
    required String chatId,
    required DateTime otherLastReadAt,
    DateTime? otherLastDeliveredAt,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final snap = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isEqualTo: uid)
        .get();
    final batch = _db.batch();
    bool hasChanges = false;
    for (final doc in snap.docs) {
      final data = doc.data();
      final sentAt = (data['sentAt'] as Timestamp?)?.toDate();
      if (sentAt == null) continue;
      final shouldRead = !sentAt.isAfter(otherLastReadAt);
      final shouldDeliver =
          otherLastDeliveredAt != null && !sentAt.isAfter(otherLastDeliveredAt);
      final curRead = data['isRead'] as bool? ?? false;
      final curDelivered = data['isDelivered'] as bool? ?? false;
      final updates = <String, dynamic>{};
      if (shouldRead && !curRead) updates['isRead'] = true;
      if ((shouldRead || shouldDeliver) && !curDelivered) {
        updates['isDelivered'] = true;
      }
      if (updates.isNotEmpty) {
        batch.update(doc.reference, updates);
        hasChanges = true;
      }
    }
    if (hasChanges) await batch.commit();
  }

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'reactions.$uid': emoji});
  }

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'reactions.$uid': FieldValue.delete()});
  }

  /// Elimina el mensaje solo para el usuario actual (lo oculta con deletedFor)
  Future<void> deleteMessageForMe({
    required String chatId,
    required String messageId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'deletedFor': FieldValue.arrayUnion([uid]),
        });
  }

  /// Vaciar chat para el usuario actual, opcionalmente preservando mensajes destacados.
  Future<void> clearChatForMe({
    required String chatId,
    bool keepStarred = false,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final snap = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();
    // Firestore batch limit is 500, do in chunks
    final docs = snap.docs.toList();
    for (var i = 0; i < docs.length; i += 400) {
      final batch = _db.batch();
      final chunk = docs.skip(i).take(400);
      for (final doc in chunk) {
        if (keepStarred) {
          final data = doc.data();
          final rawStarred = data['starredBy'];
          if (rawStarred is List && rawStarred.any((e) => e.toString() == uid)) {
            continue;
          }
        }
        final existingDeletedFor = List<String>.from(doc.data()['deletedFor'] ?? []);
        if (existingDeletedFor.contains(uid)) continue; // ya eliminado
        batch.update(doc.reference, {
          'deletedFor': FieldValue.arrayUnion([uid]),
        });
      }
      await batch.commit();
    }
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    // Marcar el mensaje como eliminado para todos
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'deleted': true, 'content': '', 'type': 'deleted'});

    // Si el lastMessage del chat es este mismo mensaje, actualizarlo
    final chatDoc = await _db.collection('chats').doc(chatId).get();
    final lastMsgMap = chatDoc.data()?['lastMessage'] as Map?;
    if (lastMsgMap != null && lastMsgMap['id'] == messageId) {
      // Buscar el mensaje anterior más reciente que no esté eliminado
      final prevSnap = await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('sentAt', descending: true)
          .limit(5)
          .get();

      final prev = prevSnap.docs.firstWhere(
        (d) => d.id != messageId && (d.data()['deleted'] != true),
        orElse: () =>
            prevSnap.docs.isEmpty ? prevSnap.docs.first : prevSnap.docs.first,
      );

      final hasValidPrev = prevSnap.docs.any(
        (d) => d.id != messageId && (d.data()['deleted'] != true),
      );

      if (hasValidPrev) {
        final prevData = prev.data();
        final prevType = prevData['type'] as String? ?? 'text';
        final prevContent = _previewForType(
          prevType,
          prevData['content'] as String? ?? '',
        );
        await _db.collection('chats').doc(chatId).update({
          'lastMessage': {
            'id': prev.id,
            'senderId': prevData['senderId'] ?? '',
            'senderName': prevData['senderName'] ?? '',
            'content': prevContent,
            'type': prevType,
            'sentAt': prevData['sentAt'],
          },
        });
      } else {
        // No quedan mensajes válidos
        await _db.collection('chats').doc(chatId).update({'lastMessage': null});
      }
    }
  }

  // ── Editar mensaje ────────────────────────────────────────────────────────

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newContent,
  }) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'content': newContent, 'isEdited': true});
  }

  // ── Fijar mensaje ─────────────────────────────────────────────────────────

  Future<void> pinMessage({
    required String chatId,
    required String messageId,
    required bool pin,
  }) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isPinned': pin});
    // Guardar referencia en el chat
    await _db.collection('chats').doc(chatId).update({
      'pinnedMessageId': pin ? messageId : FieldValue.delete(),
    });
  }

  // ── Destacar mensaje ──────────────────────────────────────────────────────

  Future<void> starMessage({
    required String chatId,
    required String messageId,
    required bool star,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'starredBy': star
              ? FieldValue.arrayUnion([uid])
              : FieldValue.arrayRemove([uid]),
        });
  }

  // ── Reenviar mensaje ──────────────────────────────────────────────────────

  Future<void> forwardMessage({
    required MessageEntity message,
    required String targetChatId,
    required String senderName,
    String? senderAvatar,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final forwarded = MessageEntity(
      id: '',
      chatId: targetChatId,
      senderId: uid,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: message.content,
      type: message.type,
      sentAt: DateTime.now(),
      mediaUrl: message.mediaUrl,
      audioDurationSeconds: message.audioDurationSeconds,
      forwardedFrom: message.senderName,
    );
    await sendMessage(chatId: targetChatId, message: forwarded);
  }

  // ── Stream mensaje fijado ─────────────────────────────────────────────────

  Stream<MessageEntity?> getPinnedMessage(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots().asyncMap((
      doc,
    ) async {
      final pinnedId = doc.data()?['pinnedMessageId'] as String?;
      if (pinnedId == null) return null;
      final msgDoc = await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(pinnedId)
          .get();
      if (!msgDoc.exists) return null;
      return MessageEntity.fromMap(msgDoc.data()!, msgDoc.id);
    });
  }

  // ── Mensajes destacados del usuario ───────────────────────────────────────

  Stream<List<MessageEntity>> getStarredMessages(String chatId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('starredBy', arrayContains: uid)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => MessageEntity.fromMap(d.data(), d.id)).toList(),
        );
  }

  // ── Typing ────────────────────────────────────────────────────────────────

  Stream<Map<String, bool>> getTypingStream(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return <String, bool>{};
      final raw = doc.data()?['typing'];
      if (raw == null) return <String, bool>{};
      return Map<String, bool>.from(raw as Map);
    });
  }

  Future<void> setTyping({
    required String chatId,
    required bool isTyping,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db.collection('chats').doc(chatId).update({
        'typing.\$uid': isTyping,
      });
    } catch (_) {}
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  ChatEntity _chatFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    Map<String, DateTime> _parseTimestampMap(dynamic raw) {
      if (raw == null) return {};
      final result = <String, DateTime>{};
      final map = Map<String, dynamic>.from(raw as Map);
      for (final entry in map.entries) {
        final v = entry.value;
        if (v is Timestamp) result[entry.key] = v.toDate();
      }
      return result;
    }

    return ChatEntity(
      id: doc.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      type: ChatType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ChatType.direct,
      ),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      lastMessage: data['lastMessage'] != null
          ? MessageEntity.fromMap(
              data['lastMessage'],
              data['lastMessage']['id'] ?? '',
            )
          : null,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      lastReadAt: _parseTimestampMap(data['lastReadAt']),
      lastDeliveredAt: _parseTimestampMap(data['lastDeliveredAt']),
    );
  }
}
