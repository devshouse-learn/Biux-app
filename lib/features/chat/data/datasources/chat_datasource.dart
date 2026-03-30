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
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _chatFromDoc(d)).toList());
  }

  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageEntity.fromMap(d.data(), d.id)).toList());
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
    final ref = _db.collection('chats').doc(chatId).collection('messages').doc();
    final data = message.toMap();
    data['id'] = ref.id;
    await ref.set(data);
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('chats').doc(chatId).update({
      'unreadCount.$uid': 0,
    });
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
        .update({
      'reactions.$uid': emoji,
    });
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
        .update({
      'reactions.$uid': FieldValue.delete(),
    });
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'deleted': true, 'content': ''});
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
          ? MessageEntity.fromMap(data['lastMessage'], data['lastMessage']['id'] ?? '')
          : null,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }
}
