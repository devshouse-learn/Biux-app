import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/colors.dart';
import '../../../../data/models/ride_model.dart';
import '../../../../providers/ride_provider.dart';

class RoadsListScreen extends StatefulWidget {
  const RoadsListScreen({Key? key}) : super(key: key);

  @override
  State<RoadsListScreen> createState() => _RoadsListScreenState();
}

class _RoadsListScreenState extends State<RoadsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadAllRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Rodadas',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          if (rideProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.darkBlue,
              ),
            );
          }

          if (rideProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${rideProvider.error}',
                    style: const TextStyle(color: AppColors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => rideProvider.loadAllRides(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (rideProvider.rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bike_outlined,
                    size: 80,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay rodadas disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a un grupo para participar en rodadas',
                    style: TextStyle(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/groups'),
                    icon: const Icon(Icons.group),
                    label: const Text('Ver Grupos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await rideProvider.loadAllRides();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rideProvider.rides.length,
              itemBuilder: (context, index) {
                final ride = rideProvider.rides[index];
                return _RideCard(ride: ride);
              },
            ),
          );
        },
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final RideModel ride;

  const _RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navegar al detalle de la rodada
          context.go('/rides/${ride.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con ícono de dificultad
              CircleAvatar(
                radius: 30,
                backgroundColor: _getDifficultyColor(ride.difficulty),
                child: const Icon(
                  Icons.directions_bike,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la rodada
                    Text(
                      ride.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Fecha y hora
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(ride.dateTime),
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Distancia
                    Row(
                      children: [
                        const Icon(
                          Icons.straighten,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ride.kilometers.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Dificultad
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Dificultad: ${_getDifficultyText(ride.difficulty)}',
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Participantes
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ride.participants.length} participantes',
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                        ),
                        if (ride.maybeParticipants.isNotEmpty) ...[
                          Text(
                            ' • ${ride.maybeParticipants.length} tal vez',
                            style: const TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Flecha para indicar que es clickeable
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey600,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.green;
      case DifficultyLevel.medium:
        return AppColors.amber;
      case DifficultyLevel.hard:
        return AppColors.red;
      case DifficultyLevel.expert:
        return AppColors.purple;
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      if (dateTime.day == now.day) {
        return 'Hoy ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } else if (difference.inDays == 1) {
      return 'Mañana ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

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

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
