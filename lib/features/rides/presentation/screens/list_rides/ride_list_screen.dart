import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/config/colors.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';


class RideListScreen extends StatefulWidget {
  final String? groupId; // Ahora es opcional

  const RideListScreen({Key? key, this.groupId}) : super(key: key);

  @override
  _RideListScreenState createState() => _RideListScreenState();
}

class _RideListScreenState extends State<RideListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RideProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      if (widget.groupId != null) {
        // Cargar rodadas de un grupo específico
        provider.loadGroupRides(widget.groupId!);
      } else {
        // Cargar todas las rodadas de todos los grupos
        provider.loadAllRides();
      }

      // Cargar los grupos de admin del usuario siempre (tanto para grupo específico como general)
      // Esto evita recargas innecesarias al presionar el botón +
      groupProvider.loadAdminGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rodadas'),
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
      ),
      body: Consumer<RideProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final rides = provider.rides;

          if (rides.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (widget.groupId != null) {
                provider.loadGroupRides(widget.groupId!);
              } else {
                provider.loadAllRides();
              }
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                return _buildRideCard(ride, provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          // Si estamos viendo las rodadas de un grupo específico
          if (widget.groupId != null) {
            return FloatingActionButton(
              onPressed: () => context.push('/rides/create/${widget.groupId}'),
              backgroundColor: AppColors.blackPearl,
              child: Icon(Icons.add, color: AppColors.white),
              tooltip: 'Crear Rodada',
            );
          }

          // Si estamos en el listado general y el usuario es admin de algún grupo
          if (groupProvider.adminGroups.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => _showCreateRideDialog(context, groupProvider),
              backgroundColor: AppColors.blackPearl,
              child: Icon(Icons.add, color: AppColors.white),
              tooltip: 'Crear Rodada',
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_bike_outlined,
                size: 80,
                color: AppColors.grey600,
              ),
              SizedBox(height: 16),
              Text(
                widget.groupId != null
                    ? 'No hay rodadas en este grupo'
                    : 'No hay rodadas programadas',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.groupId != null
                    ? 'Sé el primero en organizar una rodada en este grupo'
                    : groupProvider.adminGroups.isNotEmpty
                        ? 'Organiza la primera rodada para tu grupo'
                        : 'Únete a un grupo para participar en rodadas',
                style: TextStyle(
                  color: AppColors.grey600,
                ),
              ),
              SizedBox(height: 24),
              // Botón en estado vacío
              if (widget.groupId != null)
                ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/rides/create/${widget.groupId}'),
                  icon: Icon(Icons.add),
                  label: Text('Crear Rodada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blackPearl,
                    foregroundColor: AppColors.white,
                  ),
                )
              else if (groupProvider.adminGroups.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () =>
                      _showCreateRideDialog(context, groupProvider),
                  icon: Icon(Icons.add),
                  label: Text('Crear Rodada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blackPearl,
                    foregroundColor: AppColors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => context.go('/groups'),
                  icon: Icon(Icons.group),
                  label: Text('Ver Grupos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blackPearl,
                    foregroundColor: AppColors.white,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRideCard(RideModel ride, RideProvider provider) {
    final participationStatus = provider.getParticipationStatus(ride);
    final isCreator = provider.isCreator(ride);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado y dificultad
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(ride.status).withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(ride.difficulty),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ride.difficultyDisplayName,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${ride.kilometers} km',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isCreator)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Organizador',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del grupo organizador
                if (widget.groupId ==
                    null) // Solo mostrar si no estamos en un grupo específico
                  FutureBuilder<Map<String, dynamic>?>(
                    future: provider.getGroupInfo(ride.groupId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data != null) {
                        final groupInfo = snapshot.data!;
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: groupInfo['logoUrl'] != null &&
                                        groupInfo['logoUrl']
                                            .toString()
                                            .isNotEmpty
                                    ? NetworkImage(groupInfo['logoUrl'])
                                    : null,
                                backgroundColor: AppColors.blackPearl,
                                child: groupInfo['logoUrl'] == null ||
                                        groupInfo['logoUrl'].toString().isEmpty
                                    ? Icon(Icons.group,
                                        size: 16, color: AppColors.white)
                                    : null,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Organizado por ${groupInfo['name']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.blackPearl,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),

                // Fecha y hora
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: AppColors.grey600),
                    SizedBox(width: 8),
                    Text(
                      _formatDateTime(ride.dateTime),
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Participantes
                Row(
                  children: [
                    Icon(Icons.group, size: 16, color: AppColors.grey600),
                    SizedBox(width: 8),
                    Text(
                      '${ride.participantCount} confirmados',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                    if (ride.maybeParticipantCount > 0) ...[
                      Text(' • ', style: TextStyle(color: AppColors.grey600)),
                      Text(
                        '${ride.maybeParticipantCount} tal vez',
                        style: TextStyle(
                          color: AppColors.vividOrange,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12),

                // Estado de participación del usuario
                _buildParticipationChip(participationStatus),
                SizedBox(height: 16),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.push('/rides/${ride.id}'),
                      icon: Icon(Icons.info_outline),
                      label: Text('Ver Detalles'),
                    ),
                    _buildActionButton(ride, participationStatus, provider),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationChip(RideParticipationStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case RideParticipationStatus.participating:
        color = AppColors.green;
        text = 'Voy a ir';
        icon = Icons.check_circle;
        break;
      case RideParticipationStatus.maybeParticipating:
        color = AppColors.vividOrange;
        text = 'Tal vez voy';
        icon = Icons.help;
        break;
      case RideParticipationStatus.notParticipating:
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
      RideModel ride, RideParticipationStatus status, RideProvider provider) {
    // No mostrar botones si la rodada ya pasó o está cancelada
    if (ride.status == RideStatus.completed ||
        ride.status == RideStatus.cancelled ||
        ride.dateTime.isBefore(DateTime.now())) {
      return SizedBox.shrink();
    }

    switch (status) {
      case RideParticipationStatus.participating:
        return ElevatedButton.icon(
          onPressed: () => _leaveRide(ride.id, provider),
          icon: Icon(Icons.cancel, size: 16),
          label: Text('No voy'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
            minimumSize: Size(100, 32),
          ),
        );

      case RideParticipationStatus.maybeParticipating:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => _joinRide(ride.id, provider),
              icon: Icon(Icons.check, size: 16),
              label: Text('Confirmar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
                minimumSize: Size(80, 32),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _leaveRide(ride.id, provider),
              icon: Icon(Icons.close, size: 16),
              label: Text('No voy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                minimumSize: Size(70, 32),
              ),
            ),
          ],
        );

      case RideParticipationStatus.notParticipating:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => _joinRide(ride.id, provider),
              icon: Icon(Icons.directions_bike, size: 16),
              label: Text('Voy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
                minimumSize: Size(80, 32),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _maybeJoinRide(ride.id, provider),
              icon: Icon(Icons.help_outline, size: 16),
              label: Text('Tal vez'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vividOrange,
                foregroundColor: AppColors.white,
                minimumSize: Size(80, 32),
              ),
            ),
          ],
        );
    }
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.upcoming:
        return AppColors.blue;
      case RideStatus.ongoing:
        return AppColors.green;
      case RideStatus.completed:
        return AppColors.grey600;
      case RideStatus.cancelled:
        return AppColors.red;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.green;
      case DifficultyLevel.medium:
        return AppColors.vividOrange;
      case DifficultyLevel.hard:
        return AppColors.red;
      case DifficultyLevel.expert:
        return AppColors.purple;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month - $hour:$minute';
  }

  void _joinRide(String rideId, RideProvider provider) async {
    final success = await provider.joinRide(rideId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Genial! Te has unido a la rodada'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  void _maybeJoinRide(String rideId, RideProvider provider) async {
    final success = await provider.maybeJoinRide(rideId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marcado como "tal vez voy"'),
          backgroundColor: AppColors.vividOrange,
        ),
      );
    }
  }

  void _leaveRide(String rideId, RideProvider provider) async {
    final success = await provider.leaveRide(rideId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Has salido de la rodada'),
          backgroundColor: AppColors.grey600,
        ),
      );
    }
  }

  void _showCreateRideDialog(
      BuildContext context, GroupProvider groupProvider) {
    // Si solo es admin de un grupo, ir directamente a crear rodada
    if (groupProvider.adminGroups.length == 1) {
      final group = groupProvider.adminGroups.first;
      context.push('/rides/create/${group.id}');
      return;
    }

    // Si es admin de múltiples grupos, mostrar selector
    showDialog(
      context: context,
      builder: (context) {
        String? selectedGroupId;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Crear nueva rodada'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selecciona el grupo con el que deseas crear la rodada:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // Lista de grupos administrados por el usuario
                  Column(
                    children: groupProvider.adminGroups.map((group) {
                      return RadioListTile<String>(
                        title: Text(group.name),
                        value: group.id,
                        groupValue: selectedGroupId,
                        onChanged: (value) {
                          setState(() {
                            selectedGroupId = value;
                          });
                        },
                        activeColor: AppColors.blackPearl,
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedGroupId != null) {
                      // Navegar a la pantalla de creación de rodada con el ID del grupo seleccionado
                      context.push('/rides/create/$selectedGroupId');
                      Navigator.of(context).pop();
                    } else {
                      // Mostrar un mensaje de error si no se ha seleccionado ningún grupo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor, selecciona un grupo'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Continuar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blackPearl,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
