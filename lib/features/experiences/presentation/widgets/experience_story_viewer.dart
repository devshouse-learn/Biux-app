import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
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

            // Footer con descripción y botón de publicidad
            if (widget.experience.description.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 10,
                left: 10,
                right: 10,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: _buildDescription(),
                  ),
                ),
              ),

            // Botón de like para la historia
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 150,
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == user.id;

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

    return Row(
      children: [
        // Avatar + información usuario (clickeable para ir al perfil)
        GestureDetector(
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
              Column(
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
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        const Spacer(),

        // Tiempo y estado
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
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

        // Botón de menú (solo para el autor)
        if (isOwner)
          IconButton(
            onPressed: () => _showStoryMenu(context),
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            padding: EdgeInsets.zero,
          )
        else
          const SizedBox(width: 40),
      ],
    );
  }

  /// Muestra el menú de opciones para la historia
  void _showStoryMenu(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == widget.experience.user.id;

    if (!isOwner) return; // Solo mostrar para el autor

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar historia',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteStory(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra diálogo de confirmación para eliminar
  void _confirmDeleteStory(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        title: Text(
          'Eliminar historia',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta historia? Esta acción no se puede deshacer.',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStory(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Elimina la historia
  void _deleteStory(BuildContext context) async {
    try {
      final provider = context.read<ExperienceProvider>();
      final success = await provider.deleteExperience(widget.experience.id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historia eliminada correctamente')),
          );
          // Cerrar el visor
          Navigator.pop(context);
          if (widget.onClose != null) {
            widget.onClose!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar la historia')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Descripción de la historia
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withValues(alpha: 0.5),
          ),
          child: Text(
            widget.experience.description,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        
        const SizedBox(height: 12),

        // Botón para agregar publicidad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddAdvertisementOptions(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.secondary50.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.campaign, size: 20),
            label: const Text(
              'Agregar Publicidad',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Muestra opciones para agregar una publicidad
  void _showAddAdvertisementOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Crear Publicidad',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Promociona tu negocio, producto o servicio a todos los ciclistas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Opción: Publicidad simple
              _AdvertisementOptionButton(
                icon: Icons.image,
                title: 'Publicidad Simple',
                description: 'Imagen + Título + Descripción',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCreateAdvertisement(context, 'simple');
                },
              ),
              
              const SizedBox(height: 12),
              
              // Opción: Publicidad premium
              _AdvertisementOptionButton(
                icon: Icons.star,
                title: 'Publicidad Premium',
                description: 'Con enlace directo y más visibilidad',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCreateAdvertisement(context, 'premium');
                },
                isPremium: true,
              ),
              
              const SizedBox(height: 12),
              
              // Botón de cerrar
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navega a la pantalla de crear publicidad
  void _navigateToCreateAdvertisement(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de crear publicidad $type en desarrollo'),
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Implementar navegación a CreateAdvertisementScreen
  }  Widget _buildTouchAreas() {
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
/// Widget para mostrar una opción de publicidad
class _AdvertisementOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isPremium;

  const _AdvertisementOptionButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isPremium
                ? ColorTokens.secondary50.withValues(alpha: 0.5)
                : theme.dividerColor,
            width: isPremium ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isPremium
              ? ColorTokens.secondary50.withValues(alpha: 0.05)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPremium
                    ? ColorTokens.secondary50.withValues(alpha: 0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isPremium ? ColorTokens.secondary50 : theme.iconTheme.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ColorTokens.secondary50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.iconTheme.color?.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}