import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/entities/user_story_group_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/story_groups_provider.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';

/// Widget para mostrar stories agrupadas por usuario (tipo Instagram)
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
    // Cargar y agrupar historias al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndGroupStories();
    });
  }

  Future<void> _loadAndGroupStories() async {
    final storyGroupsProvider = context.read<StoryGroupsProvider>();
    final experienceProvider = context.read<ExperienceProvider>();

    // Obtener experiencias del feed personalizado
    final allExperiences = experienceProvider.experiences;

    // Filtrar solo las que son formato story (visuales y cortas)
    final storyExperiences = allExperiences
        .where((exp) => exp.isStoryFormat)
        .toList();

    // Agrupar por usuario y calcular vistas localmente
    await storyGroupsProvider.groupExistingStories(storyExperiences);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryGroupsProvider>(
      builder: (context, storyProvider, child) {
        final storyGroups = storyProvider.storyGroups;

        return Container(
          height: 120,
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
                    if (storyProvider.hasUnseenStories) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorTokens.error50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${storyProvider.totalUnseenCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Lista horizontal de grupos de stories
              Expanded(
                child: storyProvider.isLoading
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
                        itemCount: storyGroups.length + 1, // +1 para agregar
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Primer elemento: botón "Agregar Story"
                            return _AddStoryButton();
                          }

                          // Elementos restantes: grupos de stories por usuario
                          final group = storyGroups[index - 1];
                          return _StoryGroupCircle(storyGroup: group);
                        },
                      ),
              ),
            ],
          ),
        );
      },
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

/// Widget que muestra un círculo de historias agrupadas por usuario
class _StoryGroupCircle extends StatelessWidget {
  final UserStoryGroupEntity storyGroup;

  const _StoryGroupCircle({required this.storyGroup});

  @override
  Widget build(BuildContext context) {
    final hasUnseenStories = storyGroup.hasUnseenStories;

    return GestureDetector(
      onTap: () {
        // TODO: Navegar al visor de historias completo
        // context.push(AppRoutes.storyViewer, extra: storyGroup);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Círculo con foto de perfil
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnseenStories
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFF58529), // Instagram orange
                          Color(0xFFDD2A7B), // Instagram pink
                          Color(0xFF8134AF), // Instagram purple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: hasUnseenStories
                    ? null
                    : Border.all(color: Colors.grey.shade400, width: 2),
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: storyGroup.userProfilePhoto.isNotEmpty
                      ? Image.network(
                          storyGroup.userProfilePhoto,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Nombre de usuario
            SizedBox(
              width: 70,
              child: Text(
                storyGroup.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade300,
      child: const Icon(Icons.person, size: 35, color: Colors.grey),
    );
  }
}
