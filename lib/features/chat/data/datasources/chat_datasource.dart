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
  });
}

class ChatDatasource {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

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
    final previewContent = message.type == MessageType.voice
        ? '🎵 Nota de voz'
        : message.content;

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
    await _db.collection('chats').doc(chatId).update({'unreadCount.$uid': 0});
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

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    // Marcar el mensaje como eliminado
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
        final prevContent = prevType == 'voice'
            ? '🎵 Nota de voz'
            : (prevData['content'] as String? ?? '');
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  ChatEntity _chatFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
    );
  }
}
