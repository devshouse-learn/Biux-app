import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/presentation/widgets/experience_story_viewer.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';

/// Widget para mostrar stories de una rodada de forma horizontal (tipo Instagram)
/// Se muestra en la parte superior de la pantalla de detalle de rodada
class RideStoriesWidget extends StatefulWidget {
  final String rideId;
  final String rideName;

  const RideStoriesWidget({
    super.key,
    required this.rideId,
    required this.rideName,
  });

  @override
  State<RideStoriesWidget> createState() => _RideStoriesWidgetState();
}

class _RideStoriesWidgetState extends State<RideStoriesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExperienceProvider>(
        context,
        listen: false,
      ).loadRideExperiences(widget.rideId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExperienceProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_stories,
                    color: ColorTokens.primary30,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stories de la rodada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorTokens.neutral90,
                    ),
                  ),
                  const Spacer(),
                  if (provider.rideExperiences.isNotEmpty)
                    Text(
                      '${provider.rideExperiences.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTokens.neutral60,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Stories horizontales
              SizedBox(
                height: 90,
                child: provider.isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Row(
                        children: [
                          // Botón "Agregar Story"
                          _AddStoryButton(
                            rideId: widget.rideId,
                            rideName: widget.rideName,
                          ),
                          const SizedBox(width: 12),

                          // Lista de stories existentes
                          Expanded(
                            child: provider.rideExperiences.isEmpty
                                ? Center(
                                    child: Text(
                                      'No hay stories aún.\n¡Sé el primero en compartir!',
                                      style: TextStyle(
                                        color: ColorTokens.neutral60,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: provider.rideExperiences.length,
                                    itemBuilder: (context, index) {
                                      final story =
                                          provider.rideExperiences[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: _StoryCircle(
                                          story: story,
                                          onTap: () => _openStoryViewer(
                                            context,
                                            story,
                                            provider.rideExperiences,
                                            index,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
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
            ExperienceStoryViewer(
              experience: story,
              onNext: initialIndex < allStories.length - 1
                  ? () => _openStoryViewer(
                      context,
                      allStories[initialIndex + 1],
                      allStories,
                      initialIndex + 1,
                    )
                  : null,
              onPrevious: initialIndex > 0
                  ? () => _openStoryViewer(
                      context,
                      allStories[initialIndex - 1],
                      allStories,
                      initialIndex - 1,
                    )
                  : null,
              onClose: () => Navigator.of(context).pop(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        fullscreenDialog: true,
      ),
    );
  }
}

/// Botón para agregar una nueva story a la rodada
class _AddStoryButton extends StatelessWidget {
  final String rideId;
  final String rideName;

  const _AddStoryButton({required this.rideId, required this.rideName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateStoryOptions(context),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorTokens.neutral40, width: 2),
              color: ColorTokens.neutral10,
            ),
            child: Icon(Icons.add, color: ColorTokens.neutral60, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            'Tu story',
            style: TextStyle(fontSize: 12, color: ColorTokens.neutral60),
            textAlign: TextAlign.center,
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
      builder: (context) =>
          _StoryOptionsBottomSheet(rideId: rideId, rideName: rideName),
    );
  }
}

/// Bottom sheet con opciones para crear stories (video o texto)
class _StoryOptionsBottomSheet extends StatelessWidget {
  final String rideId;
  final String rideName;

  const _StoryOptionsBottomSheet({
    required this.rideId,
    required this.rideName,
  });

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
            'Selecciona el tipo de story que quieres crear',
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

              // Texto Story
              _StoryOptionButton(
                icon: Icons.text_fields,
                title: 'Texto Story',
                subtitle: 'Comparte tu experiencia',
                color: ColorTokens.success40,
                onTap: () {
                  Navigator.of(context).pop();
                  _showCreateTextStory(context);
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
        builder: (context) => CreateExperienceScreen(
          experienceType: ExperienceType.ride,
          rideId: rideId,
        ),
      ),
    );
  }

  void _showCreateTextStory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _CreateStoryBottomSheet(rideId: rideId, rideName: rideName),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
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
        children: [
          Stack(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      ColorTokens.primary30,
                      ColorTokens.primary60,
                      ColorTokens.success40,
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
                          : ColorTokens.primary30.withOpacity(0.1),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorTokens.primary30,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              // Indicador de video
              if (story.hasVideo)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ColorTokens.primary30,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 66,
            child: Text(
              story.user.userName.isNotEmpty
                  ? story.user.userName
                  : story.user.fullName.split(' ').first,
              style: TextStyle(fontSize: 11, color: ColorTokens.neutral80),
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

/// Bottom sheet para crear una nueva story
class _CreateStoryBottomSheet extends StatefulWidget {
  final String rideId;
  final String rideName;

  const _CreateStoryBottomSheet({required this.rideId, required this.rideName});

  @override
  State<_CreateStoryBottomSheet> createState() =>
      _CreateStoryBottomSheetState();
}

class _CreateStoryBottomSheetState extends State<_CreateStoryBottomSheet> {
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle del bottom sheet
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ColorTokens.neutral30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Crear Story',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.neutral90,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: ColorTokens.neutral60),
                ),
              ],
            ),
          ),

          // Info de la rodada
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorTokens.primary30.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorTokens.primary30.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_bike,
                  color: ColorTokens.primary30,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.rideName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorTokens.primary30,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Formulario
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Descripción
                  Text(
                    'Describe tu experiencia *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorTokens.neutral90,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          '¡Comparte cómo va tu rodada! 🚴‍♂️\n\nEjemplo: "Vista increíble desde la montaña 🏔️"',
                      hintStyle: TextStyle(color: ColorTokens.neutral50),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorTokens.neutral30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorTokens.primary30,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags opcionales
                  Text(
                    'Tags (opcional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorTokens.neutral90,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      hintText:
                          'paisaje, aventura, montaña (separados por comas)',
                      hintStyle: TextStyle(color: ColorTokens.neutral50),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorTokens.neutral30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorTokens.primary30,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Botón de crear
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.primary30,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Publicar Story',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createStory() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, describe tu experiencia'),
          backgroundColor: ColorTokens.warning60,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final provider = Provider.of<ExperienceProvider>(context, listen: false);

      // Parsear tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      await provider.createExperience(
        CreateExperienceRequest(
          description: _descriptionController.text.trim(),
          tags: tags,
          mediaFiles: [], // Por ahora sin media
          type: ExperienceType.ride,
          rideId: widget.rideId,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Story publicada con éxito! 🎉'),
            backgroundColor: ColorTokens.success40,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }
}
