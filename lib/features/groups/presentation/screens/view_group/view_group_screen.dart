import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';

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
    // Solo reinicializar si el estado de admin cambi� o si es la primera vez
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
                    Text('Grupo no encontrado'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/groups'),
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
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: ColorTokens.neutral100,
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
                                Icons.group,
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
                              Icons.group,
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
                        Tab(text: 'Info'),
                        Tab(text: 'Miembros (${group.memberCount})'),
                        Tab(text: 'Rodadas'),
                        if (isAdmin)
                          Tab(
                            text: 'Solicitudes (${group.pendingRequestCount})',
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
                            Icons.group,
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
                        Icons.group,
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
                      '${group.memberCount} miembros',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Creado el ${_formatDate(group.createdAt)}',
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
            'Descripción',
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getMembersWithNames(group),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay miembros en este grupo'));
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
                  member['userName'],
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('Miembro del grupo'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (member['isAdmin'])
                      Chip(
                        label: Text('Admin'),
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
                  print('=== MIEMBRO CLICKEADO ===');
                  print('Datos completos del miembro: $member');
                  print('User ID: ${member['userId']}');
                  print('User Name: ${member['userName']}');
                  print('User Photo: ${member['userPhoto']}');
                  print('Is Admin: ${member['isAdmin']}');
                  print('========================');

                  // Verificar que el userId no esté vacío
                  final userId = member['userId'];
                  if (userId != null && userId.toString().isNotEmpty) {
                    print('🔄 Navegando al perfil: /user-profile/$userId');
                    context.push('/user-profile/$userId');
                  } else {
                    print('❌ Error: userId está vacío o es null');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ID de usuario no disponible'),
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
                  'No hay rodadas en este grupo',
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
                    label: Text('Crear Primera Rodada'),
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
                    label: Text('Crear Rodada'),
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
                          Text('Fecha: ${_formatDateTime(ride.dateTime)}'),
                          Text('Distancia: ${ride.kilometers} km'),
                          Text(
                            'Dificultad: ${_getDifficultyName(ride.difficulty)}',
                          ),
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
                  color: ColorTokens.neutral60,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay solicitudes pendientes',
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
                  request['userName'],
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('Solicitud pendiente'),
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
                      tooltip: 'Aprobar',
                    ),
                    IconButton(
                      onPressed: () => _rejectRequest(
                        group.id,
                        request['userId'],
                        request['userName'],
                        provider,
                      ),
                      icon: Icon(Icons.close, color: ColorTokens.error50),
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

  List<Widget> _buildAppBarActions(GroupModel group, GroupProvider provider) {
    final userStatus = provider.getUserStatus(group);
    List<Widget> actions = [];

    switch (userStatus) {
      case GroupMembershipStatus.admin:
        actions.add(
          IconButton(
            onPressed: () => context.go('/groups/${group.id}/edit'),
            icon: Icon(Icons.edit),
            tooltip: 'Editar Grupo',
          ),
        );
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
                    Text('Salir del grupo'),
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
            tooltip: 'Cancelar Solicitud',
          ),
        );
        break;
      case GroupMembershipStatus.notMember:
        actions.add(
          IconButton(
            onPressed: () => _requestJoinGroup(group.id, provider),
            icon: Icon(Icons.group_add),
            tooltip: 'Solicitar Unirse',
          ),
        );
        break;
    }

    return actions;
  }

  Widget _buildActionButtons(GroupModel group, GroupProvider provider) {
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
                      'Eres administrador',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.success50,
                      ),
                    ),
                    Text(
                      'Puedes editar el grupo desde el menú superior',
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
                      'Ya eres miembro',
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
            label: Text('Cancelar Solicitud'),
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
            label: Text('Solicitar Unirse'),
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
    final success = await provider.approveJoinRequest(groupId, userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$userName ha sido aceptado en el grupo'),
          backgroundColor: ColorTokens.success50,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aprobar la solicitud'),
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
    final success = await provider.rejectJoinRequest(groupId, userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud de $userName rechazada'),
          backgroundColor: ColorTokens.warning50,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al rechazar la solicitud'),
          backgroundColor: ColorTokens.error50,
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
          backgroundColor: ColorTokens.success50,
        ),
      );
    } else if (result['requiresProfile'] == true) {
      _showProfileRequiredDialog(
        result['error'] ?? 'Debes completar tu perfil',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al enviar solicitud'),
          backgroundColor: ColorTokens.error50,
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
          backgroundColor: ColorTokens.success50,
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
                context.push('/groups');
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
    return Container(color: ColorTokens.neutral100, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
