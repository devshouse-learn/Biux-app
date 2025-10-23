import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
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
      // Esto evita recargas innecesarias al presionar el Botón +
      groupProvider.loadAdminGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rodadas'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
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
              backgroundColor: ColorTokens.primary30,
              child: Icon(Icons.add, color: ColorTokens.neutral100),
              tooltip: 'Crear Rodada',
            );
          }

          // Si estamos en el listado general y el usuario es admin de alg�n grupo
          if (groupProvider.adminGroups.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => _showCreateRideDialog(context, groupProvider),
              backgroundColor: ColorTokens.primary30,
              child: Icon(Icons.add, color: ColorTokens.neutral100),
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
                color: ColorTokens.neutral60,
              ),
              SizedBox(height: 16),
              Text(
                widget.groupId != null
                    ? 'No hay rodadas en este grupo'
                    : 'No hay rodadas programadas',
                style: TextStyle(fontSize: 18, color: ColorTokens.neutral60),
              ),
              SizedBox(height: 8),
              Text(
                widget.groupId != null
                    ? 'Sé el primero en organizar una rodada en este grupo'
                    : groupProvider.adminGroups.isNotEmpty
                    ? 'Organiza la primera rodada para tu grupo'
                    : 'Únete a un grupo para participar en rodadas',
                style: TextStyle(color: ColorTokens.neutral60),
              ),
              SizedBox(height: 24),
              // Botón en estado vac�o
              if (widget.groupId != null)
                ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/rides/create/${widget.groupId}'),
                  icon: Icon(Icons.add),
                  label: Text('Crear Rodada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: ColorTokens.neutral100,
                  ),
                )
              else if (groupProvider.adminGroups.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () =>
                      _showCreateRideDialog(context, groupProvider),
                  icon: Icon(Icons.add),
                  label: Text('Crear Rodada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: ColorTokens.neutral100,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => context.go('/groups'),
                  icon: Icon(Icons.group),
                  label: Text('Ver Grupos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: ColorTokens.neutral100,
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
    final isPastRide = ride.dateTime.isBefore(DateTime.now());

    return Opacity(
      opacity: isPastRide ? 0.6 : 1.0,
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            InkWell(
              onTap: () => context.push('/rides/${ride.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con estado y dificultad
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPastRide
                          ? Colors.grey.withValues(alpha: 0.2)
                          : _getStatusColor(ride.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ride.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        decoration: isPastRide
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: ColorTokens.neutral60,
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(
                                        ride.difficulty,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      ride.difficultyDisplayName,
                                      style: TextStyle(
                                        color: ColorTokens.neutral100,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${ride.kilometers} km',
                                    style: TextStyle(
                                      color: ColorTokens.neutral60,
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorTokens.warning50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Organizador',
                              style: TextStyle(
                                color: ColorTokens.neutral100,
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
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData &&
                                  snapshot.data != null) {
                                final groupInfo = snapshot.data!;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      groupInfo['logoUrl'] != null &&
                                              groupInfo['logoUrl']
                                                  .toString()
                                                  .isNotEmpty
                                          ? ClipOval(
                                              child: OptimizedNetworkImage(
                                                imageUrl: groupInfo['logoUrl'],
                                                width: 32,
                                                height: 32,
                                                imageType:
                                                    'avatar', // Cache de larga duración para logos
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 16,
                                              backgroundColor:
                                                  ColorTokens.primary30,
                                              child: Icon(
                                                Icons.group,
                                                size: 16,
                                                color: ColorTokens.neutral100,
                                              ),
                                            ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Organizado por ${groupInfo['name']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
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
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: ColorTokens.neutral60,
                            ),
                            SizedBox(width: 8),
                            Text(
                              _formatDateTime(ride.dateTime),
                              style: TextStyle(
                                color: ColorTokens.neutral60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Participantes
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              size: 16,
                              color: ColorTokens.neutral60,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${ride.participantCount} confirmados',
                              style: TextStyle(
                                color: ColorTokens.neutral60,
                                fontSize: 14,
                              ),
                            ),
                            if (ride.maybeParticipantCount > 0) ...[
                              Text(
                                ' ',
                                style: TextStyle(color: ColorTokens.neutral60),
                              ),
                              Text(
                                '${ride.maybeParticipantCount} tal vez',
                                style: TextStyle(
                                  color: ColorTokens.warning60,
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildActionButton(
                            ride,
                            participationStatus,
                            provider,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Badge de "Finalizada" para rodadas pasadas
            if (isPastRide)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Finalizada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationChip(RideParticipationStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case RideParticipationStatus.participating:
        color = ColorTokens.success40;
        text = 'Voy a ir';
        icon = Icons.check_circle;
        break;
      case RideParticipationStatus.maybeParticipating:
        color = ColorTokens.warning50;
        text = 'Tal vez voy';
        icon = Icons.help;
        break;
      case RideParticipationStatus.notParticipating:
        return SizedBox.shrink();
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(text, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  Widget _buildActionButton(
    RideModel ride,
    RideParticipationStatus status,
    RideProvider provider,
  ) {
    // No mostrar botones si la rodada ya pas� o est� cancelada
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
            backgroundColor: ColorTokens.error50,
            foregroundColor: ColorTokens.neutral100,
            minimumSize: Size(75, 32),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                backgroundColor: ColorTokens.success40,
                foregroundColor: ColorTokens.neutral100,
                minimumSize: Size(75, 32),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _leaveRide(ride.id, provider),
              icon: Icon(Icons.close, size: 16),
              label: Text('No'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.error50,
                foregroundColor: ColorTokens.neutral100,
                minimumSize: Size(75, 32),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                backgroundColor: ColorTokens.success40,
                foregroundColor: ColorTokens.neutral100,
                minimumSize: Size(75, 32),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _maybeJoinRide(ride.id, provider),
              icon: Icon(Icons.help_outline, size: 16),
              label: Text('Tal vez'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.warning50,
                foregroundColor: ColorTokens.neutral100,
                minimumSize: Size(75, 32),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        );
    }
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.upcoming:
        return ColorTokens.primary50;
      case RideStatus.ongoing:
        return ColorTokens.success40;
      case RideStatus.completed:
        return ColorTokens.neutral60;
      case RideStatus.cancelled:
        return ColorTokens.error50;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return ColorTokens.success50;
      case DifficultyLevel.medium:
        return ColorTokens.warning50;
      case DifficultyLevel.hard:
        return ColorTokens.error50;
      case DifficultyLevel.expert:
        return ColorTokens.secondary60;
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
      'Dic',
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
          backgroundColor: ColorTokens.success40,
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
          backgroundColor: ColorTokens.warning60,
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
          backgroundColor: ColorTokens.neutral60,
        ),
      );
    }
  }

  void _showCreateRideDialog(
    BuildContext context,
    GroupProvider groupProvider,
  ) {
    // Si solo es admin de un grupo, ir directamente a crear rodada
    if (groupProvider.adminGroups.length == 1) {
      final group = groupProvider.adminGroups.first;
      context.push('/rides/create/${group.id}');
      return;
    }

    // Si es admin de m�ltiples grupos, mostrar selector
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
                        activeColor: ColorTokens.primary30,
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
                      // Navegar a la pantalla de creaci�n de rodada con el ID del grupo seleccionado
                      context.push('/rides/create/$selectedGroupId');
                      Navigator.of(context).pop();
                    } else {
                      // Mostrar un mensaje de error si no se ha seleccionado ning�n grupo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor, selecciona un grupo'),
                          backgroundColor: ColorTokens.error50,
                        ),
                      );
                    }
                  },
                  child: Text('Continuar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: ColorTokens.neutral100,
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
