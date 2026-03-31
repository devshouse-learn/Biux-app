import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/chat/data/datasources/chat_datasource.dart';
import 'package:biux/features/chat/presentation/providers/chat_provider.dart';
import 'package:biux/features/chat/presentation/screens/chat_screen.dart';

class ViewGroupScreen extends StatefulWidget {
  @override
  _ViewGroupScreenState createState() => _ViewGroupScreenState();
}

class _ViewGroupScreenState extends State<ViewGroupScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  String? groupId;
  bool? _lastAdminStatus;
  String? _groupChatId;
  bool _loadingChat = false;

  @override
  void initState() {
    super.initState();

    // Obtener el groupId de la URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        groupId = pathSegments[1];
        if (groupId != null) {
          context.read<GroupProvider>().selectGroup(groupId!);
        }
      }
    });
  }

  void _initializeTabController(bool isAdmin) {
    // Solo reinicializar si el estado de admin cambi� o si es la primera vez
    if (_lastAdminStatus != isAdmin || _tabController == null) {
      // Dispose del controller anterior si existe
      _tabController?.dispose();

      // Ahora siempre son 4 tabs: Info, Miembros, Rodadas, y Solicitudes (solo para admin)
      final tabCount = isAdmin ? 5 : 4;
      _tabController = TabController(length: tabCount, vsync: this);
      _lastAdminStatus = isAdmin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      body: Consumer<GroupProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final group = provider.selectedGroup;
          if (group == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: ColorTokens.error50),
                    SizedBox(height: 16),
                    Text(l.t('group_not_found')),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/groups'),
                      child: Text(l.t('back_to_groups')),
                    ),
                  ],
                ),
              ),
            );
          }

          final isAdmin = group.isAdmin(provider.currentUserId ?? '');
          _initializeTabController(isAdmin);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // App Bar con imagen de portada
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: ColorTokens.neutral100,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: ColorTokens.neutral100,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/rides');
                      }
                    },
                  ),
                  actions: _buildAppBarActions(group, provider),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      group.name,
                      style: TextStyle(
                        color: ColorTokens.neutral100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: group.coverUrl != null
                        ? OptimizedNetworkImage(
                            imageUrl: group.coverUrl!,
                            imageType: 'cover',
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: ColorTokens.primary30,
                              child: Icon(
                                Icons.groups,
                                size: 80,
                                color: ColorTokens.neutral100.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: ColorTokens.primary30,
                            child: Icon(
                              Icons.groups,
                              size: 80,
                              color: ColorTokens.neutral100.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                  ),
                ),

                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: ColorTokens.secondary50,
                      labelColor: ColorTokens.primary30,
                      unselectedLabelColor: ColorTokens.neutral60,
                      tabs: [
                        Tab(text: l.t('info')),
                        Tab(text: '${l.t('members')} (${group.memberCount})'),
                        Tab(text: l.t('rides')),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 16),
                              const SizedBox(width: 4),
                              Text(l.t('group_chat')),
                            ],
                          ),
                        ),
                        if (isAdmin)
                          Tab(
                            text:
                                '${l.t('requests')} (${group.pendingRequestCount})',
                          ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(group, provider),
                _buildMembersTab(group, provider),
                _buildRidesTab(group, provider),
                _buildGroupChatTab(group),
                if (isAdmin) _buildRequestsTab(group, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String> _getOrCreateGroupChat(GroupModel group) async {
    if (_groupChatId != null) return _groupChatId!;
    setState(() => _loadingChat = true);
    final chatProvider = context.read<ChatProvider>();
    final existing = chatProvider.chats.where(
      (c) => c.type == ChatType.group && c.name == group.name,
    ).firstOrNull;
    if (existing != null) {
      _groupChatId = existing.id;
      chatProvider.openChat(existing.id);
      setState(() => _loadingChat = false);
      return existing.id;
    }
    final chatId = await chatProvider.createGroupChat(
      participantIds: group.memberIds,
      name: group.name,
      photoUrl: group.logoUrl,
    );
    chatProvider.openChat(chatId);
    _groupChatId = chatId;
    setState(() => _loadingChat = false);
    return chatId;
  }

  Widget _buildGroupChatTab(GroupModel group) {
    final l = Provider.of<LocaleNotifier>(context);
    final currentUid = context.read<ChatProvider>().currentUid;
    final isMember = group.isMember(currentUid);

    if (!isMember) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l.t('join_to_chat'),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_loadingChat) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<String>(
      future: _getOrCreateGroupChat(group),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(l.t('chat_error'), style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _groupChatId = null),
                  child: Text(l.t('retry')),
                ),
              ],
            ),
          );
        }
        final chatId = snapshot.data!;
        final chat = ChatEntity(
          id: chatId,
          name: group.name,
          photoUrl: group.logoUrl,
          type: ChatType.group,
          participantIds: group.memberIds,
          updatedAt: DateTime.now(),
          unreadCount: const {},
        );
        return ChatScreen(chat: chat);
      },
    );
  }

  Widget _buildInfoTab(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo y información básica
          Row(
            children: [
              group.logoUrl != null
                  ? ClipOval(
                      child: OptimizedNetworkImage(
                        imageUrl: group.logoUrl!,
                        width: 80,
                        height: 80,
                        imageType: 'avatar',
                        fit: BoxFit.cover,
                        errorWidget: CircleAvatar(
                          radius: 40,
                          backgroundColor: ColorTokens.primary30,
                          child: Icon(
                            Icons.groups,
                            size: 40,
                            color: ColorTokens.neutral100,
                          ),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundColor: ColorTokens.primary30,
                      child: Icon(
                        Icons.groups,
                        size: 40,
                        color: ColorTokens.neutral100,
                      ),
                    ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${group.memberCount} ${l.t('members')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${l.t('created_on')} ${_formatDate(group.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Descripción
          Text(
            l.t('description'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(group.description, style: TextStyle(fontSize: 16)),

          SizedBox(height: 32),

          // Botones de acci�n
          _buildActionButtons(group, provider),
        ],
      ),
    );
  }

  Widget _buildMembersTab(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getMembersWithNames(group),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(l.t('no_members')));
        }

        final members = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: member['userPhoto'] != null
                    ? ClipOval(
                        child: OptimizedNetworkImage(
                          imageUrl: member['userPhoto'],
                          width: 40,
                          height: 40,
                          imageType: 'avatar',
                          fit: BoxFit.cover,
                          errorWidget: CircleAvatar(child: Icon(Icons.person)),
                        ),
                      )
                    : CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  (member['userName'] as String).isNotEmpty
                      ? member['userName']
                      : l.t('group_user_no_name'),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l.t('group_member')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (member['isAdmin'])
                      Chip(
                        label: Text(l.t('admin')),
                        backgroundColor: ColorTokens.success50.withValues(
                          alpha: 0.1,
                        ),
                        labelStyle: TextStyle(color: ColorTokens.success50),
                      ),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: ColorTokens.neutral60),
                  ],
                ),
                onTap: () {
                  // Debug de datos del miembro
                  debugPrint('=== MIEMBRO CLICKEADO ===');
                  debugPrint('Datos completos del miembro: $member');
                  debugPrint('User ID: ${member['userId']}');
                  debugPrint('User Name: ${member['userName']}');
                  debugPrint('User Photo: ${member['userPhoto']}');
                  debugPrint('Is Admin: ${member['isAdmin']}');
                  debugPrint('========================');

                  // Verificar que el userId no esté vacío
                  final userId = member['userId'];
                  if (userId != null && userId.toString().isNotEmpty) {
                    debugPrint('🔄 Navegando al perfil: /user-profile/$userId');
                    context.push('/user-profile/$userId');
                  } else {
                    debugPrint('❌ Error: userId está vacío o es null');
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.t('error_user_id_not_available')),
                          backgroundColor: ColorTokens.error50,
                        ),
                      );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRidesTab(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    return FutureBuilder<List<RideModel>>(
      future: provider.getRidesByGroup(group),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_bike,
                  size: 80,
                  color: ColorTokens.neutral60,
                ),
                SizedBox(height: 16),
                Text(
                  l.t('no_rides_in_this_group'),
                  style: TextStyle(fontSize: 18, color: ColorTokens.neutral60),
                ),
                SizedBox(height: 16),
                if (group.isAdmin(provider.currentUserId ?? ''))
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a crear rodada
                      context.go('/rides/create/${group.id}');
                    },
                    icon: Icon(Icons.add),
                    label: Text(l.t('create_first_ride')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                      foregroundColor: ColorTokens.neutral100,
                    ),
                  ),
              ],
            ),
          );
        }

        final rides = snapshot.data!;
        return Column(
          children: [
            // Bot�n para crear rodada (solo para admins)
            if (group.isAdmin(provider.currentUserId ?? ''))
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go('/rides/create/${group.id}');
                    },
                    icon: Icon(Icons.add),
                    label: Text(l.t('create_ride')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                      foregroundColor: ColorTokens.neutral100,
                    ),
                  ),
                ),
              ),

            // Lista de rodadas
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getDifficultyColor(ride.difficulty),
                        child: Icon(
                          Icons.directions_bike,
                          color: ColorTokens.neutral100,
                        ),
                      ),
                      title: Text(
                        ride.name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.t('date_label')}: ${_formatDateTime(ride.dateTime)}',
                          ),
                          Text('${l.t('distance')}: ${ride.kilometers} km'),
                          Text(
                            '${l.t('difficulty')}: ${_getDifficultyName(ride.difficulty)}',
                          ),
                          Text(
                            '${l.t('participants')}: ${ride.participants.length}',
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          // Navegar a la pantalla de detalles de la rodada
                          context.push('/rides/${ride.id}');
                        },
                        icon: Icon(Icons.arrow_forward),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestsTab(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getPendingRequestsWithNames(group),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: ColorTokens.neutral60,
                ),
                SizedBox(height: 16),
                Text(
                  l.t('no_pending_requests'),
                  style: TextStyle(fontSize: 18, color: ColorTokens.neutral60),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: request['userPhoto'] != null
                    ? ClipOval(
                        child: OptimizedNetworkImage(
                          imageUrl: request['userPhoto'],
                          width: 40,
                          height: 40,
                          imageType: 'avatar',
                          fit: BoxFit.cover,
                          errorWidget: CircleAvatar(child: Icon(Icons.person)),
                        ),
                      )
                    : CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  (request['userName'] as String).isNotEmpty
                      ? request['userName']
                      : l.t('group_user_no_name'),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l.t('pending_request')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _approveRequest(
                        group.id,
                        request['userId'],
                        request['userName'],
                        provider,
                      ),
                      icon: Icon(Icons.check, color: ColorTokens.success50),
                      tooltip: l.t('approve'),
                    ),
                    IconButton(
                      onPressed: () => _rejectRequest(
                        group.id,
                        request['userId'],
                        request['userName'],
                        provider,
                      ),
                      icon: Icon(Icons.close, color: ColorTokens.error50),
                      tooltip: l.t('reject'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteGroupDialog(GroupModel group, GroupProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar grupo?'),
        content: Text(
          'Esta acción es permanente y eliminará "${group.name}" para todos los miembros. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteGroup(group.id);
              if (success && mounted) {
                context.go('/rides');
              }
            },
            style: TextButton.styleFrom(foregroundColor: ColorTokens.error50),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    final userStatus = provider.getUserStatus(group);
    List<Widget> actions = [];

    switch (userStatus) {
      case GroupMembershipStatus.admin:
        actions.add(
          IconButton(
            onPressed: () => context.go('/groups/${group.id}/edit'),
            icon: Icon(Icons.edit),
            tooltip: l.t('edit_group'),
          ),
        );
        // Solo el dueño (adminId) puede eliminar el grupo
        if (group.adminId == provider.currentUserId) {
          actions.add(
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteGroupDialog(group, provider);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: ColorTokens.error50),
                      SizedBox(width: 8),
                      Text(
                        'Eliminar grupo',
                        style: TextStyle(color: ColorTokens.error50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        break;
      case GroupMembershipStatus.member:
        actions.add(
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') {
                _showLeaveGroupDialog(group, provider);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: ColorTokens.error50),
                    SizedBox(width: 8),
                    Text(l.t('leave_group')),
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case GroupMembershipStatus.pending:
        actions.add(
          IconButton(
            onPressed: () => _cancelRequest(group.id, provider),
            icon: Icon(Icons.cancel),
            tooltip: l.t('cancel_request'),
          ),
        );
        break;
      case GroupMembershipStatus.notMember:
        actions.add(
          IconButton(
            onPressed: () => _requestJoinGroup(group.id, provider),
            icon: Icon(Icons.group_add),
            tooltip: l.t('request_join'),
          ),
        );
        break;
    }

    return actions;
  }

  Widget _buildActionButtons(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    final userStatus = provider.getUserStatus(group);

    switch (userStatus) {
      case GroupMembershipStatus.admin:
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorTokens.success50.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorTokens.success50.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: ColorTokens.success50),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.t('you_are_admin'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.success50,
                      ),
                    ),
                    Text(
                      l.t('edit_from_menu'),
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorTokens.neutral60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case GroupMembershipStatus.member:
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorTokens.secondary50.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorTokens.secondary50.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: ColorTokens.secondary50),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.t('already_member'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.secondary50,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case GroupMembershipStatus.pending:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _cancelRequest(group.id, provider),
            icon: Icon(Icons.cancel),
            label: Text(l.t('cancel_request')),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.warning50,
              foregroundColor: ColorTokens.neutral100,
            ),
          ),
        );

      case GroupMembershipStatus.notMember:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _requestJoinGroup(group.id, provider),
            icon: Icon(Icons.group_add),
            label: Text(l.t('request_join')),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary30,
              foregroundColor: ColorTokens.neutral100,
            ),
          ),
        );
    }
  }

  void _approveRequest(
    String groupId,
    String userId,
    String userName,
    GroupProvider provider,
  ) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final success = await provider.approveJoinRequest(groupId, userId);
    if (success) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName ${l.t('user_accepted')}'),
            backgroundColor: ColorTokens.success50,
          ),
        );
    } else {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('error_approving_request')),
            backgroundColor: ColorTokens.error50,
          ),
        );
    }
  }

  void _rejectRequest(
    String groupId,
    String userId,
    String userName,
    GroupProvider provider,
  ) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final success = await provider.rejectJoinRequest(groupId, userId);
    if (success) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.t('request_of_rejected').replaceAll('{name}', userName),
            ),
            backgroundColor: ColorTokens.warning50,
          ),
        );
    } else {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('error_rejecting_request')),
            backgroundColor: ColorTokens.error50,
          ),
        );
    }
  }

  void _requestJoinGroup(String groupId, GroupProvider provider) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final result = await provider.requestJoinGroup(groupId);

    if (result['success'] == true) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('request_sent')),
            backgroundColor: ColorTokens.success50,
          ),
        );
    } else if (result['requiresProfile'] == true) {
      _showProfileRequiredDialog(result['error'] ?? l.t('to_join_you_need'));
    } else {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? l.t('error_sending_request')),
            backgroundColor: ColorTokens.error50,
          ),
        );
    }
  }

  void _showProfileRequiredDialog(String message) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('complete_profile')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/profile');
            },
            child: Text(l.t('go_to_profile')),
          ),
        ],
      ),
    );
  }

  void _cancelRequest(String groupId, GroupProvider provider) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final success = await provider.cancelJoinRequest(groupId);
    if (success) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('request_cancelled')),
            backgroundColor: ColorTokens.success50,
          ),
        );
    }
  }

  void _showLeaveGroupDialog(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('leave_group')),
        content: Text(
          '${l.t('leave_group_confirm_with_name')} "${group.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.leaveGroup(group.id);
              if (success) {
                context.push('/groups');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
            ),
            child: Text(l.t('leave')),
          ),
        ],
      ),
    );
  }

  // Nuevo m�todo para formatear fecha y hora juntas
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // M�todo para obtener color seg�n dificultad
  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return ColorTokens.success50;
      case DifficultyLevel.medium:
        return ColorTokens.warning50;
      case DifficultyLevel.hard:
        return ColorTokens.error50;
      case DifficultyLevel.expert:
        return ColorTokens.primary30;
    }
  }

  // M�todo para obtener nombre de dificultad
  String _getDifficultyName(DifficultyLevel difficulty) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    switch (difficulty) {
      case DifficultyLevel.easy:
        return l.t('difficulty_easy');
      case DifficultyLevel.medium:
        return l.t('difficulty_medium');
      case DifficultyLevel.hard:
        return l.t('difficulty_hard');
      case DifficultyLevel.expert:
        return l.t('difficulty_expert');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // String _formatTime(TimeOfDay time) {
  //   final hours = time.hour.toString().padLeft(2, '0');
  //   final minutes = time.minute.toString().padLeft(2, '0');
  //   return '$hours:$minutes';
  // }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
