import 'package:flutter/material.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/presentation/widgets/video_player_widget.dart';

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

    final currentMedia = widget.experience.media[currentMediaIndex];
    final duration = Duration(seconds: currentMedia.duration);

    _progressController.duration = duration;
    _progressController.forward();
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

    if (isPaused) {
      _progressController.stop();
    } else {
      _progressController.forward();
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
          fit: BoxFit.contain,
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
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage:
              widget.experience.user.photo.isNotEmpty
                  ? NetworkImage(widget.experience.user.photo)
                  : null,
          child:
              widget.experience.user.photo.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.experience.user.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (widget.experience.isRideExperience)
                const Text(
                  'Rodada programada',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ),
        if (isPaused) const Icon(Icons.pause, color: Colors.white, size: 24),
      ],
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
    return Row(
      children: [
        // Área izquierda para retroceder
        Expanded(
          child: GestureDetector(
            onTap: _previousMedia,
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
            ),
          ),
        ),

        // Área central para pausar/reanudar
        Expanded(
          child: GestureDetector(
            onTap: _togglePause,
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
            ),
          ),
        ),

        // Área derecha para avanzar
        Expanded(
          child: GestureDetector(
            onTap: _nextMedia,
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
