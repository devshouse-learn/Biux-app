import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/features/social/presentation/providers/comments_provider.dart';
import 'package:biux/features/social/domain/repositories/comments_repository.dart';

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
          // Comentarios
          _CommentsSection(rideId: rideId, rideOwnerId: rideOwnerId),
        ],
      ),
    );
  }
}

// NOTA: Esta sección se eliminó porque ahora usamos RideAttendeesListOptimized
// que ya muestra los participantes de forma optimizada sin consultas adicionales

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

// NOTA: RideJoinButton se eliminó porque ahora usamos RideAttendanceButton
// que es más completo y maneja confirmados/tal vez de forma unificada
