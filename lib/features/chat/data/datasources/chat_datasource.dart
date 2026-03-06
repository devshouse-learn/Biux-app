import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDatasource {
  final FirebaseFirestore _firestore;
  ChatDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createChat(List<String> participants, {String? groupId, String type = 'direct'}) async {
    final existing = await _firestore.collection('chats')
        .where('participants', isEqualTo: participants..sort())
        .where('type', isEqualTo: type)
        .limit(1).get();
    if (existing.docs.isNotEmpty) return existing.docs.first.id;
    final doc = await _firestore.collection('chats').add({
      'participants': participants..sort(),
      'groupId': groupId,
      'type': type,
      'lastMessage': null,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<QuerySnapshot> getChats(String userId) {
    return _firestore.collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String chatId, {int limit = 50}) {
    return _firestore.collection('chats').doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit).snapshots();
  }

  Future<void> sendMessage(String chatId, {
    required String senderId, required String senderName,
    required String content, String type = 'text',
  }) async {
    final batch = _firestore.batch();
    final msgRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    batch.set(msgRef, {
      'senderId': senderId, 'senderName': senderName,
      'content': content, 'type': type,
      'createdAt': FieldValue.serverTimestamp(), 'isRead': false,
    });
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': content, 'lastMessageTime': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> markAsRead(String chatId, String messageId) async {
    await _firestore.collection('chats').doc(chatId)
        .collection('messages').doc(messageId).update({'isRead': true});
  }
}
