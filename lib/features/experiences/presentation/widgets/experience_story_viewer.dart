import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/presentation/widgets/video_player_widget.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';

/// Widget para mostrar una experiencia individual tipo Instagram Story
/// Soporta reproducción automática de videos e imágenes con duración
class ExperienceStoryViewer extends StatefulWidget {
  final ExperienceEntity experience;
  final VoidCallback? onTap;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onClose;

  const ExperienceStoryViewer({
    super.key,
    required this.experience,
    this.onTap,
    this.onNext,
    this.onPrevious,
    this.onClose,
  });

  @override
  State<ExperienceStoryViewer> createState() => _ExperienceStoryViewerState();
}

class _ExperienceStoryViewerState extends State<ExperienceStoryViewer>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _scaleController;

  int currentMediaIndex = 0;
  bool isPaused = false;
  bool isPressed = false;
  bool isMediaReady =
      false; // Nueva variable para controlar cuando el media está listo

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startCurrentMedia();
  }

  void _initializeControllers() {
    _progressController = AnimationController(vsync: this);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isPaused) {
        _nextMedia();
      }
    });
  }

  void _startCurrentMedia() {
    if (currentMediaIndex >= widget.experience.media.length) return;

    setState(() {
      isMediaReady = false; // Reset del estado de carga
    });

    final currentMedia = widget.experience.media[currentMediaIndex];

    // Solo iniciar el progreso después de que el media esté listo
    // Para imágenes, se inicia inmediatamente
    // Para videos, se inicia cuando el VideoPlayerWidget notifique que está listo
    if (currentMedia.mediaType == MediaType.image) {
      _startProgressTimer(Duration(seconds: currentMedia.duration));
    }
    // Para videos, el timer se iniciará desde onVideoReady callback
  }

  void _startProgressTimer(Duration duration) {
    _progressController.duration = duration;
    setState(() {
      isMediaReady = true;
    });

    if (!isPaused) {
      _progressController.forward();
    }
  }

  void _onVideoReady() {
    // Callback para cuando el video esté listo para reproducirse
    if (currentMediaIndex < widget.experience.media.length) {
      final currentMedia = widget.experience.media[currentMediaIndex];
      if (currentMedia.mediaType == MediaType.video) {
        _startProgressTimer(Duration(seconds: currentMedia.duration));
      }
    }
  }

  void _nextMedia() {
    if (currentMediaIndex < widget.experience.media.length - 1) {
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

  void _onTapDown(TapDownDetails details) {
    setState(() {
      isPressed = true;
    });
    _scaleController.forward();
    _progressController.stop();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      isPressed = false;
    });
    _scaleController.reverse();

    if (!isPaused) {
      _progressController.forward();
    }
  }

  void _onTapCancel() {
    setState(() {
      isPressed = false;
    });
    _scaleController.reverse();

    if (!isPaused) {
      _progressController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.experience.media.isEmpty) {
      return const SizedBox();
    }

    final currentMedia = widget.experience.media[currentMediaIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Stack(
          children: [
            // Contenido principal
            Center(
              child: AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_scaleController.value * 0.05),
                    child: _buildMediaContent(currentMedia),
                  );
                },
              ),
            ),

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

            // Footer con descripción
            if (widget.experience.description.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 10,
                right: 10,
                child: _buildDescription(),
              ),

            // Botón de like para la historia
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              left: 20,
              child: StoryLikeButton(
                storyId: widget.experience.id,
                storyOwnerId: widget.experience.user.id,
              ),
            ),

            // Botón de cerrar
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 10,
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),

            // Áreas de toque para navegación
            _buildTouchAreas(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(ExperienceMediaEntity media) {
    switch (media.mediaType) {
      case MediaType.image:
        return OptimizedNetworkImage(
          imageUrl: media.url,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          imageType: 'experience',
          placeholder: Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(color: ColorTokens.primary50),
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
        widget.experience.media.length,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 1),
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.5),
              color: Colors.white.withOpacity(0.3),
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

    // Log de la experiencia actual
    print('=== BUILDING HEADER FOR EXPERIENCE ===');
    print('Experience ID: ${widget.experience.id}');
    print('Experience description: "${widget.experience.description}"');
    print('Experience created: ${widget.experience.createdAt}');
    print('Experience User Object: $user');
    print('Experience User ID: "${user.id}"');
    print('Experience User FullName: "${user.fullName}"');
    print('Experience User UserName: "${user.userName}"');
    print('Experience User Email: "${user.email}"');
    print('Experience User Photo: "${user.photo}"');
    print('FullName isEmpty: ${user.fullName.isEmpty}');
    print('UserName isEmpty: ${user.userName.isEmpty}');
    print('=====================================');

    return GestureDetector(
      onTap: () {
        print('🔄 Header tapped - Navegando al perfil del usuario: ${user.id}');
        if (user.id.isNotEmpty) {
          context.push('/user-profile/${user.id}');
        } else {
          print('❌ Error: User ID está vacío');
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isNotEmpty
                      ? user.fullName
                      : (user.userName.isNotEmpty
                            ? user.userName
                            : 'Usuario sin datos'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (user.userName.isNotEmpty)
                  Text(
                    '@${user.userName}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          // Tiempo
          Text(
            _getTimeAgo(widget.experience.createdAt),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 8),
          // Icono para indicar que es clickeable
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          if (isPaused) const Icon(Icons.pause, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Text(
        widget.experience.description,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildTouchAreas() {
    final topPadding = MediaQuery.of(context).padding.top;
    final closeButtonHeight = 60.0; // Altura reservada para el botón de cerrar

    return Column(
      children: [
        // Espacio superior para el botón de cerrar (no interceptar toques aquí)
        SizedBox(height: topPadding + closeButtonHeight),

        // Áreas táctiles en el resto de la pantalla
        Expanded(
          child: Row(
            children: [
              // Área izquierda para story anterior (30% del ancho)
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    // Si estamos en el primer media de la story, ir a la story anterior
                    if (currentMediaIndex == 0) {
                      widget.onPrevious?.call();
                    } else {
                      _previousMedia();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                  ),
                ),
              ),

              // Área central para pausar/reanudar (40% del ancho)
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: _togglePause,
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                  ),
                ),
              ),

              // Área derecha para siguiente story (30% del ancho)
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    // Si estamos en el último media de la story, ir a la siguiente story
                    if (currentMediaIndex ==
                        widget.experience.media.length - 1) {
                      widget.onNext?.call();
                    } else {
                      _nextMedia();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
    _scaleController.dispose();
    super.dispose();
  }
}
