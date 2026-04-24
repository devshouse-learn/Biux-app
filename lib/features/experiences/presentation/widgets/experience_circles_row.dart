import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Widget para mostrar experiencias en formato circular tipo Instagram Stories
/// Diferencia entre experiencias de rodadas (arriba) y experiencias normales
class ExperienceCirclesRow extends StatelessWidget {
  final List<ExperienceEntity> rideExperiences;
  final List<ExperienceEntity> userExperiences;
  final Function(ExperienceEntity) onExperienceTap;
  final VoidCallback? onCreateTap;

  const ExperienceCirclesRow({
    super.key,
    required this.rideExperiences,
    required this.userExperiences,
    required this.onExperienceTap,
    this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Botón para crear nueva experiencia
          if (onCreateTap != null) _buildCreateButton(l),

          const SizedBox(width: 8),

          // Experiencias de rodadas (aparecen primero)
          ...rideExperiences.map(
            (experience) => _buildExperienceCircle(experience, isRide: true),
          ),

          // Espaciador si hay ambos tipos
          if (rideExperiences.isNotEmpty && userExperiences.isNotEmpty)
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              color: ColorTokens.neutral30,
            ),

          // Experiencias de usuarios normales
          ...userExperiences.map(
            (experience) => _buildExperienceCircle(experience, isRide: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(LocaleNotifier l) {
    return GestureDetector(
      onTap: onCreateTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorTokens.primary50, width: 2),
            ),
            child: const Icon(
              Icons.add,
              color: ColorTokens.primary50,
              size: 30,
            ),
          ),
          SizedBox(height: 4),
          Text(
            l.t('your_story'),
            style: const TextStyle(fontSize: 11, color: ColorTokens.neutral80),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCircle(
    ExperienceEntity experience, {
    required bool isRide,
  }) {
    final hasVideo = experience.hasVideo;
    final firstMedia = experience.media.isNotEmpty
        ? experience.media.first
        : null;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => onExperienceTap(experience),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Círculo principal con imagen/video
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isRide
                          ? ColorTokens.secondary50
                          : ColorTokens.primary50,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: firstMedia != null
                        ? OptimizedNetworkImage(
                            imageUrl: firstMedia.mediaType == MediaType.video
                                ? (firstMedia.thumbnailUrl ?? firstMedia.url)
                                : firstMedia.url,
                            fit: BoxFit.cover,
                            width: 54,
                            height: 54,
                            imageType: 'experience_thumb',
                            placeholder: Container(
                              color: ColorTokens.neutral20,
                              child: Icon(
                                isRide ? Icons.directions_bike : Icons.person,
                                color: ColorTokens.neutral60,
                                size: 24,
                              ),
                            ),
                          )
                        : Container(
                            color: ColorTokens.neutral20,
                            child: Icon(
                              isRide ? Icons.directions_bike : Icons.person,
                              color: ColorTokens.neutral60,
                              size: 24,
                            ),
                          ),
                  ),
                ),

                // Indicador de video
                if (hasVideo)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorTokens.primary50,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),

                // Indicador de rodada
                if (isRide)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorTokens.secondary50,
                      ),
                      child: const Icon(
                        Icons.directions_bike,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // Nombre del usuario (truncado)
            SizedBox(
              width: 64,
              child: Text(
                experience.user.userName.isNotEmpty
                    ? experience.user.userName
                    : experience.user.fullName,
                style: const TextStyle(
                  fontSize: 11,
                  color: ColorTokens.neutral80,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget más simple para mostrar una sola fila de experiencias
class SimpleExperienceCirclesRow extends StatelessWidget {
  final List<ExperienceEntity> experiences;
  final Function(ExperienceEntity) onExperienceTap;
  final VoidCallback? onCreateTap;

  const SimpleExperienceCirclesRow({
    super.key,
    required this.experiences,
    required this.onExperienceTap,
    this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return ExperienceCirclesRow(
      rideExperiences: experiences.where((e) => e.isRideExperience).toList(),
      userExperiences: experiences.where((e) => !e.isRideExperience).toList(),
      onExperienceTap: onExperienceTap,
      onCreateTap: onCreateTap,
    );
  }
}
