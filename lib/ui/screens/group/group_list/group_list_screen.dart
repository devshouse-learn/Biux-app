import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/colors.dart';
import '../../../../data/models/group_model.dart';
import '../../../../providers/group_provider.dart';


class GroupListScreen extends StatefulWidget {
  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadAllGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : Text('Grupos'),
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<GroupProvider>().clearSearchResults();
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final groups = _isSearching && _searchController.text.isNotEmpty
              ? provider.searchResults
              : provider.allGroups;

          if (groups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              provider.loadAllGroups();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return _buildGroupCard(group, provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/groups/create'),
        backgroundColor: AppColors.blackPearl,
        child: Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: 'Buscar grupos...',
        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.7)),
        border: InputBorder.none,
      ),
      onChanged: (query) {
        context.read<GroupProvider>().searchGroups(query);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: AppColors.grey600,
          ),
          SizedBox(height: 16),
          Text(
            _isSearching
                ? 'No se encontraron grupos'
                : 'No hay grupos disponibles',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Intenta con otros términos de búsqueda'
                : 'Sé el primero en crear un grupo',
            style: TextStyle(
              color: AppColors.grey600,
            ),
          ),
          if (!_isSearching) ...[
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/groups/create'),
              icon: Icon(Icons.add),
              label: Text('Crear Grupo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blackPearl,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupCard(GroupModel group, GroupProvider provider) {
    final userStatus = provider.getUserStatus(group);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de portada
          if (group.coverUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                group.coverUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppColors.grey200,
                    child: Icon(Icons.image, color: AppColors.grey600),
                  );
                },
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con logo y nombre
                Row(
                  children: [
                    // Logo del grupo
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.blackPearl,
                      backgroundImage: group.logoUrl != null
                          ? NetworkImage(group.logoUrl!)
                          : null,
                      child: group.logoUrl == null
                          ? Icon(Icons.group, color: AppColors.white)
                          : null,
                    ),
                    SizedBox(width: 12),

                    // Información del grupo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${group.memberCount} miembros',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Estado del usuario
                    _buildUserStatusChip(userStatus),
                  ],
                ),

                SizedBox(height: 12),

                // Descripción
                Text(
                  group.description,
                  style: TextStyle(
                    color: AppColors.grey200,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 16),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/groups/${group.id}'),
                      icon: Icon(Icons.info_outline),
                      label: Text('Ver Detalles'),
                    ),
                    _buildActionButton(group, userStatus, provider),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        text = 'Admin';
        icon = Icons.admin_panel_settings;
        break;
      case GroupMembershipStatus.member:
        color = AppColors.blue;
        text = 'Miembro';
        icon = Icons.check_circle;
        break;
      case GroupMembershipStatus.pending:
        color = AppColors.vividOrange;
        text = 'Pendiente';
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

  Widget _buildActionButton(
      GroupModel group, GroupMembershipStatus status, GroupProvider provider) {
    switch (status) {
      case GroupMembershipStatus.admin:
      case GroupMembershipStatus.member:
        return SizedBox.shrink(); // Sin botón, ya son miembros

      case GroupMembershipStatus.pending:
        return ElevatedButton.icon(
          onPressed: () => _cancelJoinRequest(group.id, provider),
          icon: Icon(Icons.cancel, size: 16),
          label: Text('Cancelar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.vividOrange,
            foregroundColor: AppColors.white,
            minimumSize: Size(100, 32),
          ),
        );

      case GroupMembershipStatus.notMember:
        return ElevatedButton.icon(
          onPressed: () => _requestJoinGroup(group.id, provider),
          icon: Icon(Icons.group_add, size: 16),
          label: Text('Unirse'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blackPearl,
            foregroundColor: AppColors.white,
            minimumSize: Size(100, 32),
          ),
        );
    }
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al cancelar solicitud'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
