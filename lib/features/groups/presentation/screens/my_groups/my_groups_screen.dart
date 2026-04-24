import 'package:flutter/material.dart';
import 'package:biux/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/core/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/shared/widgets/biux_refresh_indicator.dart';

class MyGroupsScreen extends StatefulWidget {
  @override
  _MyGroupsScreenState createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GroupProvider>();
      provider.loadUserGroups();
      provider.loadAdminGroups();
      provider.loadAllGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('my_groups')),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorTokens.neutral100,
          unselectedLabelColor: ColorTokens.neutral100.withValues(alpha: 0.7),
          indicatorColor: ColorTokens.neutral100,
          tabs: [
            Tab(text: l.t('member')),
            Tab(text: l.t('administered')),
          ],
        ),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMemberGroupsTab(provider),
              _buildAdminGroupsTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/groups/create'),
        backgroundColor: ColorTokens.primary30,
        child: Icon(Icons.add, color: ColorTokens.neutral100),
        tooltip: l.t('create_group'),
      ),
    );
  }

  Widget _buildMemberGroupsTab(GroupProvider provider) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final groups = provider.userGroups.isNotEmpty
        ? provider.userGroups
        : provider.allGroups;

    if (groups.isEmpty) {
      return const EmptyStateWidget(
        emoji: '🚴',
        title: 'No hay grupos disponibles',
        subtitle: 'Únete o crea un grupo para empezar',
      );
    }

    return BiuxRefreshIndicator(
      onRefresh: () async {
        provider.loadUserGroups();
        provider.loadAllGroups();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: groups.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildBanner();
          final group = groups[index - 1];
          return _buildGroupCard(group, provider);
        },
      ),
    );
  }

  Widget _buildAdminGroupsTab(GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.adminGroups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.admin_panel_settings_outlined,
        title: l.t('not_admin_any_group'),
        subtitle: l.t('create_first_group'),
        actionText: l.t('create_group'),
        onAction: () => context.go('/groups/create'),
      );
    }

    return BiuxRefreshIndicator(
      onRefresh: () async {
        provider.loadAdminGroups();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: provider.adminGroups.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildBanner();
          final group = provider.adminGroups[index - 1];
          return _buildAdminGroupCard(group, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: ColorTokens.neutral60),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: ColorTokens.neutral60),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: ColorTokens.neutral60),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary30,
              foregroundColor: ColorTokens.neutral100,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTokens.primary30,
            ColorTokens.primary30.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Text('🚴', style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aquí nadie rueda solo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Únete y no te pierdas ninguna salida',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(GroupModel group, GroupProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: group.logoUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(group.logoUrl!),
                radius: 24,
              )
            : const CircleAvatar(
                radius: 24,
                backgroundColor: ColorTokens.primary30,
                child: Icon(Icons.groups, color: ColorTokens.neutral100),
              ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${group.memberCount} miembros',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/groups/${group.id}'),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildGroupCardFull(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de portada
          if (group.coverUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: OptimizedNetworkImage(
                imageUrl: group.coverUrl!,
                height: 120,
                width: double.infinity,
                imageType: 'cover',
                fit: BoxFit.cover,
                errorWidget: Container(
                  height: 120,
                  color: ColorTokens.neutral20,
                  child: Icon(Icons.image, color: ColorTokens.neutral60),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: ColorTokens.primary30,
                      backgroundImage: group.logoUrl != null
                          ? CachedNetworkImageProvider(
                              group.logoUrl!,
                              cacheManager: OptimizedCacheManager.instance,
                            )
                          : null,
                      child: group.logoUrl == null
                          ? Icon(
                              Icons.groups,
                              color: ColorTokens.neutral100,
                              size: 20,
                            )
                          : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${group.memberCount} ${l.t('members')}',
                            style: TextStyle(
                              color: ColorTokens.neutral60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (group.isAdmin(provider.currentUserId ?? ''))
                      Chip(
                        label: Text(
                          l.t('admin'),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: ColorTokens.success40,
                        side: BorderSide.none,
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  group.description,
                  style: TextStyle(color: ColorTokens.neutral20, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/groups/${group.id}'),
                      child: Text(l.t('view_details')),
                    ),
                    if (!group.isAdmin(provider.currentUserId ?? ''))
                      TextButton(
                        onPressed: () => _showLeaveGroupDialog(group, provider),
                        child: Text(
                          l.t('leave'),
                          style: TextStyle(color: ColorTokens.error50),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminGroupCard(GroupModel group, GroupProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ColorTokens.success40, width: 1.5),
      ),
      child: ListTile(
        leading: group.logoUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(group.logoUrl!),
                radius: 24,
              )
            : const CircleAvatar(
                radius: 24,
                backgroundColor: ColorTokens.primary30,
                child: Icon(Icons.groups, color: ColorTokens.neutral100),
              ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${group.memberCount} miembros',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (group.pendingRequestCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorTokens.warning50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${group.pendingRequestCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (group.adminId == provider.currentUserId)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteGroupDialog(group, provider);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, color: ColorTokens.error50),
                        const SizedBox(width: 8),
                        Text(
                          'Eliminar grupo',
                          style: TextStyle(color: ColorTokens.error50),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.push('/groups/${group.id}'),
      ),
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

  // ignore: unused_element
  Widget _buildAdminGroupCardFull(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context);
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ColorTokens.success40.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de admin
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: ColorTokens.success40,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  l.t('administrator_label'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Imagen de portada
          if (group.coverUrl != null)
            ClipRRect(
              child: OptimizedNetworkImage(
                imageUrl: group.coverUrl!,
                imageType: 'cover',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: ColorTokens.primary30,
                      backgroundImage: group.logoUrl != null
                          ? CachedNetworkImageProvider(
                              group.logoUrl!,
                              cacheManager: OptimizedCacheManager.instance,
                            )
                          : null,
                      child: group.logoUrl == null
                          ? Icon(
                              Icons.groups,
                              color: ColorTokens.neutral100,
                              size: 20,
                            )
                          : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${group.memberCount} ${l.t('members')}',
                            style: TextStyle(
                              color: ColorTokens.neutral60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (group.pendingRequestCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorTokens.warning50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${group.pendingRequestCount}',
                          style: TextStyle(
                            color: ColorTokens.neutral100,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  group.description,
                  style: TextStyle(color: ColorTokens.neutral20, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (group.pendingRequestCount > 0) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorTokens.warning50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications,
                          color: ColorTokens.warning50,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${group.pendingRequestCount} ${l.t('pending_requests')}',
                          style: TextStyle(
                            color: ColorTokens.warning50,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go('/groups/${group.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTokens.primary30,
                          foregroundColor: ColorTokens.neutral100,
                        ),
                        child: Text(l.t('manage')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupDialog(GroupModel group, GroupProvider provider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('leave_group')),
        content: Text('${l.t('leave_group_confirm_name')} "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.leaveGroup(group.id);
              if (success) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.t('left_group')),
                      backgroundColor: ColorTokens.success40,
                    ),
                  );
              } else {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.error ?? l.t('error_leaving_group'),
                      ),
                      backgroundColor: ColorTokens.error50,
                    ),
                  );
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
