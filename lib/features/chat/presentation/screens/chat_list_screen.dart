import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:biux/shared/widgets/shimmer_loading.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final _userCache = <String, Map<String, dynamic>>{};
  late TabController _tabController;

  // Amigos (seguidores mutuos)
  List<Map<String, dynamic>> _friends = [];
  bool _loadingFriends = true;

  // Todos los usuarios que sigo
  List<Map<String, dynamic>> _followingUsers = [];
  Set<String> _mutualUidSet = {};

  // Stream cacheado para evitar recrear suscripciones
  Stream<QuerySnapshot>? _chatsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initChat();
  }

  Future<void> _initChat() async {
    // Esperar a que Firebase Auth tenga usuario si aún no lo tiene
    var uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      // Esperar al primer evento de auth
      final user = await FirebaseAuth.instance.authStateChanges().firstWhere(
        (u) => u != null,
      );
      uid = user?.uid;
    }
    if (uid != null && uid.isNotEmpty && mounted) {
      _initChatsStream(uid);
      _loadFriends();
    } else {
      if (mounted) setState(() => _loadingFriends = false);
    }
  }

  void _initChatsStream(String uid) {
    final chatProvider = context.read<ChatProvider>();
    if (mounted) {
      setState(() {
        _chatsStream = chatProvider.getChatsStream(uid);
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _loadFriends() async {
    if (_uid.isEmpty) {
      if (mounted) setState(() => _loadingFriends = false);
      return;
    }
    try {
      final myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();
      final myData = myDoc.data() ?? {};
      final myFollowers = Map<String, dynamic>.from(myData['followers'] ?? {});
      final myFollowing = Map<String, dynamic>.from(myData['following'] ?? {});

      // Amigos = usuarios que yo sigo Y que me siguen
      final mutualUids = myFollowing.keys
          .where((uid) => myFollowers.containsKey(uid))
          .toList();

      final allFollowingUsers = <Map<String, dynamic>>[];
      final friends = <Map<String, dynamic>>[];
      final mutualSet = <String>{};

      for (final uid in myFollowing.keys) {
        final userData = await _getUserData(uid);
        if (userData.isNotEmpty) {
          allFollowingUsers.add({'uid': uid, ...userData});
        }
      }

      for (final friendUid in mutualUids) {
        final userData = await _getUserData(friendUid);
        if (userData.isNotEmpty) {
          friends.add({'uid': friendUid, ...userData});
          mutualSet.add(friendUid);
        }
      }

      if (mounted) {
        setState(() {
          _friends = friends;
          _followingUsers = allFollowingUsers;
          _mutualUidSet = mutualSet;
          _loadingFriends = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFriends = false);
    }
  }

  Future<Map<String, dynamic>> _getUserData(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid]!;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? ColorTokens.primary10 : Colors.grey[50],
      body: Column(
        children: [
          Material(
            color: ColorTokens.primary30,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Chats'),
                    Tab(text: 'Amigos'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildChatsTab(), _buildFriendsTab()],
            ),
          ),
        ],
      ),
    );
  }

  // =================== TAB DE CHATS ===================
  Widget _buildChatsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Barra de busqueda
        Container(
          padding: const EdgeInsets.all(12),
          color: isDark ? ColorTokens.primary10 : Colors.white,
          child: TextField(
            controller: _searchCtrl,
            style: TextStyle(
              color: isDark ? Colors.white : ColorTokens.neutral10,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar conversación...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? ColorTokens.primary20 : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          ),
        ),
        // Lista de chats
        Expanded(
          child: _chatsStream == null
              ? const ShimmerListLoading()
              : StreamBuilder<QuerySnapshot>(
                  stream: _chatsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugPrint('Error en chats stream: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Error al cargar chats',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _chatsStream = context
                                      .read<ChatProvider>()
                                      .getChatsStream(_uid);
                                });
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorTokens.primary30.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: ColorTokens.primary30.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No tienes conversaciones',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.grey[700],
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Inicia un chat con otro ciclista',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _showNewChat(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Nuevo mensaje'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorTokens.primary30,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // Ordenar client-side por updatedAt descendente
                    final allDocs = snapshot.data!.docs.toList()
                      ..sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTime =
                            (aData['updatedAt'] ?? aData['lastMessageTime'])
                                as Timestamp?;
                        final bTime =
                            (bData['updatedAt'] ?? bData['lastMessageTime'])
                                as Timestamp?;
                        if (aTime == null && bTime == null) return 0;
                        if (aTime == null) return 1;
                        if (bTime == null) return -1;
                        return bTime.compareTo(aTime);
                      });

                    // Deduplicar: para chats directos, una sola entrada por par de usuarios
                    final seenKeys = <String>{};
                    final docs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final type = data['type'] as String? ?? 'direct';
                      // Ocultar chats de grupo y rodada (se acceden desde sus pantallas)
                      if (type == 'group' || type == 'ride') return false;
                      if (type != 'direct') return true;
                      final ids = List<String>.from(
                        data['participantIds'] ?? data['participants'] ?? [],
                      );
                      ids.sort();
                      final key = ids.join('_');
                      if (seenKeys.contains(key)) return false;
                      seenKeys.add(key);
                      return true;
                    }).toList();
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final chatId = docs[i].id;
                        final participants =
                            data['participantIds'] as List<dynamic>? ??
                            data['participants'] as List<dynamic>? ??
                            [];
                        final lastTime =
                            (data['updatedAt'] ?? data['lastMessageTime'])
                                as Timestamp?;
                        final lastMsgRaw = data['lastMessage'];
                        final String lastMsg;
                        if (lastMsgRaw is String) {
                          lastMsg = lastMsgRaw;
                        } else if (lastMsgRaw is Map) {
                          final type = lastMsgRaw['type'] as String? ?? 'text';
                          final content =
                              lastMsgRaw['content'] as String? ?? '';
                          switch (type) {
                            case 'voice':
                              lastMsg = '🎤 Audio';
                              break;
                            case 'image':
                              lastMsg = '📷 Imagen';
                              break;
                            case 'video':
                              lastMsg = '🎬 Video';
                              break;
                            case 'location':
                              lastMsg = '📍 Ubicación';
                              break;
                            case 'gif':
                              lastMsg = '🎞️ GIF';
                              break;
                            case 'file':
                              lastMsg = '📎 Archivo';
                              break;
                            case 'deleted':
                              lastMsg = '🚫 Mensaje eliminado';
                              break;
                            default:
                              lastMsg = content;
                          }
                        } else {
                          lastMsg = '';
                        }
                        final unreadCount =
                            data['unreadCount'] as Map<String, dynamic>? ?? {};
                        final unread = (unreadCount[_uid] as int?) ?? 0;
                        final type = data['type'] as String? ?? 'direct';
                        final isGroup = type == 'group';
                        final otherUid = isGroup
                            ? ''
                            : _getOtherUid(participants);

                        return FutureBuilder<Map<String, dynamic>>(
                          future: isGroup
                              ? Future.value({})
                              : _getUserData(otherUid),
                          builder: (context, userSnap) {
                            // No renderizar hasta que la data del usuario esté lista
                            if (!isGroup &&
                                userSnap.connectionState !=
                                    ConnectionState.done) {
                              return const SizedBox.shrink();
                            }
                            final userData = userSnap.data ?? {};
                            final name = isGroup
                                ? 'Chat grupal'
                                : (userData['fullName'] as String? ??
                                      userData['name'] as String? ??
                                      'Ciclista');
                            final photo =
                                userData['photoUrl'] as String? ??
                                userData['photo'] as String? ??
                                '';

                            if (_searchQuery.isNotEmpty &&
                                !name.toLowerCase().contains(_searchQuery)) {
                              return const SizedBox.shrink();
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 4),
                              color: isDark
                                  ? ColorTokens.primary20
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => context.push('/chat/$chatId'),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: isGroup
                                            ? Colors.blue.withValues(alpha: 0.1)
                                            : ColorTokens.primary30.withValues(
                                                alpha: 0.1,
                                              ),
                                        backgroundImage: photo.isNotEmpty
                                            ? NetworkImage(photo)
                                            : null,
                                        child: photo.isEmpty
                                            ? Icon(
                                                isGroup
                                                    ? Icons.group
                                                    : Icons.person,
                                                color: isGroup
                                                    ? Colors.blue
                                                    : ColorTokens.primary30,
                                                size: 26,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style: TextStyle(
                                                      fontWeight: unread > 0
                                                          ? FontWeight.w700
                                                          : FontWeight.w600,
                                                      fontSize: 15,
                                                      color: isDark
                                                          ? Colors.white
                                                          : ColorTokens
                                                                .neutral10,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (lastTime != null)
                                                  Text(
                                                    timeago.format(
                                                      lastTime.toDate(),
                                                      locale: 'es',
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: unread > 0
                                                          ? ColorTokens
                                                                .primary30
                                                          : (isDark
                                                                ? Colors.white54
                                                                : Colors
                                                                      .grey[500]),
                                                      fontWeight: unread > 0
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    lastMsg.isEmpty
                                                        ? 'Sin mensajes aún'
                                                        : lastMsg,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: unread > 0
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                      color: lastMsg.isEmpty
                                                          ? (isDark
                                                                ? Colors.white38
                                                                : Colors
                                                                      .grey[400])
                                                          : (isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                      .grey[600]),
                                                    ),
                                                  ),
                                                ),
                                                if (unread > 0)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 6,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 7,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          ColorTokens.primary30,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      unread > 99
                                                          ? '99+'
                                                          : '$unread',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
      ],
    );
  }

  /// Obtiene el nombre de un mapa de datos de usuario con fallback
  String _getUserName(Map<String, dynamic> data) {
    return data['fullName'] as String? ?? data['name'] as String? ?? 'Ciclista';
  }

  /// Obtiene la foto de un mapa de datos de usuario con fallback
  String _getUserPhoto(Map<String, dynamic> data) {
    return data['photoUrl'] as String? ?? data['photo'] as String? ?? '';
  }

  // =================== TAB DE AMIGOS ===================
  Widget _buildFriendsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_loadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorTokens.primary30.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: ColorTokens.primary30.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aún no tienes amigos',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Sigue a otros ciclistas y cuando te sigan de vuelta aparecerán aquí',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: _friends.length,
      itemBuilder: (context, i) {
        final friend = _friends[i];
        final friendUid = friend['uid'] as String;
        final name = _getUserName(friend);
        final photo = _getUserPhoto(friend);
        final username =
            friend['username'] as String? ??
            friend['userName'] as String? ??
            '';

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          color: isDark ? ColorTokens.primary20 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final chatProvider = context.read<ChatProvider>();
              final chatId = await chatProvider.startDirectChat(
                _uid,
                friendUid,
              );
              if (chatId.isNotEmpty && context.mounted) {
                context.push('/chat/$chatId');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: ColorTokens.primary30.withValues(
                      alpha: 0.1,
                    ),
                    backgroundImage: photo.isNotEmpty
                        ? NetworkImage(photo)
                        : null,
                    child: photo.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: ColorTokens.primary30,
                            size: 26,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark
                                ? Colors.white
                                : ColorTokens.neutral10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (username.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@$username',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chat_bubble_outline,
                    color: ColorTokens.primary30,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNewChat(BuildContext context) {
    final searchCtrl = TextEditingController();
    String filterQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) {
          final mIsDark = Theme.of(ctx).brightness == Brightness.dark;
          final filtered = filterQuery.isEmpty
              ? _followingUsers
              : _followingUsers
                    .where(
                      (u) =>
                          _getUserName(u).toLowerCase().contains(filterQuery),
                    )
                    .toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (ctx, scrollCtrl) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nuevo mensaje',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige un ciclista que sigues',
                    style: TextStyle(
                      color: mIsDark ? Colors.white54 : Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Filtrar por nombre...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (v) {
                      setBS(() => filterQuery = v.trim().toLowerCase());
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_search,
                                  size: 48,
                                  color: mIsDark
                                      ? Colors.white24
                                      : Colors.grey[300],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _followingUsers.isEmpty
                                      ? 'Aún no sigues a nadie'
                                      : 'Sin resultados',
                                  style: TextStyle(
                                    color: mIsDark
                                        ? Colors.white54
                                        : Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollCtrl,
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final userData = filtered[i];
                              final userId = userData['uid'] as String;
                              final name = _getUserName(userData);
                              final photo = _getUserPhoto(userData);
                              final isMutual = _mutualUidSet.contains(userId);

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: ColorTokens.primary30
                                      .withValues(alpha: 0.1),
                                  backgroundImage: photo.isNotEmpty
                                      ? NetworkImage(photo)
                                      : null,
                                  child: photo.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: ColorTokens.primary30,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: isMutual
                                    ? null
                                    : Text(
                                        'Solicitar mensaje',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                trailing: Icon(
                                  isMutual
                                      ? Icons.chat_bubble_outline
                                      : Icons.mail_outline,
                                  color: isMutual
                                      ? ColorTokens.primary30
                                      : Colors.orange[700],
                                  size: 20,
                                ),
                                onTap: () async {
                                  if (isMutual) {
                                    Navigator.pop(ctx);
                                    final chatProvider = context
                                        .read<ChatProvider>();
                                    final chatId = await chatProvider
                                        .startDirectChat(_uid, userId);
                                    if (chatId.isNotEmpty && context.mounted) {
                                      context.push('/chat/$chatId');
                                    }
                                  } else {
                                    await _sendChatRequest(userId, name);
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendChatRequest(String targetUid, String targetName) async {
    try {
      final myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();
      final myData = myDoc.data() ?? {};
      final myName =
          myData['fullName'] as String? ??
          myData['name'] as String? ??
          'Ciclista';
      final myPhoto =
          myData['photoUrl'] as String? ?? myData['photo'] as String? ?? '';

      // Verificar si ya existe una solicitud pendiente
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('chatRequests')
          .doc(_uid)
          .get();

      if (existing.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya enviaste una solicitud a este usuario'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final batch = FirebaseFirestore.instance.batch();

      // Crear solicitud de chat
      final requestRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('chatRequests')
          .doc(_uid);
      batch.set(requestRef, {
        'fromUserId': _uid,
        'fromUserName': myName,
        'fromUserPhoto': myPhoto,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Crear notificaci\u00f3n
      final notifRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('notifications')
          .doc();
      batch.set(notifRef, {
        'type': 'chat_request',
        'fromUserId': _uid,
        'fromUserName': myName,
        'fromUserPhoto': myPhoto,
        'message': '$myName quiere enviarte un mensaje',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud de mensaje enviada a $targetName'),
            backgroundColor: ColorTokens.primary30,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar la solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
