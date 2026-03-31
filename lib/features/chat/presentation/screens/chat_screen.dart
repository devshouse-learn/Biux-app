// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/chat/data/datasources/chat_datasource.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/chat/presentation/widgets/message_bubble.dart';
import 'package:biux/features/chat/presentation/widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final ChatEntity chat;

  const ChatScreen({super.key, required this.chat});

  factory ChatScreen.fromId({required String chatId}) {
    return ChatScreen(
      chat: ChatEntity(
        id: chatId,
        name: '',
        type: ChatType.direct,
        participantIds: [],
        updatedAt: DateTime.now(),
        unreadCount: {},
      ),
    );
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  late final ChatProvider _provider;

  String _otherName = '';
  String _otherPhoto = '';
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ChatProvider>();
    _provider.openChat(widget.chat.id);
    _loadOtherUserProfile();
  }

  @override
  void dispose() {
    _provider.closeChat();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOtherUserProfile() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      // 1. Obtener participantIds desde Firestore
      List<String> participants = List.from(widget.chat.participantIds);
      if (participants.isEmpty) {
        final chatDoc = await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chat.id)
            .get();
        if (chatDoc.exists) {
          participants =
              List<String>.from(chatDoc.data()?['participantIds'] ?? []);
        }
      }

      // 2. Encontrar el otro usuario
      final otherId =
          participants.firstWhere((id) => id != myUid, orElse: () => '');
      if (otherId.isEmpty) {
        if (mounted) setState(() => _loadingProfile = false);
        return;
      }

      // 3. Cargar perfil del otro usuario
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherId)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _otherName = data['fullName'] ??
              data['name'] ??
              data['userName'] ??
              data['username'] ??
              'Ciclista';
          _otherPhoto =
              data['photo'] ?? data['photoUrl'] ?? data['photoURL'] ?? '';
          _loadingProfile = false;
        });
      } else {
        if (mounted) setState(() => _loadingProfile = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;
    final userProvider = context.watch<UserProvider>();

    // Nombre y foto del usuario actual (quien envía)
    final myName = userProvider.user?.name?.isNotEmpty == true
        ? userProvider.user!.name!
        : (currentUser?.displayName?.isNotEmpty == true
            ? currentUser!.displayName!
            : 'Usuario');
    final myPhoto = userProvider.user?.photoUrl?.isNotEmpty == true
        ? userProvider.user!.photoUrl
        : currentUser?.photoURL;

    // Nombre y foto del otro usuario (AppBar)
    final displayName = _otherName.isNotEmpty ? _otherName : 'Chat';
    final displayPhoto = _otherPhoto;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0D1B2A) : const Color(0xFF16242D),
        foregroundColor: Colors.white,
        title: _loadingProfile
            ? const Row(children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white54),
                ),
                SizedBox(width: 10),
                Text('Cargando...', style: TextStyle(fontSize: 14)),
              ])
            : Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF1E8BC3),
                    backgroundImage: displayPhoto.isNotEmpty
                        ? NetworkImage(displayPhoto)
                        : null,
                    child: displayPhoto.isEmpty
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text('Chat directo',
                            style: TextStyle(
                                fontSize: 11, color: Colors.white60)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          final messages = provider.messages;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 64,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Sé el primero en enviar un mensaje',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == currentUser?.uid;
                          final showAvatar = !isMe &&
                              (index == 0 ||
                                  messages[index - 1].senderId !=
                                      msg.senderId);
                          return MessageBubble(
                            message: msg,
                            isMe: isMe,
                            showAvatar: showAvatar,
                            isDark: isDark,
                            chatId: widget.chat.id,
                            onReply: (m) => provider.setReplyingTo(m),
                            onReact: (m, emoji) => provider.addReaction(
                              chatId: widget.chat.id,
                              messageId: m.id,
                              emoji: emoji,
                            ),
                            onDelete: (m) => provider.deleteMessage(
                              chatId: widget.chat.id,
                              messageId: m.id,
                            ),
                          );
                        },
                      ),
              ),
              ChatInput(
                chatId: widget.chat.id,
                senderName: myName,
                senderAvatar: myPhoto,
                replyingTo: provider.replyingTo,
                onSendText: (text) => provider.sendTextMessage(
                  chatId: widget.chat.id,
                  text: text,
                  senderName: myName,
                  senderAvatar: myPhoto,
                ),
                onSendVoice: (path, secs) => provider.sendVoiceMessage(
                  chatId: widget.chat.id,
                  audioUrl: path,
                  durationSeconds: secs,
                  senderName: myName,
                  senderAvatar: myPhoto,
                ),
                onCancelReply: () => provider.setReplyingTo(null),
                isDark: isDark,
              ),
            ],
          );
        },
      ),
    );
  }
}
