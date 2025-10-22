import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/attendee_entity.dart';
import '../providers/attendees_provider.dart';
import 'user_avatar.dart';
import 'package:go_router/go_router.dart';

/// Widget de lista de asistentes a una rodada
class AttendeesList extends StatelessWidget {
  final String rideId;
  final bool showJoinButton;
  final String? rideOwnerId;

  const AttendeesList({
    super.key,
    required this.rideId,
    this.showJoinButton = false,
    this.rideOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendeesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contador de asistentes confirmados
        StreamBuilder<int>(
          stream: provider.watchConfirmedCount(rideId),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$count ${count == 1 ? 'asistente confirmado' : 'asistentes confirmados'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showJoinButton && rideOwnerId != null)
                    _buildJoinButton(context, provider),
                ],
              ),
            );
          },
        ),
        // Lista de asistentes
        StreamBuilder<List<AttendeeEntity>>(
          stream: provider.watchAttendees(rideId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final attendees = snapshot.data ?? [];

            if (attendees.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'Aún no hay asistentes',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendees.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return AttendeeCard(attendee: attendees[index], rideId: rideId);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildJoinButton(BuildContext context, AttendeesProvider provider) {
    return StreamBuilder<bool>(
      stream: provider.watchUserIsAttending(rideId),
      builder: (context, snapshot) {
        final isAttending = snapshot.data ?? false;

        if (isAttending) {
          return StreamBuilder<AttendeeStatus?>(
            stream: provider.watchUserStatus(rideId),
            builder: (context, statusSnapshot) {
              final status = statusSnapshot.data;

              return Row(
                children: [
                  Text(
                    status == AttendeeStatus.confirmed
                        ? 'Confirmado ✓'
                        : status == AttendeeStatus.maybe
                        ? 'Tal vez ?'
                        : 'Cancelado',
                    style: TextStyle(
                      color: status == AttendeeStatus.confirmed
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showStatusMenu(context, provider),
                  ),
                ],
              );
            },
          );
        }

        return ElevatedButton.icon(
          onPressed: provider.isJoining
              ? null
              : () => _showJoinDialog(context, provider),
          icon: provider.isJoining
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline),
          label: const Text('Unirme'),
        );
      },
    );
  }

  void _showJoinDialog(BuildContext context, AttendeesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unirse a la rodada'),
        content: const Text('¿Confirmas tu asistencia a esta rodada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.joinRide(
                rideId: rideId,
                rideOwnerId: rideOwnerId!,
                status: AttendeeStatus.confirmed,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showStatusMenu(BuildContext context, AttendeesProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Confirmar asistencia'),
            onTap: () async {
              await provider.updateStatus(
                rideId: rideId,
                status: AttendeeStatus.confirmed,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.orange),
            title: const Text('Marcar como "Tal vez"'),
            onTap: () async {
              await provider.updateStatus(
                rideId: rideId,
                status: AttendeeStatus.maybe,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Salir de la rodada'),
            onTap: () async {
              await provider.leaveRide(rideId);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Widget de tarjeta de asistente individual
class AttendeeCard extends StatelessWidget {
  final AttendeeEntity attendee;
  final String rideId;

  const AttendeeCard({super.key, required this.attendee, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        userName: attendee.userName,
        photoUrl: attendee.userPhoto,
        radius: 20,
      ),
      title: Row(
        children: [
          Text(attendee.fullName ?? attendee.userName),
          const SizedBox(width: 8),
          if (attendee.status == AttendeeStatus.confirmed)
            const Icon(Icons.check_circle, color: Colors.green, size: 16)
          else if (attendee.status == AttendeeStatus.maybe)
            const Icon(Icons.help_outline, color: Colors.orange, size: 16),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (attendee.bikeType != null) Text('Bici: ${attendee.bikeType}'),
          if (attendee.level != null)
            Text('Nivel: ${attendee.level!.displayName}'),
        ],
      ),
      onTap: () {
        // Navegar al perfil del usuario
        context.push('/users/${attendee.userId}');
      },
    );
  }
}
