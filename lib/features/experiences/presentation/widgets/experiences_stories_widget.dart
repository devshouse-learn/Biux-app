import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
        );
      },
    );
  }
}

/// Botón para agregar una nueva story general
class _AddStoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showCreateStoryOptions(context),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [ColorTokens.primary30, ColorTokens.secondary50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 70,
              child: Text(
                'Tu story',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
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

  void _showCreateStoryOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor:
          theme.bottomSheetTheme.backgroundColor ?? theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CreateOptionsBottomSheet(),
    );
  }
}

/// Bottom sheet con opciones para crear contenido (historias y publicaciones)
class _CreateOptionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Crear Contenido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige qué tipo de contenido quieres crear',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Botón para crear publicación (como antes)
          _StoryOptionButton(
            icon: Icons.article,
            title: 'Crear Publicación',
            subtitle: 'Compartir experiencias permanentes',
            color: ColorTokens.primary30,
            onTap: () {
              Navigator.of(context).pop();
              _navigateToCreatePost(context);
            },
          ),

          const SizedBox(height: 16),

          // Botón para crear historia
          _StoryOptionButton(
            icon: Icons.auto_stories,
            title: 'Crear Historia',
            subtitle: 'Desaparece en 24 horas',
            color: ColorTokens.secondary50,
            onTap: () {
              Navigator.of(context).pop();
              _navigateToCreateStory(context);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToCreatePost(BuildContext context) {
    // Navegar a crear publicación general (como estaba antes)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateExperienceScreen(
          experienceType: ExperienceType.general,
          isPostMode: true, // Modo publicación
          textOnly: false, // Permite multimedia
        ),
      ),
    );
  }

  void _navigateToCreateStory(BuildContext context) {
    // Navegar a la pantalla específica para crear historias (solo texto corto)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateExperienceScreen(
          experienceType: ExperienceType.general,
          isStoryMode: true, // Nuevo parámetro para forzar modo historia
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
    final theme = Theme.of(context);

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
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
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
    // Obtener el provider de story groups
    final storyGroupsProvider = Provider.of<StoryGroupsProvider>(
      context,
      listen: false,
    );

    // Encontrar el índice del grupo actual
    final allGroups = storyGroupsProvider.storyGroups;
    final currentIndex = allGroups.indexWhere(
      (g) => g.userId == storyGroup.userId,
    );

    // Mostrar las historias de este grupo en pantalla completa
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _StoryGroupViewerScreen(
          storyGroups: allGroups,
          initialGroupIndex: currentIndex >= 0 ? currentIndex : 0,
          onStoryViewed: (storyId) {
            // Marcar historia como vista
            storyGroupsProvider.markStoryAsViewed(storyId);
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

/// Pantalla temporal para visualizar historias de un grupo
class _StoryGroupViewerScreen extends StatefulWidget {
  final List<UserStoryGroupEntity> storyGroups;
  final int initialGroupIndex;
  final Function(String storyId) onStoryViewed;
  final VoidCallback onClose;

  const _StoryGroupViewerScreen({
    required this.storyGroups,
    required this.initialGroupIndex,
    required this.onStoryViewed,
    required this.onClose,
  });

  @override
  State<_StoryGroupViewerScreen> createState() =>
      _StoryGroupViewerScreenState();
}

class _StoryGroupViewerScreenState extends State<_StoryGroupViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentGroupIndex;
  int _currentStoryIndex = 0;
  bool _isPaused = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  AnimationController? _progressController;

  static const Duration _imageDuration = Duration(seconds: 5);

  UserStoryGroupEntity get _currentGroup =>
      widget.storyGroups[_currentGroupIndex];

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _progressController = AnimationController(vsync: this);

    // Inicializar de manera asíncrona
    _initialize();

    // Timer para actualizar el progreso del video
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _videoController != null && _isVideoInitialized) {
        setState(() {});
      }
      return mounted;
    });
  }

  /// Inicializa el visor encontrando la primera historia no vista
  Future<void> _initialize() async {
    if (_currentGroup.stories.isEmpty) return;

    // Encontrar la primera historia no vista
    _currentStoryIndex = await _findFirstUnseenStoryIndex();

    // NO marcar como vista aún - se marcará cuando el contenido se cargue
    await _initializeMedia();
  }

  /// Encuentra el índice de la primera historia no vista
  /// Si todas están vistas, comienza desde la primera (índice 0)
  Future<int> _findFirstUnseenStoryIndex() async {
    final storyGroupsProvider = context.read<StoryGroupsProvider>();

    for (int i = 0; i < _currentGroup.stories.length; i++) {
      final storyId = _currentGroup.stories[i].id;
      final isViewed = await storyGroupsProvider.isStoryViewed(storyId);

      if (!isViewed) {
        return i; // Primera historia no vista
      }
    }

    // Si todas están vistas, comenzar desde la primera
    return 0;
  }

  @override
  void dispose() {
    _progressController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMedia() async {
    final currentStory = _currentGroup.stories[_currentStoryIndex];

    // Detener progreso anterior
    _progressController?.stop();
    _progressController?.reset();

    // Limpiar video anterior si existe
    await _videoController?.dispose();
    _videoController = null;
    setState(() => _isVideoInitialized = false);

    if (currentStory.media.isNotEmpty &&
        currentStory.media[0].mediaType == MediaType.video) {
      // Obtener el video del caché o descargarlo
      final videoUrl = currentStory.media[0].url;

      // Intentar obtener del caché primero
      var fileInfo = await DefaultCacheManager().getFileFromCache(videoUrl);

      if (fileInfo == null) {
        // Si no está en caché, descargarlo y cachear
        fileInfo = await DefaultCacheManager().downloadFile(videoUrl);
      }

      // Inicializar el video player con el ARCHIVO LOCAL del caché
      _videoController = VideoPlayerController.file(
        fileInfo.file,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await _videoController!.initialize();

      if (mounted) {
        setState(() => _isVideoInitialized = true);
        _videoController!.play();

        // Marcar como vista cuando el video esté listo y comience a reproducirse
        widget.onStoryViewed(currentStory.id);

        // Listener para avanzar cuando termine el video
        _videoController!.addListener(() {
          if (_videoController!.value.position >=
              _videoController!.value.duration) {
            if (!_isPaused) {
              _nextStory();
            }
          }
        });
      }
    } else {
      // Para imágenes, NO iniciar el progreso aún
      // Se iniciará cuando la imagen termine de cargar
      _progressController!.duration = _imageDuration;
      // El progreso se iniciará desde _buildMediaWidget cuando la imagen cargue
    }
  }

  void _nextStory() async {
    if (_currentStoryIndex < _currentGroup.stories.length - 1) {
      // Avanzar a la siguiente historia del mismo usuario
      setState(() {
        _currentStoryIndex++;
      });
      // NO marcar como vista aún - se marcará cuando el contenido se cargue
      await _initializeMedia();
    } else if (_currentGroupIndex < widget.storyGroups.length - 1) {
      // Avanzar al siguiente usuario
      setState(() {
        _currentGroupIndex++;
      });
      // Inicializar desde la primera historia no vista del nuevo usuario
      await _initialize();
    } else {
      // No hay más historias, cerrar
      widget.onClose();
    }
  }

  void _previousStory() async {
    if (_currentStoryIndex > 0) {
      // Retroceder a la historia anterior del mismo usuario
      setState(() {
        _currentStoryIndex--;
      });
      await _initializeMedia();
    } else if (_currentGroupIndex > 0) {
      // Retroceder al usuario anterior
      setState(() {
        _currentGroupIndex--;
        _currentStoryIndex =
            widget.storyGroups[_currentGroupIndex].stories.length - 1;
      });
      // NO marcar como vista aún - se marcará cuando el contenido se cargue
      await _initializeMedia();
    }
  }

  void _pause() {
    setState(() => _isPaused = true);
    _progressController?.stop();
    _videoController?.pause();
  }

  void _resume() {
    setState(() => _isPaused = false);

    // Solo reanudar la animación si tiene duración configurada y no ha terminado
    if (_progressController != null &&
        _progressController!.duration != null &&
        !_progressController!.isCompleted) {
      _progressController!.forward();
    }

    if (_videoController != null && _isVideoInitialized) {
      _videoController!.play();
    }
  }

  Widget _buildMediaWidget(ExperienceMediaEntity media) {
    if (media.mediaType == MediaType.video) {
      if (_videoController != null && _isVideoInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      }
    } else {
      // Imagen con callback cuando termine de cargar
      return CachedNetworkImage(
        imageUrl: media.url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
        ),
        imageBuilder: (context, imageProvider) {
          // Iniciar el progreso cuando la imagen cargue completamente
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                _progressController != null &&
                !_progressController!.isAnimating &&
                !_isPaused) {
              // Marcar como vista cuando la imagen esté cargada y comience el progreso
              final currentStory = _currentGroup.stories[_currentStoryIndex];
              widget.onStoryViewed(currentStory.id);

              _progressController!.forward().then((_) {
                if (mounted && !_isPaused) {
                  _nextStory();
                }
              });
            }
          });

          return Image(
            image: imageProvider,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStory = _currentGroup.stories[_currentStoryIndex];

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? Colors.black
          : theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTapUp: (details) {
          // Solo ejecutar si no está pausado y fue un tap rápido (no long press)
          if (!_isPaused) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < screenWidth / 2) {
              _previousStory();
            } else {
              _nextStory();
            }
          }
        },
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        child: Stack(
          children: [
            // Imagen o video de la historia
            Center(
              child: currentStory.media.isNotEmpty
                  ? _buildMediaWidget(currentStory.media[0])
                  : Container(
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: Text(
                          currentStory.description,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),

            // Header con info del usuario y botón cerrar
            SafeArea(
              child: Column(
                children: [
                  // Indicadores de progreso
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: List.generate(_currentGroup.stories.length, (
                        index,
                      ) {
                        return Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: index < _currentStoryIndex
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                : index == _currentStoryIndex
                                ? AnimatedBuilder(
                                    animation: _progressController!,
                                    builder: (context, child) {
                                      double progress = 0.0;

                                      if (_videoController != null &&
                                          _isVideoInitialized) {
                                        // Progreso basado en video
                                        final position = _videoController!
                                            .value
                                            .position
                                            .inMilliseconds;
                                        final duration = _videoController!
                                            .value
                                            .duration
                                            .inMilliseconds;
                                        if (duration > 0) {
                                          progress = position / duration;
                                        }
                                      } else {
                                        // Progreso basado en animación para imágenes
                                        progress = _progressController!.value;
                                      }

                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: progress.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Info del usuario
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              _currentGroup.userProfilePhoto.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  _currentGroup.userProfilePhoto,
                                )
                              : null,
                          child: _currentGroup.userProfilePhoto.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentGroup.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Descripción al fondo
            if (currentStory.description.isNotEmpty)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    currentStory.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
