import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/presentation/widgets/video_player_widget.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/features/social/presentation/providers/likes_provider.dart';
import 'package:biux/features/social/domain/entities/like_entity.dart';
import 'package:biux/features/social/domain/repositories/likes_repository.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:share_plus/share_plus.dart';

/// Widget para mostrar una experiencia individual tipo Instagram Story
/// Soporta reproducción automática de videos e imágenes con duración
class ExperienceStoryViewer extends StatefulWidget {
  final ExperienceEntity experience;
  final List<({String experienceId, int mediaIndex})>? mediaOrigins;
  final VoidCallback? onTap;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onClose;

  const ExperienceStoryViewer({
    super.key,
    required this.experience,
    this.mediaOrigins,
    this.onTap,
    this.onNext,
    this.onPrevious,
    this.onClose,
  });

  @override
  State<ExperienceStoryViewer> createState() => _ExperienceStoryViewerState();
}

class _ExperienceStoryViewerState extends State<ExperienceStoryViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late List<ExperienceMediaEntity> _mediaItems;
  // ignore: unused_field
  // ignore: unused_field
  late List<({String experienceId, int mediaIndex})> _mediaOrigins;

  int currentMediaIndex = 0;
  bool isPaused = false;
  bool isPressed = false;
  bool isMediaReady =
      false; // Nueva variable para controlar cuando el media está listo

  @override
  void initState() {
    super.initState();
    _mediaItems = List.from(widget.experience.media);
    _mediaOrigins = widget.mediaOrigins != null
        ? List.from(widget.mediaOrigins!)
        : List.generate(
            widget.experience.media.length,
            (i) => (experienceId: widget.experience.id, mediaIndex: i),
          );
    _initializeControllers();
    _startCurrentMedia();
  }

  void _initializeControllers() {
    // Inicializar con duración estándar de 15 segundos
    _progressController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isPaused) {
        _nextMedia();
      }
    });
  }

  void _startCurrentMedia() {
    if (currentMediaIndex >= _mediaItems.length) return;

    setState(() {
      isMediaReady = false; // Reset del estado de carga
    });

    // Todas las historias duran exactamente 15 segundos como estándar
    const standardDuration = Duration(seconds: 15);

    // Solo iniciar el progreso después de que el media esté listo
    // Para imágenes, se inicia inmediatamente
    // Para videos, se inicia cuando el VideoPlayerWidget notifique que está listo
    final currentMedia = _mediaItems[currentMediaIndex];
    if (currentMedia.mediaType == MediaType.image) {
      _startProgressTimer(standardDuration);
    }
    // Para videos, el timer se iniciará desde onVideoReady callback
  }

  void _startProgressTimer(Duration duration) {
    // La duración ya está establecida en 15 segundos en _initializeControllers
    // Solo necesitamos resetear y forward el controlador
    _progressController.reset();
    setState(() {
      isMediaReady = true;
    });

    if (!isPaused) {
      _progressController.forward();
    }
  }

  void _onVideoReady() {
    // Callback para cuando el video esté listo para reproducirse
    // Todas las historias duran exactamente 15 segundos como estándar
    const standardDuration = Duration(seconds: 15);
    _startProgressTimer(standardDuration);
  }

  void _nextMedia() {
    if (currentMediaIndex < _mediaItems.length - 1) {
      setState(() {
        currentMediaIndex++;
      });
      _progressController.reset();
      _startCurrentMedia();
    } else {
      widget.onNext?.call();
    }
  }

  void _previousMedia() {
    if (currentMediaIndex > 0) {
      setState(() {
        currentMediaIndex--;
      });
      _progressController.reset();
      _startCurrentMedia();
    } else {
      widget.onPrevious?.call();
    }
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });

    // Solo controlar el progreso si el media está listo
    if (isMediaReady) {
      if (isPaused) {
        _progressController.stop();
      } else {
        _progressController.forward();
      }
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      isPressed = true;
    });
    _progressController.stop();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      isPressed = false;
    });

    if (!isPaused && isMediaReady) {
      _progressController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mediaItems.isEmpty) {
      return const SizedBox();
    }

    final currentMedia = _mediaItems[currentMediaIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        child: Stack(
          children: [
            // Contenido principal
            Center(child: _buildMediaContent(currentMedia)),

            // Barra de progreso superior
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              right: 10,
              child: _buildProgressBar(),
            ),

            // Header con información del usuario
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              left: 10,
              right: 10,
              child: _buildUserHeader(),
            ),

            // Footer con descripción centrada
            if (_getCurrentDescription().isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 10,
                left: 10,
                right: 10,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(child: _buildDescription()),
                ),
              ),

            // Botón de like para la historia (solo para otros usuarios, no para el propietario)
            if (FirebaseAuth.instance.currentUser?.uid !=
                widget.experience.user.id)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 150,
                left: 20,
                child: StoryLikeButton(
                  storyId: widget.experience.id,
                  storyOwnerId: widget.experience.user.id,
                ),
              ),

            // Botón de visualizadores (ojo con número de vistas) y likes - abajo a la derecha
            if (FirebaseAuth.instance.currentUser?.uid ==
                widget.experience.user.id)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => _showViewersModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: StreamBuilder<List<LikeEntity>>(
                      stream: context.read<LikesProvider>().watchLikes(
                        LikeableType.story,
                        widget.experience.id,
                      ),
                      builder: (context, likesSnap) {
                        final likesCount = likesSnap.hasData
                            ? likesSnap.data!.where((l) => !l.isExpired).length
                            : 0;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.experience.viewers.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (likesCount > 0) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                likesCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Áreas de toque para navegación
            _buildTouchAreas(),

            // Botón de TRES PUNTOS BLANCO arriba a la derecha - SOLO para propietarios
            if (FirebaseAuth.instance.currentUser?.uid ==
                widget.experience.user.id)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _showStoryOptions(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(ExperienceMediaEntity media) {
    switch (media.mediaType) {
      case MediaType.image:
        return Container(
          color: Colors.black,
          child: Center(
            child: OptimizedNetworkImage(
              imageUrl: media.url,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              imageType: 'experience',
              placeholder: Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: ColorTokens.primary50,
                  ),
                ),
              ),
            ),
          ),
        );

      case MediaType.video:
        return VideoPlayerWidget(
          videoUrl: media.url,
          autoPlay: true,
          isPlaying: !isPaused,
          onVideoReady:
              _onVideoReady, // Agregar callback para cuando esté listo
          onFinished: () {
            // Cuando termine el video, avanzar al siguiente automáticamente
            if (widget.onNext != null) {
              widget.onNext!();
            }
          },
          onTap: () {
            // Al tocar el video, pausar/reanudar igual que las imágenes
            _togglePause();
            widget.onTap?.call();
          },
        );
    }
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(
        _mediaItems.length,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 1),
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.5),
              color: Colors.white.withValues(alpha: 0.3),
            ),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                double progress = 0.0;
                if (index < currentMediaIndex) {
                  progress = 1.0;
                } else if (index == currentMediaIndex) {
                  progress = _progressController.value;
                }

                return FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    final user = widget.experience.user;

    return Row(
      children: [
        // Avatar + información usuario (clickeable para ir al perfil)
        Flexible(
          child: GestureDetector(
            onTap: () {
              if (user.id.isNotEmpty) {
                context.push('/user-profile/${user.id}');
              }
            },
            child: Row(
              children: [
                // Avatar simple
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user.photo.isNotEmpty
                      ? NetworkImage(user.photo)
                      : null,
                  child: user.photo.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                  backgroundColor: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                // Información directa del usuario
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.fullName.isNotEmpty
                            ? user.fullName
                            : (user.userName.isNotEmpty
                                  ? user.userName
                                  : 'Usuario sin datos'),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      if (user.userName.isNotEmpty)
                        Text(
                          '@${user.userName}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Tiempo y estado
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getTimeAgo(widget.experience.createdAt),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (isPaused) const SizedBox(height: 4),
            if (isPaused)
              const Text(
                'Pausado',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
          ],
        ),

        const SizedBox(width: 8),

        // No mostrar botón aquí - está en la esquina superior izquierda como PopupMenuButton
      ],
    );
  }

  /// Muestra diálogo de confirmación para eliminar
  void _confirmDeleteStory(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        title: Text(
          '¿Estás seguro/a que quieres eliminar esta historia?',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: Text(
          'No podrás recuperar esta historia después de eliminada',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteStory(context);
            },
            child: const Text('Eliminar historia'),
          ),
        ],
      ),
    );
  }

  /// Elimina la historia
  void _deleteStory(BuildContext context) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final provider = context.read<ExperienceProvider>();
      await provider.deleteExperience(widget.experience.id);

      // Cerrar el visor inmediatamente para UX instantánea
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(l.t('story_deleted_success')),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${l.t('error_generic')}: $e')),
        );
      }
    }
  }

  /// Confirma eliminación de una foto individual
  void _confirmDeleteMedia(BuildContext context) {
    final theme = Theme.of(context);
    final l = Provider.of<LocaleNotifier>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        title: Text(
          l.t('delete_photo_title'),
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: Text(
          l.t('delete_photo_description'),
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteMedia(context);
            },
            child: Text(l.t('delete_photo')),
          ),
        ],
      ),
    );
  }

  /// Elimina solo la foto actual de la historia
  void _deleteMedia(BuildContext context) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final provider = context.read<ExperienceProvider>();

      // Si después de eliminar no quedan más media, cerrar el visor y eliminar todo
      if (widget.experience.media.length <= 1) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        await provider.deleteExperience(widget.experience.id);
        return;
      }

      // Eliminar el media individual en el índice actual
      final mediaIndex = currentMediaIndex;
      final ok = await provider.removeMediaFromExperience(
        widget.experience.id,
        mediaIndex,
      );

      if (context.mounted) {
        if (ok) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l.t('media_deleted_success')),
              duration: const Duration(seconds: 2),
            ),
          );
          // Ajustar índice si eliminamos el último elemento
          if (mounted) {
            setState(() {
              _mediaItems.removeAt(mediaIndex);
              if (currentMediaIndex >= _mediaItems.length &&
                  currentMediaIndex > 0) {
                currentMediaIndex = _mediaItems.length - 1;
              }
            });
            _startCurrentMedia();
          }
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l.t('error_generic')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${l.t('error_generic')}: $e')),
        );
      }
    }
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.5),
      ),
      child: Text(
        _getCurrentDescription(),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  /// Obtiene la descripción del media actual (individual o de la experiencia)
  String _getCurrentDescription() {
    if (currentMediaIndex < _mediaItems.length) {
      final mediaDesc = _mediaItems[currentMediaIndex].description;
      if (mediaDesc != null && mediaDesc.isNotEmpty) {
        return mediaDesc;
      }
    }
    return widget.experience.description;
  }

  /// Muestra opciones de la historia (eliminar, compartir)
  void _showStoryOptions(BuildContext context) {
    final theme = Theme.of(context);

    // Pausar el progreso mientras se muestra el menú
    _progressController.stop();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Opción: Compartir
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorTokens.primary50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share, color: ColorTokens.primary50),
                ),
                title: const Text(
                  'Compartir',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Comparte esta historia'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _shareStory(context);
                },
              ),

              const SizedBox(height: 8),

              // Opción: Eliminar esta foto
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: Text(
                  _mediaItems.length > 1
                      ? 'Eliminar esta foto'
                      : 'Eliminar historia',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(
                  _mediaItems.length > 1
                      ? 'Solo se eliminará esta foto, no las demás'
                      : 'Esta acción no se puede deshacer',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  if (_mediaItems.length > 1) {
                    _confirmDeleteMedia(context);
                  } else {
                    _confirmDeleteStory(context);
                  }
                },
              ),

              const SizedBox(height: 12),

              // Cancelar
              TextButton(
                onPressed: () => Navigator.pop(modalContext),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // Reanudar el progreso cuando se cierre el menú
      if (!isPaused && isMediaReady) {
        _progressController.forward();
      }
    });
  }

  /// Comparte la historia
  void _shareStory(BuildContext context) async {
    final user = widget.experience.user;
    final description = widget.experience.description;
    final mediaUrl = _mediaItems.isNotEmpty
        ? _mediaItems[currentMediaIndex].url
        : '';

    final shareText = StringBuffer();
    if (user.fullName.isNotEmpty) {
      shareText.write('Historia de ${user.fullName}');
    } else {
      shareText.write('Historia de @${user.userName}');
    }
    if (description.isNotEmpty) {
      shareText.write('\n\n$description');
    }
    if (mediaUrl.isNotEmpty) {
      shareText.write('\n\n$mediaUrl');
    }
    shareText.write('\n\nCompartido desde Biux');

    try {
      await SharePlus.instance.share(ShareParams(text: shareText.toString()));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo compartir la historia')),
        );
      }
    }
  }

  /// Muestra modal con información de visualizaciones y likes
  void _showViewersModal(BuildContext context) {
    final theme = Theme.of(context);
    final viewers = widget.experience.viewers;
    final viewsCount = viewers.length;
    final hasViewers = viewers.isNotEmpty;
    final likesProvider = context.read<LikesProvider>();

    // Pausar el progreso mientras se muestra el modal
    _progressController.stop();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => DraggableScrollableSheet(
        initialChildSize: hasViewers ? 0.5 : 0.35,
        minChildSize: 0.25,
        maxChildSize: hasViewers ? 0.85 : 0.4,
        expand: false,
        builder: (sheetContext, scrollController) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de arrastre
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Encabezado con vistas y likes
                StreamBuilder<List<LikeEntity>>(
                  stream: likesProvider.watchLikes(
                    LikeableType.story,
                    widget.experience.id,
                  ),
                  builder: (context, likesHeaderSnapshot) {
                    final likesCount = likesHeaderSnapshot.hasData
                        ? likesHeaderSnapshot.data!
                              .where((l) => !l.isExpired)
                              .length
                        : 0;

                    return Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: ColorTokens.primary50,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$viewsCount ${viewsCount == 1 ? 'visualización' : 'visualizaciones'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (likesCount > 0) ...[
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$likesCount',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                if (hasViewers)
                  Expanded(
                    child: StreamBuilder<List<LikeEntity>>(
                      stream: likesProvider.watchLikes(
                        LikeableType.story,
                        widget.experience.id,
                      ),
                      builder: (context, likesSnapshot) {
                        final likerIds = <String>{};
                        if (likesSnapshot.hasData) {
                          for (final like in likesSnapshot.data!) {
                            if (!like.isExpired) {
                              likerIds.add(like.userId);
                            }
                          }
                        }

                        return ListView.separated(
                          controller: scrollController,
                          itemCount: viewers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final viewer = viewers[index];
                            final hasLiked = likerIds.contains(viewer.id);

                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pop(modalContext);
                                final currentUid =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (viewer.id == currentUid) {
                                  context.push('/profile');
                                } else {
                                  context.push('/user-profile/${viewer.id}');
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar con corazón superpuesto si dio like
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage:
                                              viewer.photo.isNotEmpty
                                              ? NetworkImage(viewer.photo)
                                              : null,
                                          backgroundColor: Colors.grey[600],
                                          child: viewer.photo.isEmpty
                                              ? const Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        if (hasLiked)
                                          Positioned(
                                            bottom: -2,
                                            right: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: theme.cardColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    // Información del usuario
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            viewer.fullName.isNotEmpty
                                                ? viewer.fullName
                                                : (viewer.userName.isNotEmpty
                                                      ? viewer.userName
                                                      : 'Usuario'),
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (viewer.userName.isNotEmpty)
                                            Text(
                                              '@${viewer.userName}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Icono de flecha para indicar navegación
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                else
                  // Mensaje cuando no hay visualizaciones
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorTokens.primary50.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_off,
                          color: Colors.grey[600],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nadie ha visto tu historia aún',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comparte tu historia con más amigos para que la vean',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      // Reanudar el progreso cuando se cierre el modal
      if (!isPaused && isMediaReady) {
        _progressController.forward();
      }
    });
  }

  Widget _buildTouchAreas() {
    final topPadding = MediaQuery.of(context).padding.top;
    final closeButtonHeight = 60.0;

    return Positioned(
      top: topPadding + closeButtonHeight,
      left: 0,
      right: 0,
      bottom: 0,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                if (currentMediaIndex == 0) {
                  widget.onPrevious?.call();
                } else {
                  _previousMedia();
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _togglePause,
              child: Container(color: Colors.transparent),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                if (currentMediaIndex == _mediaItems.length - 1) {
                  widget.onNext?.call();
                } else {
                  _nextMedia();
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }
}
