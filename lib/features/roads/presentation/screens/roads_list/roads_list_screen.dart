import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('rides'),
          style: const TextStyle(color: ColorTokens.neutral100),
        ),
        backgroundColor: ColorTokens.primary30,
        iconTheme: const IconThemeData(color: ColorTokens.neutral100),
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          if (rideProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorTokens.primary30),
            );
          }

          if (rideProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l.t('error')}: ${rideProvider.error}',
                    style: const TextStyle(color: ColorTokens.error50),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => rideProvider.loadAllRides(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                    ),
                    child: Text(
                      l.t('retry'),
                      style: const TextStyle(color: ColorTokens.neutral100),
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
                    color: ColorTokens.neutral60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.t('no_rides_available'),
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorTokens.neutral60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.t('join_group_for_rides'),
                    style: TextStyle(color: ColorTokens.neutral60),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/groups'),
                    icon: const Icon(Icons.group),
                    label: Text(l.t('view_groups')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                      foregroundColor: ColorTokens.neutral100,
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  color: ColorTokens.neutral100,
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
                        color: ColorTokens.primary30,
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
                          color: ColorTokens.neutral60,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(ride.dateTime, l),
                          style: const TextStyle(
                            color: ColorTokens.neutral60,
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
                          color: ColorTokens.neutral60,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ride.kilometers.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: ColorTokens.neutral60,
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
                          color: ColorTokens.neutral60,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${l.t('difficulty')}: ${_getDifficultyText(ride.difficulty, l)}',
                          style: const TextStyle(
                            color: ColorTokens.neutral60,
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
                          color: ColorTokens.neutral60,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ride.participants.length} ${l.t('n_participants')}',
                          style: const TextStyle(
                            color: ColorTokens.neutral60,
                            fontSize: 14,
                          ),
                        ),
                        if (ride.maybeParticipants.isNotEmpty) ...[
                          Text(
                            '  ${ride.maybeParticipants.length} ${l.t('n_maybe')}',
                            style: const TextStyle(
                              color: ColorTokens.neutral60,
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
                color: ColorTokens.neutral60,
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
        return ColorTokens.success40;
      case DifficultyLevel.medium:
        return ColorTokens.warning50;
      case DifficultyLevel.hard:
        return ColorTokens.error50;
      case DifficultyLevel.expert:
        return ColorTokens.primary60;
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty, LocaleNotifier l) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return l.t('difficulty_easy');
      case DifficultyLevel.medium:
        return l.t('difficulty_medium');
      case DifficultyLevel.hard:
        return l.t('difficulty_hard');
      case DifficultyLevel.expert:
        return l.t('difficulty_expert');
    }
  }

  String _formatDateTime(DateTime dateTime, LocaleNotifier l) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (difference.inDays == 0 && dateTime.day == now.day) {
      return '${l.t('today')} $time';
    } else if (difference.inDays == 1) {
      return '${l.t('tomorrow')} $time';
    }

    final monthKeys = [
      'month_jan',
      'month_feb',
      'month_mar',
      'month_apr',
      'month_may',
      'month_jun',
      'month_jul',
      'month_aug',
      'month_sep',
      'month_oct',
      'month_nov',
      'month_dec',
    ];

    return '${dateTime.day} ${l.t(monthKeys[dateTime.month - 1])} $time';
  }
}
