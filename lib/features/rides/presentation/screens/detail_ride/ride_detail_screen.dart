import 'package:biux/features/maps/data/models/meeting_point.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/core/services/deep_link_service.dart';
import 'package:biux/features/social/presentation/widgets/ride_social_actions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:biux/core/design_system/color_tokens.dart';

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
      Provider.of<RideProvider>(
        context,
        listen: false,
      ).selectRideById(widget.rideId);
      Provider.of<MeetingPointProvider>(
        context,
        listen: false,
      ).startListening();
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
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final ride = rideProvider.selectedRide;
          if (ride == null) {
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
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: ColorTokens.neutral100,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      ride.name,
                      style: TextStyle(
                        color: ColorTokens.neutral100,
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
                            ColorTokens.primary30,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.directions_bike,
                          size: 80,
                          color: ColorTokens.neutral100.withValues(alpha: 0.3),
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
                  SizedBox(height: 16),

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

                  // Acciones sociales (Asistentes y Comentarios)
                  RideSocialActions(
                    rideId: ride.id,
                    rideOwnerId: ride.createdBy,
                  ),
                  SizedBox(height: 16),

                  // Botón para unirse a la rodada
                  RideJoinButton(rideId: ride.id, rideOwnerId: ride.createdBy),
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
        return ColorTokens.success50;
      case DifficultyLevel.medium:
        return ColorTokens.warning50;
      case DifficultyLevel.hard:
        return ColorTokens.error50;
      case DifficultyLevel.expert:
        return ColorTokens.primary60;
    }
  }

  void _joinRide(String rideId, RideProvider provider) async {
    final success = await provider.joinRide(rideId);
    if (success && mounted) {
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
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marcado como "tal vez voy"'),
          backgroundColor: ColorTokens.warning50,
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
          backgroundColor: ColorTokens.neutral60,
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
          'Estás seguro que deseas cancelar esta rodada? Esta acción no se puede deshacer.',
        ),
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
                    backgroundColor: ColorTokens.error50,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
            ),
            child: Text(
              'Sí, cancelar',
              style: TextStyle(color: ColorTokens.neutral100),
            ),
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
                        backgroundColor: ColorTokens.neutral60,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorTokens.primary30,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Cargando Información del grupo...',
                        style: TextStyle(color: ColorTokens.neutral60),
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
                        backgroundColor: ColorTokens.neutral60,
                        child: Icon(Icons.group, color: ColorTokens.neutral60),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Grupo no encontrado',
                        style: TextStyle(color: ColorTokens.neutral60),
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
                      groupInfo['imageUrl'] != null
                          ? ClipOval(
                              child: OptimizedNetworkImage(
                                imageUrl: groupInfo['imageUrl'],
                                width: 50,
                                height: 50,
                                imageType:
                                    'avatar', // Cache de larga duración para logos
                                fit: BoxFit.cover,
                              ),
                            )
                          : CircleAvatar(
                              radius: 25,
                              backgroundColor: ColorTokens.primary30,
                              child: Icon(
                                Icons.group,
                                color: ColorTokens.neutral100,
                                size: 28,
                              ),
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
                                  color: ColorTokens.neutral60,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Organizada por',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              groupInfo['name'],
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (groupInfo['memberCount'] > 0) ...[
                              SizedBox(height: 2),
                              Text(
                                '${groupInfo['memberCount']} miembros',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: ColorTokens.neutral60,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                Icon(Icons.trending_up, color: ColorTokens.neutral60),
                SizedBox(width: 12),
                Text(
                  'Dificultad: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: ColorTokens.neutral60,
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
                      color: ColorTokens.neutral100,
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
    final weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
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
      'Diciembre',
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
        return ColorTokens.success50;
      case DifficultyLevel.medium:
        return ColorTokens.warning50;
      case DifficultyLevel.hard:
        return ColorTokens.error50;
      case DifficultyLevel.expert:
        return ColorTokens.primary60;
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
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
                Icon(icon, color: ColorTokens.neutral60),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(content, style: TextStyle(fontSize: 16)),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ParticipantStatWidget(
                    label: 'Confirmados',
                    count: ride.participants.length,
                    color: ColorTokens.success40,
                    icon: Icons.check_circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ParticipantStatWidget(
                    label: 'Tal vez',
                    count: ride.maybeParticipants.length,
                    color: ColorTokens.warning50,
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
                  color: ColorTokens.neutral60,
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
          Text(label, style: TextStyle(color: color, fontSize: 12)),
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
        final isMaybeParticipating = ride.maybeParticipants.contains(
          currentUserId,
        );
        final isCreator = ride.createdBy == currentUserId;

        final isPastRide =
            ride.dateTime.isBefore(DateTime.now()) ||
            ride.status == RideStatus.completed ||
            ride.status == RideStatus.cancelled;

        return Column(
          children: [
            // Botón de compartir (siempre visible)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _shareRide(context, ride),
                icon: Icon(Icons.share),
                label: Text('Compartir rodada'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorTokens.primary50,
                  side: BorderSide(color: ColorTokens.primary50, width: 2),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(height: 16),

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
                          backgroundColor: ColorTokens.success40,
                          foregroundColor: ColorTokens.neutral100,
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
                          backgroundColor: ColorTokens.warning50,
                          foregroundColor: ColorTokens.neutral100,
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
                      backgroundColor: ColorTokens.error50,
                      foregroundColor: ColorTokens.neutral100,
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
                          backgroundColor: ColorTokens.success40,
                          foregroundColor: ColorTokens.neutral100,
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
                          backgroundColor: ColorTokens.error50,
                          foregroundColor: ColorTokens.neutral100,
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
                    foregroundColor: ColorTokens.error50,
                    side: BorderSide(color: ColorTokens.error50),
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

  Future<void> _shareRide(BuildContext context, RideModel ride) async {
    try {
      // Obtener información del grupo
      final provider = Provider.of<RideProvider>(context, listen: false);
      final groupInfo = await provider.getGroupInfo(ride.groupId);
      final groupName = groupInfo?['name'] ?? 'un grupo de ciclistas';

      // Generar texto de compartir con deep link
      final shareText = DeepLinkService.generateShareText(
        rideName: ride.name,
        rideId: ride.id,
        groupName: groupName,
      );

      // Si hay imagen, compartirla con el texto
      if (ride.imageUrl != null && ride.imageUrl!.isNotEmpty) {
        try {
          // Descargar la imagen temporalmente
          final response = await http.get(Uri.parse(ride.imageUrl!));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final file = File('${tempDir.path}/ride_${ride.id}.jpg');
            await file.writeAsBytes(response.bodyBytes);

            // Compartir con imagen
            await Share.shareXFiles(
              [XFile(file.path)],
              text: shareText,
              subject: '🚴 Rodada: ${ride.name}',
            );

            // Limpiar archivo temporal después de compartir
            await file.delete();
          } else {
            // Si falla la descarga, compartir solo texto
            await Share.share(shareText, subject: '🚴 Rodada: ${ride.name}');
          }
        } catch (e) {
          // Si hay error con la imagen, compartir solo texto
          print('Error compartiendo imagen: $e');
          await Share.share(shareText, subject: '🚴 Rodada: ${ride.name}');
        }
      } else {
        // Sin imagen, compartir solo texto
        await Share.share(shareText, subject: '🚴 Rodada: ${ride.name}');
      }
    } catch (e) {
      print('Error compartiendo rodada: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: ColorTokens.error50,
        ),
      );
    }
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
        Icon(icon, color: ColorTokens.neutral60),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: ColorTokens.neutral60,
          ),
        ),
        Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
      ],
    );
  }
}
