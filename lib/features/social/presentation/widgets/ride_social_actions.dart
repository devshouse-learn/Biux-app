import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/comments_provider.dart';
import '../providers/attendees_provider.dart';
import '../../domain/repositories/comments_repository.dart';

/// Widget que muestra las acciones sociales para una rodada
/// (Asistentes y Comentarios)
class RideSocialActions extends StatelessWidget {
  final String rideId;
  final String rideOwnerId;

  const RideSocialActions({
    super.key,
    required this.rideId,
    required this.rideOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Asistentes
          _AttendeesSection(rideId: rideId, rideOwnerId: rideOwnerId),

          const Divider(height: 1),

          // Comentarios
          _CommentsSection(rideId: rideId, rideOwnerId: rideOwnerId),
        ],
      ),
    );
  }
}

class _AttendeesSection extends StatelessWidget {
  final String rideId;
  final String rideOwnerId;

  const _AttendeesSection({required this.rideId, required this.rideOwnerId});

  @override
  Widget build(BuildContext context) {
    final attendeesProvider = context.watch<AttendeesProvider>();

    return StreamBuilder<int>(
      stream: attendeesProvider.watchConfirmedCount(rideId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return ListTile(
          leading: const Icon(Icons.people, color: Color(0xFF16242D)),
          title: Text(
            count == 1
                ? '$count asistente confirmado'
                : '$count asistentes confirmados',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/rides/$rideId/attendees?ownerId=$rideOwnerId');
          },
        );
      },
    );
  }
}

class _CommentsSection extends StatelessWidget {
  final String rideId;
  final String rideOwnerId;

  const _CommentsSection({required this.rideId, required this.rideOwnerId});

  @override
  Widget build(BuildContext context) {
    final commentsProvider = context.watch<CommentsProvider>();

    return StreamBuilder<int>(
      stream: commentsProvider.watchCommentsCount(CommentableType.ride, rideId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return ListTile(
          leading: const Icon(Icons.comment, color: Color(0xFF16242D)),
          title: Text(
            count == 1 ? '$count comentario' : '$count comentarios',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/rides/$rideId/comments?ownerId=$rideOwnerId');
          },
        );
      },
    );
  }
}

/// Widget compacto que muestra un botón de unirse a la rodada
class RideJoinButton extends StatelessWidget {
  final String rideId;
  final String rideOwnerId;

  const RideJoinButton({
    super.key,
    required this.rideId,
    required this.rideOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    final attendeesProvider = context.watch<AttendeesProvider>();

    return StreamBuilder<bool>(
      stream: attendeesProvider.watchUserIsAttending(rideId),
      builder: (context, snapshot) {
        final isAttending = snapshot.data ?? false;

        if (isAttending) {
          return OutlinedButton.icon(
            onPressed: () {
              context.push('/rides/$rideId/attendees?ownerId=$rideOwnerId');
            },
            icon: const Icon(Icons.check_circle, color: Colors.green),
            label: const Text(
              'Ya estás asistiendo',
              style: TextStyle(color: Colors.green),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: attendeesProvider.isJoining
              ? null
              : () async {
                  await attendeesProvider.joinRide(
                    rideId: rideId,
                    rideOwnerId: rideOwnerId,
                  );

                  if (context.mounted && attendeesProvider.error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Te has unido a la rodada!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
          icon: attendeesProvider.isJoining
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(
            attendeesProvider.isJoining ? 'Uniéndose...' : 'Unirme a la rodada',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16242D),
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
