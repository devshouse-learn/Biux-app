import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/entities/user_story_group_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/providers/story_groups_provider.dart';
import 'package:biux/features/experiences/presentation/providers/experience_creator_classic_provider.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';
import 'package:biux/features/experiences/presentation/screens/story_viewer_screen.dart';

/// Widget para mostrar stories agrupadas por usuario (tipo Instagram)
/// Se muestra en la parte superior con scroll horizontal de círculos
class ExperiencesStoriesWidget extends StatefulWidget {
  const ExperiencesStoriesWidget({super.key});

  @override
  State<ExperiencesStoriesWidget> createState() =>
      _ExperiencesStoriesWidgetState();
}

class _ExperiencesStoriesWidgetState extends State<ExperiencesStoriesWidget> {
  ExperienceProvider? _experienceProvider;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios del ExperienceProvider para re-agrupar stories
    // cuando el feed se cargue o actualice
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _experienceProvider = context.read<ExperienceProvider>();
      _experienceProvider!.addListener(_onExperiencesChanged);
      // Intentar agrupar si ya hay datos
      _loadAndGroupStories();
    });
  }

  @override
  void dispose() {
    // Remover listener de forma segura usando la referencia guardada
    _experienceProvider?.removeListener(_onExperiencesChanged);
    _experienceProvider = null;
    super.dispose();
  }

  void _onExperiencesChanged() {
    // Solo re-agrupar si el widget sigue montado
    if (!mounted) return;
    _loadAndGroupStories();
  }

  Future<void> _loadAndGroupStories() async {
    if (!mounted) return;
    final storyGroupsProvider = context.read<StoryGroupsProvider>();
    final experienceProvider = context.read<ExperienceProvider>();

    // Obtener experiencias del feed personalizado
    final allExperiences = experienceProvider.experiences;

    // No agrupar si no hay datos aún (evitar resetear)
    if (allExperiences.isEmpty) return;

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
          height: 92,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
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
                  itemCount: storyGroups.length + 1, // +1 para Tu story
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Primer elemento: botón "Tu Story"
                      return _AddStoryButton();
                    }

                    // Elementos restantes: grupos de stories por usuario
                    final group = storyGroups[index - 1];
                    return _StoryGroupCircle(storyGroup: group);
                  },
                ),
        );
      },
    );
  }
}

/// Botón para agregar una nueva story general
class _AddStoryButton extends StatefulWidget {
  @override
  State<_AddStoryButton> createState() => _AddStoryButtonState();
}

class _AddStoryButtonState extends State<_AddStoryButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ExperienceCreatorProvider>(
      builder: (context, creatorProvider, child) {
        final isUploading = creatorProvider.isUploading;
        final uploadProgress = creatorProvider.uploadProgress;

        return GestureDetector(
          onTap: isUploading ? null : () => _navigateToCreateStory(context),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Contenedor con indicador de progreso
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo de progreso tipo Instagram
                    if (isUploading)
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CustomPaint(
                          painter: _CircularProgressPainter(
                            progress: uploadProgress,
                            strokeWidth: 3,
                          ),
                          child: Container(),
                        ),
                      ),
                    // Círculo principal con icono
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            ColorTokens.primary30.withValues(
                              alpha: isUploading ? 0.6 : 1.0,
                            ),
                            ColorTokens.secondary50.withValues(
                              alpha: isUploading ? 0.6 : 1.0,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: isUploading
                          ? Center(
                              child: Text(
                                '${(uploadProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Tu story',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color,
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
      },
    );
  }

  void _navigateToCreateStory(BuildContext context) {
    // Navegar directamente a la pantalla de crear historia
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const CreateExperienceScreen(
              experienceType: ExperienceType.general,
              isStoryMode: true,
            ),
          ),
        )
        .then((result) {
          // Si se creó exitosamente, recarga el feed
          if (result == true && mounted) {
            // Recargar historias del feed
            context.read<StoryGroupsProvider>().groupExistingStories(
              context.read<ExperienceProvider>().experiences,
            );
          }
        });
  }
}

/// Custom painter para dibujar el indicador de progreso circular
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _CircularProgressPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Dibujar el círculo de progreso con color blanco
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Dibujar arco desde la parte superior (-90 grados)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Comienza en la parte superior
      2 * 3.14159 * progress, // Cubrimiento según el progreso
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget que muestra un círculo de historias agrupadas por usuario
class _StoryGroupCircle extends StatelessWidget {
  final UserStoryGroupEntity storyGroup;

  const _StoryGroupCircle({required this.storyGroup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnseenStories = storyGroup.hasUnseenStories;

    return GestureDetector(
      onTap: () {
        // Navegar al visor de historias de este usuario
        _openStoryViewer(context);
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
                    : Border.all(color: theme.dividerColor, width: 2),
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
                          errorBuilder: (ctx, error, stackTrace) {
                            return _buildDefaultAvatar(ctx);
                          },
                        )
                      : _buildDefaultAvatar(context),
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 35,
        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
      ),
    );
  }

  void _openStoryViewer(BuildContext context) {
    final storyGroupsProvider = context.read<StoryGroupsProvider>();

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => StoryViewerScreen(stories: storyGroup.stories),
          ),
        )
        .then((_) async {
          await storyGroupsProvider.markUserStoriesAsViewed(storyGroup.userId);
        });
  }
}
