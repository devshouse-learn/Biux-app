import 'package:biux/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/group_model.dart';
import '../../../../providers/group_provider.dart';

class ViewGroupScreen extends StatefulWidget {
  @override
  _ViewGroupScreenState createState() => _ViewGroupScreenState();
}

class _ViewGroupScreenState extends State<ViewGroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? groupId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GroupProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.blackPearl,
                foregroundColor: AppColors.white,
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final group = provider.selectedGroup;
          if (group == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Grupo no encontrado'),
                backgroundColor: AppColors.blackPearl,
                foregroundColor: AppColors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: AppColors.grey600),
                    SizedBox(height: 16),
                    Text('Grupo no encontrado'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: Text('Volver'),
                    ),
                  ],
                ),
              ),
            );
          }

          final userStatus = provider.getUserStatus(group);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.blackPearl,
                  foregroundColor: AppColors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(group.name),
                    background: group.coverUrl != null
                        ? Image.network(
                            group.coverUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.blackPearl.withOpacity(0.8),
                            child: Icon(
                              Icons.group,
                              size: 80,
                              color: AppColors.white.withOpacity(0.5),
                            ),
                          ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                // Información del grupo
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.blackPearl,
                            backgroundImage: group.logoUrl != null
                                ? NetworkImage(group.logoUrl!)
                                : null,
                            child: group.logoUrl == null
                                ? Icon(Icons.group,
                                    color: AppColors.white, size: 30)
                                : null,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${group.memberCount} miembros',
                                  style: TextStyle(
                                    color: AppColors.grey600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (group.pendingRequestCount > 0 &&
                                    userStatus == GroupMembershipStatus.admin)
                                  Text(
                                    '${group.pendingRequestCount} solicitudes pendientes',
                                    style: TextStyle(
                                      color: AppColors.vividOrange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildUserStatusChip(userStatus),
                        ],
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        group.description,
                        style: TextStyle(
                          color: AppColors.grey200,
                          fontSize: 14,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Botones de acción
                      _buildActionButtons(group, userStatus, provider),
                    ],
                  ),
                ),

                // Tabs
                if (userStatus == GroupMembershipStatus.member ||
                    userStatus == GroupMembershipStatus.admin) ...[
                  Container(
                    color: AppColors.grey200,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.blackPearl,
                      unselectedLabelColor: AppColors.grey600,
                      indicatorColor: AppColors.blackPearl,
                      tabs: [
                        Tab(text: 'Miembros (${group.memberCount})'),
                        if (userStatus == GroupMembershipStatus.admin)
                          Tab(
                              text:
                                  'Solicitudes (${group.pendingRequestCount})'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMembersTab(group),
                        if (userStatus == GroupMembershipStatus.admin)
                          _buildRequestsTab(group, provider),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserStatusChip(GroupMembershipStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case GroupMembershipStatus.admin:
        color = AppColors.green;
        text = 'Administrador';
        icon = Icons.admin_panel_settings;
        break;
      case GroupMembershipStatus.member:
        color = AppColors.blue;
        text = 'Miembro';
        icon = Icons.check_circle;
        break;
      case GroupMembershipStatus.pending:
        color = AppColors.vividOrange;
        text = 'Solicitud Pendiente';
        icon = Icons.schedule;
        break;
      case GroupMembershipStatus.notMember:
        return SizedBox.shrink();
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildActionButtons(
      GroupModel group, GroupMembershipStatus status, GroupProvider provider) {
    switch (status) {
      case GroupMembershipStatus.admin:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar edición de grupo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Función en desarrollo')),
                  );
                },
                icon: Icon(Icons.edit),
                label: Text('Editar Grupo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blackPearl,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        );

      case GroupMembershipStatus.member:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showLeaveGroupDialog(group.id, provider),
                icon: Icon(Icons.exit_to_app),
                label: Text('Salir del Grupo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        );

      case GroupMembershipStatus.pending:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _cancelJoinRequest(group.id, provider),
                icon: Icon(Icons.cancel),
                label: Text('Cancelar Solicitud'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vividOrange,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        );

      case GroupMembershipStatus.notMember:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _requestJoinGroup(group.id, provider),
                icon: Icon(Icons.group_add),
                label: Text('Solicitar Ingreso'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blackPearl,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildMembersTab(GroupModel group) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: group.memberIds.length,
      itemBuilder: (context, index) {
        final memberId = group.memberIds[index];
        final isAdmin = group.adminId == memberId;

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.blackPearl,
              child: Icon(Icons.person, color: AppColors.white),
            ),
            title: Text(memberId), // TODO: Obtener nombre real del usuario
            subtitle: isAdmin ? Text('Administrador') : null,
            trailing: isAdmin
                ? Icon(Icons.admin_panel_settings, color: AppColors.green)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab(GroupModel group, GroupProvider provider) {
    if (group.pendingRequestIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.grey600),
            SizedBox(height: 16),
            Text(
              'No hay solicitudes pendientes',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: group.pendingRequestIds.length,
      itemBuilder: (context, index) {
        final requesterId = group.pendingRequestIds[index];

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.vividOrange,
              child: Icon(Icons.person_add, color: AppColors.white),
            ),
            title: Text(requesterId), // TODO: Obtener nombre real del usuario
            subtitle: Text('Solicitud de ingreso'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      _approveRequest(group.id, requesterId, provider),
                  icon: Icon(Icons.check, color: AppColors.green),
                  tooltip: 'Aprobar',
                ),
                IconButton(
                  onPressed: () =>
                      _rejectRequest(group.id, requesterId, provider),
                  icon: Icon(Icons.close, color: AppColors.red),
                  tooltip: 'Rechazar',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _requestJoinGroup(String groupId, GroupProvider provider) async {
    final success = await provider.requestJoinGroup(groupId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud enviada correctamente'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al enviar solicitud'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _cancelJoinRequest(String groupId, GroupProvider provider) async {
    final success = await provider.cancelJoinRequest(groupId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud cancelada'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  void _showLeaveGroupDialog(String groupId, GroupProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Salir del grupo'),
        content: Text('¿Estás seguro de que quieres salir de este grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.leaveGroup(groupId);
              if (success) {
                context.pop(); // Volver a la lista de grupos
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _approveRequest(
      String groupId, String userId, GroupProvider provider) async {
    final success = await provider.approveJoinRequest(groupId, userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud aprobada'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  void _rejectRequest(
      String groupId, String userId, GroupProvider provider) async {
    final success = await provider.rejectJoinRequest(groupId, userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud rechazada'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
