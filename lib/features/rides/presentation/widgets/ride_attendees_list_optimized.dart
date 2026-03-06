import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Widget OPTIMIZADO que usa la metadata de participantes almacenada en la rodada
/// en lugar de consultar Firestore por cada usuario.
///
/// Beneficios:
/// - ❌ NO hace consultas a Firestore por participante
/// - ✅ Usa datos pre-cargados de la metadata
/// - ✅ Carga MUCHO más rápido
/// - ✅ Consume menos recursos
class RideAttendeesListOptimized extends StatelessWidget {
  final String rideId;
  final List<ParticipantMetadata> confirmedMetadata;
  final List<ParticipantMetadata> maybeMetadata;

  const RideAttendeesListOptimized({
    Key? key,
    required this.rideId,
    required this.confirmedMetadata,
    required this.maybeMetadata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final hasConfirmed = confirmedMetadata.isNotEmpty;
    final hasMaybe = maybeMetadata.isNotEmpty;

    if (!hasConfirmed && !hasMaybe) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          l.t('no_participants_yet'),
          style: TextStyle(
            color: ColorTokens.neutral60,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Mostrar solo los primeros 5 de cada categoría
    final confirmedToShow = confirmedMetadata.take(5).toList();
    final maybeToShow = maybeMetadata.take(5).toList();
    final totalParticipants = confirmedMetadata.length + maybeMetadata.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Confirmados
        if (hasConfirmed) ...[
          _SectionHeader(
            title: '✅ ${l.t('confirmed_count')} (${confirmedMetadata.length})',
            color: ColorTokens.success50,
          ),
          SizedBox(height: 8),
          ...confirmedToShow.map(
            (metadata) => _AttendeeCard(metadata: metadata, isConfirmed: true),
          ),
          if (hasMaybe) SizedBox(height: 16),
        ],

        // Tal vez
        if (hasMaybe) ...[
          _SectionHeader(
            title: '🤔 ${l.t('maybe_count')} (${maybeMetadata.length})',
            color: ColorTokens.warning50,
          ),
          SizedBox(height: 8),
          ...maybeToShow.map(
            (metadata) => _AttendeeCard(metadata: metadata, isConfirmed: false),
          ),
        ],

        // Botón "Ver todos" si hay más de 5 participantes
        if (totalParticipants > 5) ...[
          SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                context.push('/rides/$rideId/attendees');
              },
              icon: Icon(Icons.people, color: ColorTokens.primary50),
              label: Text(
                '${l.t('view_all_participants')} ($totalParticipants)',
                style: TextStyle(
                  color: ColorTokens.primary50,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
    );
  }
}

class _AttendeeCard extends StatelessWidget {
  final ParticipantMetadata metadata;
  final bool isConfirmed;

  const _AttendeeCard({required this.metadata, required this.isConfirmed});

  @override
  Widget build(BuildContext context) {
    // Debug para ver qué datos tiene el metadata
    debugPrint(
      '📋 AttendeeCard - userId: ${metadata.userId}, userName: "${metadata.userName}", photoUrl: "${metadata.photoUrl}"',
    );

    return InkWell(
      onTap: () {
        // Navegar al perfil del usuario usando la ruta correcta
        context.push('/user-profile/${metadata.userId}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Avatar con foto o inicial
            _buildAvatar(),
            SizedBox(width: 12),

            // Nombre del usuario (con fallback si está vacío)
            Expanded(
              child: Text(
                metadata.userName.isNotEmpty
                    ? metadata.userName
                    : l.t('user_no_name'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Indicador de estado
            Icon(
              isConfirmed ? Icons.check_circle : Icons.help,
              color: isConfirmed
                  ? ColorTokens.success50
                  : ColorTokens.warning50,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Debug: Imprimir datos para ver qué está llegando
    debugPrint(
      '🔍 Avatar Debug - userName: "${metadata.userName}", photoUrl: "${metadata.photoUrl}"',
    );

    if (metadata.photoUrl != null && metadata.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(metadata.photoUrl!),
        backgroundColor: ColorTokens.neutral20,
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('❌ Error cargando imagen: $exception');
        },
      );
    }

    // Avatar con inicial del nombre
    final initial = metadata.userName.isNotEmpty
        ? metadata.userName[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 20,
      backgroundColor: ColorTokens.primary50,
      child: Text(
        initial,
        style: TextStyle(
          color: ColorTokens.neutral100,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
