import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Grupos'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorTokens.neutral100,
          unselectedLabelColor: ColorTokens.neutral100.withValues(alpha: 0.7),
          indicatorColor: ColorTokens.neutral100,
          tabs: [Tab(text: 'Miembro'), Tab(text: 'Administrados')],
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
        tooltip: 'Crear nuevo grupo',
      ),
    );
  }

  Widget _buildMemberGroupsTab(GroupProvider provider) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.userGroups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_outlined,
        title: 'No eres miembro de ningún grupo',
        subtitle: 'Explora grupos disponibles y únete a alguno',
        actionText: 'Ver Grupos',
        onAction: () => context.go('/groups'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.loadUserGroups();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: provider.userGroups.length,
        itemBuilder: (context, index) {
          final group = provider.userGroups[index];
          return _buildGroupCard(group, provider);
        },
      ),
    );
  }

  Widget _buildAdminGroupsTab(GroupProvider provider) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.adminGroups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.admin_panel_settings_outlined,
        title: 'No administras ningún grupo',
        subtitle: 'Crea tu primer grupo y conviértete en administrador',
        actionText: 'Crear Grupo',
        onAction: () => context.go('/groups/create'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.loadAdminGroups();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: provider.adminGroups.length,
        itemBuilder: (context, index) {
          final group = provider.adminGroups[index];
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

  Widget _buildGroupCard(GroupModel group, GroupProvider provider) {
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
                      backgroundImage:
                          group.logoUrl != null
                              ? CachedNetworkImageProvider(
                                group.logoUrl!,
                                cacheManager: OptimizedCacheManager.instance,
                              )
                              : null,
                      child:
                          group.logoUrl == null
                              ? Icon(
                                Icons.group,
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
                            '${group.memberCount} miembros',
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
                        label: Text('Admin', style: TextStyle(fontSize: 10)),
                        backgroundColor: ColorTokens.success40.withValues(
                          alpha: 0.1,
                        ),
                        side: BorderSide(color: ColorTokens.success40),
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
                      child: Text('Ver Detalles'),
                    ),
                    if (!group.isAdmin(provider.currentUserId ?? ''))
                      TextButton(
                        onPressed: () => _showLeaveGroupDialog(group, provider),
                        child: Text(
                          'Salir',
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
              color: ColorTokens.success40.withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: ColorTokens.success40,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'ADMINISTRADOR',
                  style: TextStyle(
                    color: ColorTokens.success40,
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
                      backgroundImage:
                          group.logoUrl != null
                              ? CachedNetworkImageProvider(
                                group.logoUrl!,
                                cacheManager: OptimizedCacheManager.instance,
                              )
                              : null,
                      child:
                          group.logoUrl == null
                              ? Icon(
                                Icons.group,
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
                            '${group.memberCount} miembros',
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
                          '${group.pendingRequestCount} solicitudes pendientes',
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
                        child: Text('Gestionar'),
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Salir del grupo'),
            content: Text(
              '¿Estás seguro de que quieres salir del grupo "${group.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await provider.leaveGroup(group.id);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Has salido del grupo'),
                        backgroundColor: ColorTokens.success40,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.error ?? 'Error al salir del grupo',
                        ),
                        backgroundColor: ColorTokens.error50,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.error50,
                ),
                child: Text('Salir'),
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
