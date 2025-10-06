import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/widgets/story_viewer_screen.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';

/// Widget para mostrar stories generales en la pantalla principal (tipo Instagram)
/// Se muestra en la parte superior con scroll horizontal de círculos
class ExperiencesStoriesWidget extends StatefulWidget {
  const ExperiencesStoriesWidget({super.key});

  @override
  State<ExperiencesStoriesWidget> createState() =>
      _ExperiencesStoriesWidgetState();
}

class _ExperiencesStoriesWidgetState extends State<ExperiencesStoriesWidget> {
  @override
  void initState() {
    super.initState();
    // No cargar datos aquí - la pantalla padre ya lo hace
    // Esto evita duplicar llamadas y el loop de recarga
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExperienceProvider>(
      builder: (context, provider, child) {
        // Filtrar solo las experiencias que queremos mostrar como stories
        final stories = _getStoriesFromExperiences(provider);

        return Container(
          height: 120, // Aumentar altura para evitar overflow
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la sección
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_stories,
                      color: ColorTokens.primary30,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorTokens.neutral90,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Lista horizontal de stories
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:
                            stories.length + 1, // +1 para el botón de agregar
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Primer elemento: botón "Agregar Story"
                            return _AddStoryButton();
                          }

                          // Elementos restantes: stories existentes
                          final story = stories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _StoryCircle(
                              story: story,
                              onTap: () => _openStoryViewer(
                                context,
                                story,
                                stories,
                                index - 1,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<ExperienceEntity> _getStoriesFromExperiences(
    ExperienceProvider provider,
  ) {
    // Combinar todas las experiencias disponibles
    final allExperiences = <ExperienceEntity>[];

    // Agregar experiencias del usuario
    allExperiences.addAll(provider.userExperiences);

    // Agregar experiencias generales (si las hay)
    allExperiences.addAll(provider.experiences);

    // Filtrar solo las que son realmente "stories" (contenido visual y corto)
    final storyExperiences = allExperiences.where(
      (exp) =>
          // Stories: tienen media y descripción corta (o sin descripción)
          exp.media.isNotEmpty && exp.description.length <= 50,
    );

    // Eliminar duplicados y ordenar por fecha
    final uniqueExperiences = <String, ExperienceEntity>{};
    for (final experience in storyExperiences) {
      uniqueExperiences[experience.id] = experience;
    }

    final stories = uniqueExperiences.values.toList();
    stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Limitar a las últimas 20 stories para performance
    return stories.take(20).toList();
  }

  void _openStoryViewer(
    BuildContext context,
    ExperienceEntity story,
    List<ExperienceEntity> allStories,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StoryViewerScreen(stories: allStories, initialIndex: initialIndex),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        fullscreenDialog: true,
      ),
    );
  }
}

/// Botón para agregar una nueva story general
class _AddStoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateStoryOptions(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [ColorTokens.primary30, ColorTokens.secondary50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            'Tu story',
            style: TextStyle(
              fontSize: 11,
              color: ColorTokens.neutral60,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  void _showCreateStoryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _StoryOptionsBottomSheet(),
    );
  }
}

/// Bottom sheet con opciones para crear stories (video o texto)
class _StoryOptionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle del bottom sheet
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: ColorTokens.neutral30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Crear Story',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorTokens.neutral90,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comparte tu experiencia en bicicleta',
            style: TextStyle(fontSize: 14, color: ColorTokens.neutral60),
          ),
          const SizedBox(height: 24),

          // Opciones de story
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Video Story
              _StoryOptionButton(
                icon: Icons.videocam,
                title: 'Video Story',
                subtitle: 'Graba hasta 30s',
                color: ColorTokens.primary30,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToCreateVideoStory(context);
                },
              ),

              // Foto Story
              _StoryOptionButton(
                icon: Icons.photo_camera,
                title: 'Foto Story',
                subtitle: 'Comparte momentos',
                color: ColorTokens.success40,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToCreatePhotoStory(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToCreateVideoStory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateExperienceScreen(
          experienceType: ExperienceType.general,
        ),
      ),
    );
  }

  void _navigateToCreatePhotoStory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateExperienceScreen(
          experienceType: ExperienceType.general,
        ),
      ),
    );
  }
}

/// Botón individual para cada opción de story
class _StoryOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _StoryOptionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorTokens.neutral90,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: ColorTokens.neutral60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Círculo individual de story con borde colorido (tipo Instagram)
class _StoryCircle extends StatelessWidget {
  final ExperienceEntity story;
  final VoidCallback onTap;

  const _StoryCircle({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: story.type == ExperienceType.ride
                        ? [
                            ColorTokens.primary30,
                            ColorTokens.primary60,
                            ColorTokens.warning60,
                          ]
                        : [
                            ColorTokens.success40,
                            ColorTokens.secondary50,
                            ColorTokens.primary30,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: story.user.photo.isNotEmpty
                          ? null
                          : ColorTokens.primary30.withValues(alpha: 0.1),
                      image: story.user.photo.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(story.user.photo),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: story.user.photo.isEmpty
                        ? Center(
                            child: Text(
                              story.user.userName.isNotEmpty
                                  ? story.user.userName[0].toUpperCase()
                                  : story.user.fullName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorTokens.primary30,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              // Indicador de tipo de experiencia
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: story.type == ExperienceType.ride
                        ? ColorTokens.warning60
                        : ColorTokens.success40,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    story.type == ExperienceType.ride
                        ? Icons.directions_bike
                        : story.hasVideo
                        ? Icons.videocam
                        : Icons.photo_camera,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(
              story.user.userName.isNotEmpty
                  ? story.user.userName
                  : story.user.fullName.split(' ').first,
              style: TextStyle(
                fontSize: 10,
                color: ColorTokens.neutral80,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
