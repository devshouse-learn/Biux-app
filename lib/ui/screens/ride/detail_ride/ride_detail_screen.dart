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
                backgroundColor: AppColors.blackPearl,
                foregroundColor: AppColors.white,
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final ride = rideProvider.selectedRide;
          if (ride == null) {
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
                  backgroundColor: AppColors.blackPearl,
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
                            AppColors.blackPearl,
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
                  // Información básica
                  _buildBasicInfo(ride),
                  SizedBox(height: 24),

                  // Punto de encuentro
                  if (meetingPoint != null)
                    _buildMeetingPointInfo(meetingPoint),
                  SizedBox(height: 24),

                  // Instrucciones
                  _buildInfoSection(
                    'Instrucciones',
                    ride.instructions,
                    Icons.info_outline,
                  ),
                  SizedBox(height: 16),

                  // Recomendaciones
                  _buildInfoSection(
                    'Recomendaciones',
                    ride.recommendations,
                    Icons.lightbulb_outline,
                  ),
                  SizedBox(height: 24),

                  // Participantes
                  _buildParticipantsSection(ride, rideProvider),
                  SizedBox(height: 32),

                  // Botones de acción
                  _buildActionButtons(ride, rideProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfo(RideModel ride) {
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

            // Fecha y hora
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha y hora',
              _formatDateTime(ride.dateTime),
            ),
            SizedBox(height: 12),

            // Distancia
            _buildInfoRow(
              Icons.straighten,
              'Distancia',
              '${ride.kilometers} km',
            ),
            SizedBox(height: 12),

            // Dificultad
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.grey600),
                SizedBox(width: 12),
                Text(
                  'Dificultad: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey600,
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

            // Estado
            _buildInfoRow(
              Icons.flag,
              'Estado',
              _getStatusName(ride.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingPointInfo(MeetingPoint meetingPoint) {
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
            _buildInfoRow(
              Icons.location_on,
              meetingPoint.name,
              meetingPoint.description,
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/map'),
              icon: Icon(Icons.map),
              label: Text('Ver en mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strongCyan,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.grey600),
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

  Widget _buildParticipantsSection(RideModel ride, RideProvider provider) {
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

            // Estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildParticipantStat(
                    'Confirmados',
                    ride.participants.length,
                    AppColors.green,
                    Icons.check_circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildParticipantStat(
                    'Tal vez',
                    ride.maybeParticipants.length,
                    AppColors.vividOrange,
                    Icons.help,
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
                  color: AppColors.grey600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantStat(
      String label, int count, Color color, IconData icon) {
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

  Widget _buildActionButtons(RideModel ride, RideProvider provider) {
    final currentUserId = provider.currentUserId;
    if (currentUserId == null) return SizedBox.shrink();

    final isParticipating = ride.participants.contains(currentUserId);
    final isMaybeParticipating = ride.maybeParticipants.contains(currentUserId);
    final isCreator = ride.createdBy == currentUserId;

    // No mostrar botones si la rodada ya pasó
    final isPastRide = ride.dateTime.isBefore(DateTime.now()) ||
        ride.status == RideStatus.completed ||
        ride.status == RideStatus.cancelled;

    return Column(
      children: [
        // Botones de participación
        if (!isPastRide) ...[
          if (!isParticipating && !isMaybeParticipating) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _joinRide(ride.id, provider),
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
                    onPressed: () => _maybeJoinRide(ride.id, provider),
                    icon: Icon(Icons.help_outline),
                    label: Text('Tal vez voy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vividOrange,
                      foregroundColor: AppColors.white,
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
                onPressed: () => _leaveRide(ride.id, provider),
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
                    onPressed: () => _joinRide(ride.id, provider),
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
                    onPressed: () => _leaveRide(ride.id, provider),
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

        // Botones de administración (solo para el creador)
        if (isCreator && !isPastRide) ...[
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(ride.id, provider),
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
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey600),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.grey600,
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

  void _showCancelDialog(String rideId, RideProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Rodada'),
        content: Text(
            '¿Estás seguro que deseas cancelar esta rodada? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.cancelRide(rideId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rodada cancelada'),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}
