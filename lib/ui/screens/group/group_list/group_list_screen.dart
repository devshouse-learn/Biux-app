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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCitiesAndGroups();
    });
  }

  void _initializeCitiesAndGroups() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Cargar todos los grupos sin filtrar por ciudad
    groupProvider.loadAllGroups();
    // Cargar también los grupos de admin del usuario para verificar restricción
    groupProvider.loadAdminGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Lista de grupos (sin selector de ciudades)
          Expanded(
            child: Consumer<GroupProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groups = provider.allGroups;

                if (groups.isEmpty) {
                  return _buildEmptyState(provider);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    provider.loadAllGroups();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _buildGroupCard(group, provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<GroupProvider>(
        builder: (context, provider, child) {
          // Solo mostrar el FAB si el usuario no es admin de ningún grupo
          if (provider.canCreateGroup) {
            return FloatingActionButton(
              onPressed: () => context.go('/groups/create'),
              backgroundColor: AppColors.blackPearl,
              child: const Icon(Icons.add, color: AppColors.white),
              tooltip: 'Crear Grupo',
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(GroupProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: AppColors.grey600,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay grupos disponibles',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.canCreateGroup
                ? 'Sé el primero en crear un grupo'
                : 'Explora grupos para unirte',
            style: TextStyle(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          if (provider.canCreateGroup)
            ElevatedButton.icon(
              onPressed: () => context.go('/groups/create'),
              icon: const Icon(Icons.add),
              label: const Text('Crear Grupo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blackPearl,
                foregroundColor: AppColors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(GroupModel group, GroupProvider provider) {
    final status = provider.getUserStatus(group);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/groups/${group.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de portada
            if (group.coverUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  group.coverUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: AppColors.grey200,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: AppColors.grey600,
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Logo del grupo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.grey200,
                        ),
                        child: group.logoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  group.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.group,
                                      color: AppColors.grey600,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.group,
                                color: AppColors.grey600,
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Información del grupo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${group.memberIds.length} miembros',
                              style: TextStyle(
                                color: AppColors.grey600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Estado del usuario en el grupo
                      _buildStatusChip(status),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Descripción
                  Text(
                    group.description,
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Botón de acción si no es miembro
                  if (status == GroupMembershipStatus.notMember ||
                      status == GroupMembershipStatus.pending)
                    _buildActionButton(group, status, provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(GroupMembershipStatus status) {
    String text;
    Color color;

    switch (status) {
      case GroupMembershipStatus.admin:
        text = 'Admin';
        color = AppColors.green;
        break;
      case GroupMembershipStatus.member:
        text = 'Miembro';
        color = AppColors.blackPearl;
        break;
      case GroupMembershipStatus.pending:
        text = 'Pendiente';
        color = AppColors.yellow;
        break;
      case GroupMembershipStatus.notMember:
        text = 'Unirse';
        color = AppColors.grey600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
      GroupModel group, GroupMembershipStatus status, GroupProvider provider) {
    switch (status) {
      case GroupMembershipStatus.admin:
      case GroupMembershipStatus.member:
        return const SizedBox.shrink(); // Sin botón, ya son miembros

      case GroupMembershipStatus.pending:
        return ElevatedButton.icon(
          onPressed: () => _cancelJoinRequest(group.id, provider),
          icon: const Icon(Icons.cancel, size: 16),
          label: const Text('Cancelar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
            minimumSize: const Size(100, 32),
          ),
        );

      case GroupMembershipStatus.notMember:
        return ElevatedButton.icon(
          onPressed: () => _requestJoinGroup(group.id, provider),
          icon: const Icon(Icons.group_add, size: 16),
          label: const Text('Unirse'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blackPearl,
            foregroundColor: AppColors.white,
            minimumSize: const Size(100, 32),
          ),
        );
    }
  }

  void _requestJoinGroup(String groupId, GroupProvider provider) async {
    // El nuevo método devuelve un Map con información detallada
    final result = await provider.requestJoinGroup(groupId);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada correctamente'),
          backgroundColor: AppColors.green,
        ),
      );
    } else {
      // Verificar si requiere completar el perfil
      if (result['requiresProfile'] == true) {
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
  }

  void _showProfileRequiredDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.red),
              SizedBox(width: 8),
              Text('Completar Perfil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 12),
              const Text(
                'Para unirte a grupos, los administradores necesitan saber quién eres.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Redirigir al perfil para completar el nombre
                context.go('/profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blackPearl,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Ir al Perfil'),
            ),
          ],
        );
      },
    );
  }

  void _cancelJoinRequest(String groupId, GroupProvider provider) async {
    final success = await provider.cancelJoinRequest(groupId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
}
