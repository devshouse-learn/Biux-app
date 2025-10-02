import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/colors.dart';
import '../../../../data/models/meeting_point.dart';
import '../../../../data/models/ride_model.dart';
import '../../../../providers/meeting_point_provider.dart';
import '../../../../providers/ride_provider.dart';

class RideDetailScreen extends StatefulWidget {
  final String rideId;

  const RideDetailScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  _RideDetailScreenState createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RideProvider>(context, listen: false)
          .selectRideById(widget.rideId);
      Provider.of<MeetingPointProvider>(context, listen: false)
          .startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<RideProvider, MeetingPointProvider>(
        builder: (context, rideProvider, meetingPointProvider, child) {
          if (rideProvider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.white,
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final ride = rideProvider.selectedRide;
          if (ride == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: AppColors.red),
                    SizedBox(height: 16),
                    Text('Rodada no encontrada'),
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

          final meetingPoint = meetingPointProvider.meetingPoints
              .where((mp) => mp.id == ride.meetingPointId)
              .firstOrNull;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: AppColors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      ride.name,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _getDifficultyColor(ride.difficulty),
                            AppColors.darkBlue,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.directions_bike,
                          size: 80,
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del grupo organizador
                  GroupInfoWidget(ride: ride),
                  SizedBox(height: 16),

                  // Información básica
                  BasicInfoWidget(ride: ride),
                  SizedBox(height: 24),

                  // Punto de encuentro
                  if (meetingPoint != null)
                    MeetingPointInfoWidget(meetingPoint: meetingPoint),
                  SizedBox(height: 24),

                  // Instrucciones
                  InfoSectionWidget(
                    title: 'Instrucciones',
                    content: ride.instructions,
                    icon: Icons.info_outline,
                  ),
                  SizedBox(height: 16),

                  // Recomendaciones
                  InfoSectionWidget(
                    title: 'Recomendaciones',
                    content: ride.recommendations,
                    icon: Icons.lightbulb_outline,
                  ),
                  SizedBox(height: 24),

                  // Participantes
                  ParticipantsSectionWidget(ride: ride),
                  SizedBox(height: 32),

                  // Botones de acción
                  ActionButtonsWidget(
                    ride: ride,
                    onJoinRide: () => _joinRide(ride.id, rideProvider),
                    onMaybeJoinRide: () =>
                        _maybeJoinRide(ride.id, rideProvider),
                    onLeaveRide: () => _leaveRide(ride.id, rideProvider),
                    onCancelRide: () =>
                        _showCancelDialog(ride.id, rideProvider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.green;
      case DifficultyLevel.medium:
        return AppColors.yellow;
      case DifficultyLevel.hard:
        return AppColors.red;
      case DifficultyLevel.expert:
        return AppColors.purple;
    }
  }

  void _joinRide(String rideId, RideProvider provider) async {
    final success = await provider.joinRide(rideId);
    if (success && mounted) {
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
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marcado como "tal vez voy"'),
          backgroundColor: AppColors.yellow,
        ),
      );
    }
  }

  void _leaveRide(String rideId, RideProvider provider) async {
    final success = await provider.leaveRide(rideId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Has salido de la rodada'),
          backgroundColor: AppColors.gray,
        ),
      );
    }
  }

  void _showCancelDialog(String rideId, RideProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancelar Rodada'),
        content: Text(
            '¿Estás seguro que deseas cancelar esta rodada? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await provider.cancelRide(rideId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rodada cancelada'),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child:
                Text('Sí, cancelar', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}

class GroupInfoWidget extends StatelessWidget {
  final RideModel ride;

  const GroupInfoWidget({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: provider.getGroupInfo(ride.groupId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.gray,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Cargando información del grupo...',
                        style: TextStyle(color: AppColors.gray),
                      ),
                    ],
                  ),
                ),
              );
            }

            final groupInfo = snapshot.data;
            if (groupInfo == null) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.gray,
                        child: Icon(Icons.group, color: AppColors.gray),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Grupo no encontrado',
                        style: TextStyle(color: AppColors.gray),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
                child: InkWell(
              onTap: () {
                context.go('/groups/${groupInfo['id']}');
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.darkBlue,
                      backgroundImage: groupInfo['imageUrl'] != null
                          ? NetworkImage(groupInfo['imageUrl'])
                          : null,
                      child: groupInfo['imageUrl'] == null
                          ? Icon(
                              Icons.group,
                              color: AppColors.white,
                              size: 28,
                            )
                          : null,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                size: 16,
                                color: AppColors.gray,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Organizada por',
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            groupInfo['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (groupInfo['memberCount'] > 0) ...[
                            SizedBox(height: 2),
                            Text(
                              '${groupInfo['memberCount']} miembros',
                              style: TextStyle(
                                color: AppColors.gray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.gray,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ));
          },
        );
      },
    );
  }
}

class BasicInfoWidget extends StatelessWidget {
  final RideModel ride;

  const BasicInfoWidget({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de la rodada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            InfoRowWidget(
              icon: Icons.calendar_today,
              label: 'Fecha y hora',
              value: _formatDateTime(ride.dateTime),
            ),
            SizedBox(height: 12),
            InfoRowWidget(
              icon: Icons.straighten,
              label: 'Distancia',
              value: '${ride.kilometers} km',
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.gray),
                SizedBox(width: 12),
                Text(
                  'Dificultad: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(ride.difficulty),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyName(ride.difficulty),
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            InfoRowWidget(
              icon: Icons.flag,
              label: 'Estado',
              value: _getStatusName(ride.status),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    final weekday = weekdays[dateTime.weekday - 1];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$weekday, $day de $month - $hour:$minute';
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.green;
      case DifficultyLevel.medium:
        return AppColors.yellow;
      case DifficultyLevel.hard:
        return AppColors.red;
      case DifficultyLevel.expert:
        return AppColors.purple;
    }
  }

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

  String _getStatusName(RideStatus status) {
    switch (status) {
      case RideStatus.upcoming:
        return 'Próxima';
      case RideStatus.ongoing:
        return 'En curso';
      case RideStatus.completed:
        return 'Completada';
      case RideStatus.cancelled:
        return 'Cancelada';
    }
  }
}

class MeetingPointInfoWidget extends StatelessWidget {
  final MeetingPoint meetingPoint;

  const MeetingPointInfoWidget({Key? key, required this.meetingPoint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Punto de encuentro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            InfoRowWidget(
              icon: Icons.location_on,
              label: meetingPoint.name,
              value: meetingPoint.description,
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/map'),
              icon: Icon(Icons.map),
              label: Text('Ver en mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoSectionWidget extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const InfoSectionWidget({
    Key? key,
    required this.title,
    required this.content,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gray),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantsSectionWidget extends StatelessWidget {
  final RideModel ride;

  const ParticipantsSectionWidget({Key? key, required this.ride})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ParticipantStatWidget(
                    label: 'Confirmados',
                    count: ride.participants.length,
                    color: AppColors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ParticipantStatWidget(
                    label: 'Tal vez',
                    count: ride.maybeParticipants.length,
                    color: AppColors.yellow,
                    icon: Icons.help,
                  ),
                ),
              ],
            ),
            if (ride.participants.isEmpty &&
                ride.maybeParticipants.isEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Aún no hay participantes registrados',
                style: TextStyle(
                  color: AppColors.gray,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ParticipantStatWidget extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const ParticipantStatWidget({
    Key? key,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtonsWidget extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onJoinRide;
  final VoidCallback onMaybeJoinRide;
  final VoidCallback onLeaveRide;
  final VoidCallback onCancelRide;

  const ActionButtonsWidget({
    Key? key,
    required this.ride,
    required this.onJoinRide,
    required this.onMaybeJoinRide,
    required this.onLeaveRide,
    required this.onCancelRide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, provider, child) {
        final currentUserId = provider.currentUserId;
        if (currentUserId == null) return SizedBox.shrink();

        final isParticipating = ride.participants.contains(currentUserId);
        final isMaybeParticipating =
            ride.maybeParticipants.contains(currentUserId);
        final isCreator = ride.createdBy == currentUserId;

        final isPastRide = ride.dateTime.isBefore(DateTime.now()) ||
            ride.status == RideStatus.completed ||
            ride.status == RideStatus.cancelled;

        return Column(
          children: [
            if (!isPastRide) ...[
              if (!isParticipating && !isMaybeParticipating) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onJoinRide,
                        icon: Icon(Icons.directions_bike),
                        label: Text('Voy a ir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMaybeJoinRide,
                        icon: Icon(Icons.help_outline),
                        label: Text('Tal vez voy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.yellow,
                          foregroundColor: AppColors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (isParticipating) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onLeaveRide,
                    icon: Icon(Icons.cancel),
                    label: Text('No voy a ir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ] else if (isMaybeParticipating) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onJoinRide,
                        icon: Icon(Icons.check),
                        label: Text('Confirmar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onLeaveRide,
                        icon: Icon(Icons.close),
                        label: Text('No voy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            if (isCreator && !isPastRide) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancelRide,
                  icon: Icon(Icons.cancel_outlined),
                  label: Text('Cancelar rodada'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: BorderSide(color: AppColors.red),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class InfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRowWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gray),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.gray,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
