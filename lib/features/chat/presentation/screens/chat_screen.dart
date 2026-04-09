// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biux/features/chat/data/datasources/chat_datasource.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/chat/presentation/widgets/message_bubble.dart';
import 'package:biux/features/chat/presentation/widgets/chat_input.dart';
import 'package:biux/features/chat/domain/entities/message_entity.dart';

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
  final _imagePicker = ImagePicker();
  final _searchController = TextEditingController();

  String _otherName = '';
  String _otherPhoto = '';
  // ignore: unused_field
  String _otherUid = '';
  bool _loadingProfile = true;
  bool _isOnline = false;
  DateTime? _lastSeen;
  bool _searching = false;
  String _searchQuery = '';
  int _lastMessageCount = 0;
  MessageEntity? _pinnedMessage;
  StreamSubscription? _onlineSub;
  StreamSubscription? _pinnedSub;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ChatProvider>();
    _provider.openChat(widget.chat.id);
    _loadOtherUserProfile();
    _listenPinnedMessage();
  }

  @override
  void dispose() {
    _provider.closeChat();
    _scrollController.dispose();
    _searchController.dispose();
    _onlineSub?.cancel();
    _pinnedSub?.cancel();
    super.dispose();
  }

  void _listenPinnedMessage() {
    _pinnedSub = context
        .read<ChatProvider>()
        .ds
        .getPinnedMessage(widget.chat.id)
        .listen((msg) {
      if (mounted) setState(() => _pinnedMessage = msg);
    });
  }

  Future<void> _loadOtherUserProfile() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
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
      final otherId =
          participants.firstWhere((id) => id != myUid, orElse: () => '');
      if (otherId.isEmpty) {
        if (mounted) setState(() => _loadingProfile = false);
        return;
      }
      _otherUid = otherId;
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
      // Escuchar estado en línea
      _onlineSub = FirebaseFirestore.instance
          .collection('users')
          .doc(otherId)
          .snapshots()
          .listen((snap) {
        if (!mounted || !snap.exists) return;
        final data = snap.data()!;
        final online = data['isOnline'] ?? false;
        final lastSeenTs = data['lastSeen'] as Timestamp?;
        setState(() {
          _isOnline = online;
          _lastSeen = lastSeenTs?.toDate();
        });
      });
    } catch (e) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  String _formatLastSeen(DateTime? dt) {
    if (dt == null) return 'Última vez: desconocida';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Última vez: hace un momento';
    if (diff.inMinutes < 60) return 'Última vez: hace ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return 'Última vez hoy a las $h:$m';
    }
    return 'Última vez: ${dt.day}/${dt.month}/${dt.year}';
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _pickAndSendImage() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;
    final myName = userProvider.user?.name?.isNotEmpty == true
        ? userProvider.user!.name!
        : (currentUser?.displayName ?? 'Usuario');
    final myPhoto = userProvider.user?.photoUrl ?? currentUser?.photoURL;
    final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 75);
    if (picked == null || !mounted) return;
    await _provider.sendImageMessage(
      chatId: widget.chat.id,
      imageFile: File(picked.path),
      senderName: myName,
      senderAvatar: myPhoto,
    );
  }

  void _showForwardDialog(MessageEntity message) {
    final provider = context.read<ChatProvider>();
    final userProvider = context.read<UserProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;
    final myName = userProvider.user?.name ?? currentUser?.displayName ?? 'Usuario';
    final myPhoto = userProvider.user?.photoUrl ?? currentUser?.photoURL;
    final chats = provider.chats
        .where((c) => c.id != widget.chat.id)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2B3C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Reenviar a...',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (chats.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay otros chats disponibles',
                      style: TextStyle(color: Colors.grey)),
                )
              else
                ...chats.map((c) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: c.photoUrl != null
                            ? NetworkImage(c.photoUrl!)
                            : null,
                        child: c.photoUrl == null
                            ? Text(c.name.isNotEmpty
                                ? c.name[0].toUpperCase()
                                : '?')
                            : null,
                      ),
                      title: Text(c.name),
                      onTap: () {
                        Navigator.pop(context);
                        provider.forwardMessage(
                          message: message,
                          targetChatId: c.id,
                          senderName: myName,
                          senderAvatar: myPhoto,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mensaje reenviado a ${c.name}'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  List<dynamic> _buildItems(List<MessageEntity> messages) {
    final items = <dynamic>[];
    DateTime? lastDate;
    for (final msg in messages) {
      final d = msg.sentAt;
      final msgDate = DateTime(d.year, d.month, d.day);
      if (lastDate == null || msgDate != lastDate) {
        items.add(msgDate);
        lastDate = msgDate;
      }
      items.add(msg);
    }
    return items;
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Hoy';
    if (date == yesterday) return 'Ayer';
    const months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;
    final userProvider = context.watch<UserProvider>();

    final myName = userProvider.user?.name?.isNotEmpty == true
        ? userProvider.user!.name!
        : (currentUser?.displayName?.isNotEmpty == true
            ? currentUser!.displayName!
            : 'Usuario');
    final myPhoto = userProvider.user?.photoUrl?.isNotEmpty == true
        ? userProvider.user!.photoUrl
        : currentUser?.photoURL;

    final displayName = _otherName.isNotEmpty ? _otherName : 'Chat';
    final displayPhoto = _otherPhoto;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0D1B2A) : const Color(0xFF16242D),
        foregroundColor: Colors.white,
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Buscar mensajes...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : _loadingProfile
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
                : Row(children: [
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
                          Text(displayName,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                          Consumer<ChatProvider>(
                            builder: (_, p, __) => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: p.someoneIsTyping
                                  ? const Text('escribiendo...',
                                      key: ValueKey('typing'),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.greenAccent,
                                          fontStyle: FontStyle.italic))
                                  : Text(
                                      _isOnline
                                          ? 'En línea'
                                          : _formatLastSeen(_lastSeen),
                                      key: const ValueKey('status'),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: _isOnline
                                              ? Colors.greenAccent
                                              : Colors.white60),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
        actions: [
          if (_searching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _searching = false;
                _searchQuery = '';
                _searchController.clear();
              }),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white70),
              tooltip: 'Buscar',
              onPressed: () => setState(() => _searching = true),
            ),
            IconButton(
              icon: const Icon(Icons.photo_outlined, color: Colors.white70),
              tooltip: 'Enviar imagen',
              onPressed: _pickAndSendImage,
            ),
          ],
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          var messages = provider.messages;

          // Filtrar por búsqueda
          if (_searchQuery.isNotEmpty) {
            messages = messages
                .where((m) => m.content
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();
          }

          // Scroll automático solo cuando llegan mensajes nuevos
          if (messages.length != _lastMessageCount && _searchQuery.isEmpty) {
            _lastMessageCount = messages.length;
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());
          }

          final items = _buildItems(messages);

          return Column(
            children: [
              // Banner mensaje fijado
              if (_pinnedMessage != null)
                _PinnedMessageBanner(
                  message: _pinnedMessage!,
                  isDark: isDark,
                  onTap: () {
                    // Scroll al mensaje fijado
                    final idx = messages.indexOf(_pinnedMessage!);
                    if (idx >= 0 && _scrollController.hasClients) {
                      _scrollController.animateTo(
                        idx * 72.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  onDismiss: () => provider.pinMessage(
                    chatId: widget.chat.id,
                    messageId: _pinnedMessage!.id,
                    pin: false,
                  ),
                ),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.chat_bubble_outline,
                                size: 64,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Sin resultados para "$_searchQuery"'
                                  : 'Sé el primero en enviar un mensaje',
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
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          // Separador de fecha
                          if (item is DateTime) {
                            return Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatDateSeparator(item),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black45),
                                ),
                              ),
                            );
                          }

                          final msg = item as MessageEntity;
                          final isMe = msg.senderId == currentUser?.uid;
                          final msgIndex = messages.indexOf(msg);
                          final showAvatar = !isMe &&
                              (msgIndex == 0 ||
                                  messages[msgIndex - 1].senderId !=
                                      msg.senderId);

                          return MessageBubble(
                            message: msg,
                            isMe: isMe,
                            showAvatar: showAvatar,
                            isDark: isDark,
                            chatId: widget.chat.id,
                            currentUserId: currentUser?.uid ?? '',
                            onReply: (m) => provider.setReplyingTo(m),
                            onReact: (m, emoji) => provider.addReaction(
                              chatId: widget.chat.id,
                              messageId: m.id,
                              emoji: emoji,
                            ),
                            onDeleteForMe: (m) => provider.deleteMessageForMe(
                              chatId: widget.chat.id,
                              messageId: m.id,
                            ),
                            onDeleteForAll: (m) => provider.deleteMessage(
                              chatId: widget.chat.id,
                              messageId: m.id,
                            ),
                            onEdit: (m, newText) => provider.editMessage(
                              chatId: widget.chat.id,
                              messageId: m.id,
                              newContent: newText,
                            ),
                            onPin: (m) => provider.pinMessage(
                              chatId: widget.chat.id,
                              messageId: m.id,
                              pin: !m.isPinned,
                            ),
                            onStar: (m) => provider.starMessage(
                              chatId: widget.chat.id,
                              messageId: m.id,
                              star: !m.starredBy.contains(currentUser?.uid),
                            ),
                            onForward: (m) => _showForwardDialog(m),
                          );
                        },
                      ),
              ),
              // Typing indicator
              Consumer<ChatProvider>(
                builder: (_, p, __) => AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: p.someoneIsTyping
                      ? Padding(
                          padding:
                              const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(children: [
                            _TypingBubble(isDark: isDark),
                          ]),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              ChatInput(
                chatId: widget.chat.id,
                senderName: myName,
                senderAvatar: myPhoto,
                replyingTo: provider.replyingTo,
                onSendText: (text) {
                  provider.onTypingChanged(false);
                  provider.sendTextMessage(
                    chatId: widget.chat.id,
                    text: text,
                    senderName: myName,
                    senderAvatar: myPhoto,
                  );
                },
                onSendVoice: (path, secs) => provider.sendVoiceMessage(
                  chatId: widget.chat.id,
                  audioUrl: path,
                  durationSeconds: secs,
                  senderName: myName,
                  senderAvatar: myPhoto,
                ),
                onCancelReply: () => provider.setReplyingTo(null),
                onTypingChanged: (typing) => provider.onTypingChanged(typing),
                isDark: isDark,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Banner mensaje fijado ──────────────────────────────────────────────────

class _PinnedMessageBanner extends StatelessWidget {
  final MessageEntity message;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _PinnedMessageBanner({
    required this.message,
    required this.isDark,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2B3C) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF1E8BC3).withOpacity(0.4),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.push_pin, size: 16, color: Color(0xFF1E8BC3)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mensaje fijado',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1E8BC3),
                          fontWeight: FontWeight.w600)),
                  Text(
                    message.type == MessageType.voice
                        ? '🎤 Mensaje de voz'
                        : message.type == MessageType.image
                            ? '🖼️ Imagen'
                            : message.content,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Typing bubble ──────────────────────────────────────────────────────────

class _TypingBubble extends StatefulWidget {
  final bool isDark;
  const _TypingBubble({required this.isDark});

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A2B3C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
              final bounce =
                  offset < 0.5 ? offset * 2 : (1.0 - offset) * 2;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 7,
                height: 7 + bounce * 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
