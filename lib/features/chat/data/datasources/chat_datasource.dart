import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatDatasource {
  final FirebaseFirestore _firestore;
  ChatDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createChat(
    List<String> participants, {
    String? groupId,
    String type = 'direct',
  }) async {
    final sorted = List<String>.from(participants)..sort();
    try {
      // Buscar chats existentes donde yo participo
      final myChats = await _firestore
          .collection('chats')
          .where('participants', arrayContains: sorted.first)
          .get();
      // Filtrar client-side para encontrar match exacto
      for (final doc in myChats.docs) {
        final data = doc.data();
        final docParticipants = List<String>.from(data['participants'] ?? [])
          ..sort();
        final docType = data['type'] as String? ?? 'direct';
        if (docType == type && _listEquals(docParticipants, sorted)) {
          return doc.id;
        }
      }
    } catch (e) {
      debugPrint('Error buscando chat existente: $e');
    }
    final doc = await _firestore.collection('chats').add({
      'participants': sorted,
      'groupId': groupId,
      'type': type,
      'lastMessage': null,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Stream<QuerySnapshot> getChats(String userId) {
    // Solo arrayContains, sin orderBy — evita necesitar índice compuesto
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> sendMessage(
    String chatId, {
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
  }) async {
    final batch = _firestore.batch();
    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> markAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }
}
