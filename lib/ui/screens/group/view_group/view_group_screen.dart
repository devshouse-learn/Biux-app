import 'package:biux/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/group_model.dart';
import '../../../../data/models/ride_model.dart';
import '../../../../providers/group_provider.dart';

class ViewGroupScreen extends StatefulWidget {
  @override
  _ViewGroupScreenState createState() => _ViewGroupScreenState();
}

class _ViewGroupScreenState extends State<ViewGroupScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  String? groupId;
  bool? _lastAdminStatus;

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
    // Solo reinicializar si el estado de admin cambió o si es la primera vez
    if (_lastAdminStatus != isAdmin || _tabController == null) {
      // Dispose del controller anterior si existe
      _tabController?.dispose();

      // Ahora siempre son 4 tabs: Info, Miembros, Rodadas, y Solicitudes (solo para admin)
      final tabCount = isAdmin ? 4 : 3;
      _tabController = TabController(length: tabCount, vsync: this);
      _lastAdminStatus = isAdmin;
    }
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
                backgroundColor: AppColors.blackPearl,
                foregroundColor: AppColors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: AppColors.red),
                    SizedBox(height: 16),
                    Text('Grupo no encontrado'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/groups'),
                      child: Text('Volver a Grupos'),
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
                  backgroundColor: AppColors.blackPearl,
                  foregroundColor: AppColors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      group.name,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: group.coverUrl != null
                        ? Image.network(
                            group.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.blackPearl,
                                child: Icon(
                                  Icons.group,
                                  size: 80,
                                  color: AppColors.white.withValues(alpha: 0.5),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.blackPearl,
                            child: Icon(
                              Icons.group,
                              size: 80,
                              color: AppColors.white.withValues(alpha: 0.5),
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
                      indicatorColor: AppColors.strongCyan,
                      labelColor: AppColors.blackPearl,
                      unselectedLabelColor: AppColors.grey600,
                      tabs: [
                        Tab(text: 'Info'),
                        Tab(text: 'Miembros (${group.memberCount})'),
                        Tab(text: 'Rodadas'),
                        if (isAdmin)
                          Tab(
                              text:
                                  'Solicitudes (${group.pendingRequestCount})'),
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
                if (isAdmin) _buildRequestsTab(group, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(GroupModel group, GroupProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo y información básica
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.blackPearl,
                backgroundImage:
                    group.logoUrl != null ? NetworkImage(group.logoUrl!) : null,
                child: group.logoUrl == null
                    ? Icon(Icons.group, size: 40, color: AppColors.white)
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${group.memberCount} miembros',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Creado el ${_formatDate(group.createdAt)}',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Descripción
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            group.description,
            style: TextStyle(fontSize: 16),
          ),

          SizedBox(height: 32),

          // Botones de acción
          _buildActionButtons(group, provider),
        ],
      ),
    );
  }

  Widget _buildMembersTab(GroupModel group, GroupProvider provider) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getMembersWithNames(group),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No hay miembros en este grupo'),
          );
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
                leading: CircleAvatar(
                  backgroundImage: member['userPhoto'] != null
                      ? NetworkImage(member['userPhoto'])
                      : null,
                  child:
                      member['userPhoto'] == null ? Icon(Icons.person) : null,
                ),
                title: Text(
                  member['userName'],
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(member['phoneNumber']),
                trailing: member['isAdmin']
                    ? Chip(
                        label: Text('Admin'),
                        backgroundColor: AppColors.green.withValues(alpha: 0.1),
                        labelStyle: TextStyle(color: AppColors.green),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRidesTab(GroupModel group, GroupProvider provider) {
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
                  color: AppColors.grey600,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay rodadas en este grupo',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.grey600,
                  ),
                ),
                SizedBox(height: 16),
                if (group.isAdmin(provider.currentUserId ?? ''))
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a crear rodada
                      context.go('/rides/create/${group.id}');
                    },
                    icon: Icon(Icons.add),
                    label: Text('Crear Primera Rodada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blackPearl,
                      foregroundColor: AppColors.white,
                    ),
                  ),
              ],
            ),
          );
        }

        final rides = snapshot.data!;
        return Column(
          children: [
            // Botón para crear rodada (solo para admins)
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
                    label: Text('Crear Rodada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blackPearl,
                      foregroundColor: AppColors.white,
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
                          color: AppColors.white,
                        ),
                      ),
                      title: Text(
                        ride.name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha: ${_formatDateTime(ride.dateTime)}'),
                          Text('Distancia: ${ride.kilometers} km'),
                          Text(
                              'Dificultad: ${_getDifficultyName(ride.difficulty)}'),
                          Text('Participantes: ${ride.participants.length}'),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          // Navegar a la pantalla de detalles de la rodada
                          context.go('/rides/${ride.id}');
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
                  color: AppColors.grey600,
                ),
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

        final requests = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: request['userPhoto'] != null
                      ? NetworkImage(request['userPhoto'])
                      : null,
                  child:
                      request['userPhoto'] == null ? Icon(Icons.person) : null,
                ),
                title: Text(
                  request['userName'],
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(request['phoneNumber']),
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
                      icon: Icon(Icons.check, color: AppColors.green),
                      tooltip: 'Aprobar',
                    ),
                    IconButton(
                      onPressed: () => _rejectRequest(
                        group.id,
                        request['userId'],
                        request['userName'],
                        provider,
                      ),
                      icon: Icon(Icons.close, color: AppColors.red),
                      tooltip: 'Rechazar',
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

  Widget _buildActionButtons(GroupModel group, GroupProvider provider) {
    final userStatus = provider.getUserStatus(group);

    switch (userStatus) {
      case GroupMembershipStatus.admin:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navegar a la pantalla de edición de grupo
                  context.go('/groups/${group.id}/edit');
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
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showLeaveGroupDialog(group, provider),
            icon: Icon(Icons.exit_to_app),
            label: Text('Salir del Grupo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
            ),
          ),
        );

      case GroupMembershipStatus.pending:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _cancelRequest(group.id, provider),
            icon: Icon(Icons.cancel),
            label: Text('Cancelar Solicitud'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vividOrange,
              foregroundColor: AppColors.white,
            ),
          ),
        );

      case GroupMembershipStatus.notMember:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _requestJoinGroup(group.id, provider),
            icon: Icon(Icons.group_add),
            label: Text('Solicitar Unirse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blackPearl,
              foregroundColor: AppColors.white,
            ),
          ),
        );
    }
  }

  void _approveRequest(String groupId, String userId, String userName,
      GroupProvider provider) async {
    final success = await provider.approveJoinRequest(groupId, userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$userName ha sido aceptado en el grupo'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aprobar la solicitud'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _rejectRequest(String groupId, String userId, String userName,
      GroupProvider provider) async {
    final success = await provider.rejectJoinRequest(groupId, userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud de $userName rechazada'),
          backgroundColor: AppColors.vividOrange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al rechazar la solicitud'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _requestJoinGroup(String groupId, GroupProvider provider) async {
    final result = await provider.requestJoinGroup(groupId);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud enviada correctamente'),
          backgroundColor: AppColors.green,
        ),
      );
    } else if (result['requiresProfile'] == true) {
      _showProfileRequiredDialog(
          result['error'] ?? 'Debes completar tu perfil');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al enviar solicitud'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _showProfileRequiredDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Completar Perfil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/profile');
            },
            child: Text('Ir al Perfil'),
          ),
        ],
      ),
    );
  }

  void _cancelRequest(String groupId, GroupProvider provider) async {
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

  void _showLeaveGroupDialog(GroupModel group, GroupProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Salir del Grupo'),
        content: Text('¿Estás seguro que deseas salir de "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.leaveGroup(group.id);
              if (success) {
                context.go('/groups');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text('Salir'),
          ),
        ],
      ),
    );
  }

  // Nuevo método para formatear fecha y hora juntas
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Método para obtener color según dificultad
  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.green;
      case DifficultyLevel.medium:
        return AppColors.vividOrange;
      case DifficultyLevel.hard:
        return AppColors.red;
      case DifficultyLevel.expert:
        return AppColors.blackPearl;
    }
  }

  // Método para obtener nombre de dificultad
  String _getDifficultyName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Fácil';
      case DifficultyLevel.medium:
        return 'Medio';
      case DifficultyLevel.hard:
        return 'Difícil';
      case DifficultyLevel.expert:
        return 'Experto';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
