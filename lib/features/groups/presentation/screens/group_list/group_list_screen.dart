import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';

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
        // Añadir botón de volver explícito (flecha)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Fallback: ir al menú principal si no hay historial
              context.go('/main');
            }
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Grupos'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
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
              backgroundColor: ColorTokens.primary30,
              child: const Icon(Icons.add, color: ColorTokens.neutral100),
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
          Icon(Icons.group_outlined, size: 80, color: ColorTokens.neutral60),
          const SizedBox(height: 16),
          Text(
            'No hay grupos disponibles',
            style: TextStyle(fontSize: 18, color: ColorTokens.neutral60),
          ),
          const SizedBox(height: 8),
          Text(
            provider.canCreateGroup
                ? 'Sé el primero en crear un grupo'
                : 'Explora grupos para unirte',
            style: TextStyle(color: ColorTokens.neutral60),
          ),
          const SizedBox(height: 24),
          if (provider.canCreateGroup)
            ElevatedButton.icon(
              onPressed: () => context.go('/groups/create'),
              icon: const Icon(Icons.add),
              label: const Text('Crear Grupo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/groups/${group.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de portada
            if (group.coverUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: OptimizedNetworkImage(
                  imageUrl: group.coverUrl!,
                  height: 150,
                  width: double.infinity,
                  imageType: 'cover',
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    height: 150,
                    color: ColorTokens.neutral20,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: ColorTokens.neutral60,
                    ),
                  ),
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
                          color: ColorTokens.neutral20,
                        ),
                        child: group.logoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: OptimizedNetworkImage(
                                  imageUrl: group.logoUrl!,
                                  width: 50,
                                  height: 50,
                                  imageType: 'avatar',
                                  fit: BoxFit.cover,
                                  errorWidget: const Icon(
                                    Icons.group,
                                    color: ColorTokens.neutral60,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.group,
                                color: ColorTokens.neutral60,
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
                                color: ColorTokens.neutral60,
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

                  // Ciudad del grupo
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: ColorTokens.neutral60,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '📍 ${_getCityName(group.cityId)}',
                          style: TextStyle(
                            color: ColorTokens.neutral60,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Estados de rodadas
                  Text(
                    'Estados de Rodadas:',
                    style: TextStyle(
                      color: ColorTokens.neutral60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildRideStatusBadge('Próxima', ColorTokens.warning50),
                      const SizedBox(width: 8),
                      _buildRideStatusBadge('Cancelada', ColorTokens.error50),
                      const SizedBox(width: 8),
                      _buildRideStatusBadge('Realizada', ColorTokens.success40),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Creador del grupo como líder
                  FutureBuilder<Map<String, dynamic>>(
                    future: provider.getUserAdminInfo(group.adminId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorTokens.primary30.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '👤 Cargando líder...',
                            style: TextStyle(
                              color: ColorTokens.neutral60,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        final admin = snapshot.data!;
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorTokens.primary30.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ColorTokens.primary30.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: ColorTokens.neutral20,
                                backgroundImage:
                                    admin['photo'] != null &&
                                        admin['photo'].isNotEmpty
                                    ? NetworkImage(admin['photo'])
                                    : null,
                                child:
                                    admin['photo'] == null ||
                                        admin['photo'].isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 16,
                                        color: ColorTokens.neutral60,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '👑 ${admin['fullName'] ?? 'Líder'}',
                                      style: TextStyle(
                                        color: ColorTokens.neutral100,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '@${admin['userName'] ?? 'usuario'}',
                                      style: TextStyle(
                                        color: ColorTokens.neutral60,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorTokens.primary30.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '👤 Líder no disponible',
                          style: TextStyle(
                            color: ColorTokens.neutral60,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Descripción
                  Text(
                    group.description,
                    style: TextStyle(
                      color: ColorTokens.neutral60,
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

  Widget _buildRideStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getCityName(String cityId) {
    // Mapeo básico de IDs de ciudad a nombres
    // En producción, esto debería venir del provider
    const cityMap = {
      'bogota': 'Bogotá',
      'medellin': 'Medellín',
      'cali': 'Cali',
      'barranquilla': 'Barranquilla',
      'cartagena': 'Cartagena',
      'santa-marta': 'Santa Marta',
      'manizales': 'Manizales',
      'pereira': 'Pereira',
      'armenia': 'Armenia',
      'bucaramanga': 'Bucaramanga',
      'tunja': 'Tunja',
      'villavicencio': 'Villavicencio',
      'popayan': 'Popayán',
      'cucuta': 'Cúcuta',
      'neiva': 'Neiva',
    };
    return cityMap[cityId.toLowerCase()] ?? cityId;
  }

  Widget _buildStatusChip(GroupMembershipStatus status) {
    String text;
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (status) {
      case GroupMembershipStatus.admin:
        text = 'Admin';
        backgroundColor = ColorTokens.success40;
        textColor = ColorTokens.neutral100;
        borderColor = ColorTokens.success40;
        break;
      case GroupMembershipStatus.member:
        text = 'Miembro';
        backgroundColor = ColorTokens.primary30;
        textColor = ColorTokens.neutral100;
        borderColor = ColorTokens.primary30;
        break;
      case GroupMembershipStatus.pending:
        text = 'Pendiente';
        backgroundColor = ColorTokens.warning50;
        textColor = ColorTokens.neutral100;
        borderColor = ColorTokens.warning50;
        break;
      case GroupMembershipStatus.notMember:
        text = 'Unirse';
        backgroundColor = ColorTokens.neutral60;
        textColor = ColorTokens.neutral100;
        borderColor = ColorTokens.neutral60;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    GroupModel group,
    GroupMembershipStatus status,
    GroupProvider provider,
  ) {
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
            backgroundColor: ColorTokens.error50,
            foregroundColor: ColorTokens.neutral100,
            minimumSize: const Size(100, 32),
          ),
        );

      case GroupMembershipStatus.notMember:
        return ElevatedButton.icon(
          onPressed: () => _requestJoinGroup(group.id, provider),
          icon: const Icon(Icons.group_add, size: 16),
          label: const Text('Unirse'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorTokens.primary30,
            foregroundColor: ColorTokens.neutral100,
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
          backgroundColor: ColorTokens.success50,
        ),
      );
    } else {
      // Verificar si requiere completar el perfil
      if (result['requiresProfile'] == true) {
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
  }

  void _showProfileRequiredDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_outline, color: ColorTokens.error50),
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
                style: TextStyle(fontSize: 14, color: ColorTokens.neutral60),
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
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
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
          backgroundColor: ColorTokens.success50,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al cancelar solicitud'),
          backgroundColor: ColorTokens.error50,
        ),
      );
    }
  }
}
