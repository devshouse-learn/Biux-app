import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';

import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final _userCache = <String, Map<String, dynamic>>{};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<Map<String, dynamic>> _getUserData(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid]!;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      _userCache[uid] = data;
      return data;
    } catch (_) {
      return {};
    }
  }

  String _getOtherUid(List<dynamic> participants) {
    return participants.firstWhere((p) => p != _uid, orElse: () => '');
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: () => _showNewChat(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChat(context),
        backgroundColor: ColorTokens.primary30,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: Column(children: [
        // Barra de busqueda
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar conversación...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              filled: true, fillColor: ColorTokens.neutral99,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          ),
        ),
        // Lista de chats
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: chatProvider.getChatsStream(_uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: ColorTokens.primary30.withValues(alpha: 0.1)),
                    child: Icon(Icons.chat_bubble_outline, size: 64, color: ColorTokens.primary30.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 20),
                  Text('No tienes conversaciones', style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Inicia un chat con otro ciclista', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showNewChat(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo mensaje'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ]));
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final chatId = docs[i].id;
                  final participants = data['participants'] as List<dynamic>? ?? [];
                  final lastMsg = data['lastMessage'] as String? ?? '';
                  final lastTime = data['lastMessageTime'] as Timestamp?;
                  final type = data['type'] as String? ?? 'direct';
                  final isGroup = type == 'group';
                  final otherUid = isGroup ? '' : _getOtherUid(participants);

                  return FutureBuilder<Map<String, dynamic>>(
                    future: isGroup ? Future.value({}) : _getUserData(otherUid),
                    builder: (context, userSnap) {
                      final userData = userSnap.data ?? {};
                      final name = isGroup ? 'Chat grupal' : (userData['name'] as String? ?? 'Ciclista');
                      final photo = userData['photoUrl'] as String? ?? '';

                      if (_searchQuery.isNotEmpty && !name.toLowerCase().contains(_searchQuery)) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/chat/$chatId'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(children: [
                              // Avatar
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: isGroup ? Colors.blue.withValues(alpha: 0.1) : ColorTokens.primary30.withValues(alpha: 0.1),
                                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                                child: photo.isEmpty
                                    ? Icon(isGroup ? Icons.group : Icons.person, color: isGroup ? Colors.blue : ColorTokens.primary30, size: 26)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), overflow: TextOverflow.ellipsis)),
                                  if (lastTime != null) Text(timeago.format(lastTime.toDate(), locale: 'es'), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                ]),
                                const SizedBox(height: 4),
                                Text(
                                  lastMsg.isEmpty ? 'Sin mensajes aún' : lastMsg,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: lastMsg.isEmpty ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ])),
                            ]),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }

  void _showNewChat(BuildContext context) {
    final searchCtrl = TextEditingController();
    List<QueryDocumentSnapshot> results = [];
    bool searching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setBS) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollCtrl) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Nuevo mensaje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Busca un ciclista para chatear', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: searching ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))) : null,
                ),
                onChanged: (v) async {
                  if (v.trim().length < 2) { setBS(() => results = []); return; }
                  setBS(() => searching = true);
                  try {
                    final snap = await FirebaseFirestore.instance.collection('users')
                        .where('name', isGreaterThanOrEqualTo: v.trim())
                        .where('name', isLessThanOrEqualTo: '${v.trim()}\uf8ff')
                        .limit(20).get();
                    setBS(() { results = snap.docs.where((d) => d.id != _uid).toList(); searching = false; });
                  } catch (_) {
                    setBS(() => searching = false);
                  }
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: results.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.person_search, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text('Escribe un nombre para buscar', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                      ]))
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: results.length,
                        itemBuilder: (ctx, i) {
                          final userData = results[i].data() as Map<String, dynamic>;
                          final userId = results[i].id;
                          final name = userData['name'] as String? ?? 'Ciclista';
                          final photo = userData['photoUrl'] as String? ?? '';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ColorTokens.primary30.withValues(alpha: 0.1),
                              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                              child: photo.isEmpty ? const Icon(Icons.person, color: ColorTokens.primary30) : null,
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            trailing: const Icon(Icons.chat_bubble_outline, color: ColorTokens.primary30, size: 20),
                            onTap: () async {
                              Navigator.pop(ctx);
                              final chatProvider = context.read<ChatProvider>();
                              final chatId = await chatProvider.startDirectChat(_uid, userId);
                              if (chatId.isNotEmpty && context.mounted) {
                                context.push('/chat/$chatId');
                              }
                            },
                          );
                        },
                      ),
              ),
            ]),
          ),
        );
      }),
    );
  }
}
