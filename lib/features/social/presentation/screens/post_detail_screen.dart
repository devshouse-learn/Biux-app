import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:firebase_database/firebase_database.dart';

/// Pantalla estilo Instagram para ver publicaciones con galería
/// Permite: ver imágenes en grande, darle like, y comentar
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  ExperienceEntity? _experience;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
    _loadExperience();
  }

  Future<void> _loadExperience() async {
    try {
      final provider = context.read<ExperienceProvider>();
      final experience = await provider.getExperienceById(widget.postId);

      if (mounted) {
        setState(() {
          _experience = experience;
          _isLoading = false;
          if (experience == null) {
            _error = 'Publicación no encontrada';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error cargando la publicación: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextImage(int mediaLength) {
    if (_currentImageIndex < mediaLength - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Formatea el tiempo relativo al formato solicitado
  String _formatRelativeTime(DateTime? createdAt) {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    // Menos de un minuto
    if (difference.inSeconds < 60) {
      return 'hace ${difference.inSeconds} segundo${difference.inSeconds != 1 ? 's' : ''}';
    }

    // Menos de una hora
    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes != 1 ? 's' : ''}';
    }

    // Menos de un día
    if (difference.inHours < 24) {
      return 'hace ${difference.inHours} hora${difference.inHours != 1 ? 's' : ''}';
    }

    // Menos de 7 días
    if (difference.inDays < 7) {
      return 'hace ${difference.inDays} día${difference.inDays != 1 ? 's' : ''}';
    }

    // Más de 7 días - mostrar formato DD de MM
    if (createdAt.year == now.year) {
      return '${createdAt.day.toString().padLeft(2, '0')} de ${_monthName(createdAt.month)}';
    }

    // Diferente año - mostrar DD de MM de AAAA
    return '${createdAt.day.toString().padLeft(2, '0')} de ${_monthName(createdAt.month)} de ${createdAt.year}';
  }

  String _monthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Publicación',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.white30),
            SizedBox(height: 16),
            Text(
              'Cargando publicación...',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null || _experience == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Publicación no encontrada',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary50,
                foregroundColor: Colors.white,
              ),
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    final experience = _experience!;
    final hasMultipleMedia = experience.media.length > 1;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Usuario ARRIBA de la imagen (separado como Instagram)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildUserOverlay(context, experience.user),
            ),
          ),

          // Galería de imágenes con botón de menú
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Stack(
                  children: [
                    // Galería de imágenes
                    _buildMediaGallery(context, experience, hasMultipleMedia),

                    // Botón de menú (tres puntos) en esquina superior derecha
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildPostOptions(context, experience),
                    ),
                  ],
                ),

                // Galería de miniaturas (si hay múltiples imágenes)
                if (hasMultipleMedia) _buildThumbnailGallery(experience),

                // Descripción y timestamp alineados a la izquierda, DEBAJO de la imagen
                if (experience.description.isNotEmpty ||
                    experience.createdAt != null)
                  _buildDescriptionAndTimestampInline(experience),
              ],
            ),
          ),

          // Acciones sociales (Likes y Comentarios)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: PostSocialActions(
              postId: experience.id,
              postOwnerId: experience.user.id,
              postPreview: experience.description.length > 50
                  ? experience.description.substring(0, 50)
                  : experience.description,
            ),
          ),

          // Sección de comentarios
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: PostCommentsPreview(
              postId: experience.id,
              postOwnerId: experience.user.id,
              maxComments: 5,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndTimestamp(ExperienceEntity experience) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (experience.description.isNotEmpty)
            Text(
              experience.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          if (experience.description.isNotEmpty && experience.createdAt != null)
            const SizedBox(height: 12),
          if (experience.createdAt != null)
            Text(
              _formatRelativeTime(experience.createdAt),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              textAlign: TextAlign.left,
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndTimestampInline(ExperienceEntity experience) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (experience.description.isNotEmpty)
            Text(
              experience.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          if (experience.description.isNotEmpty && experience.createdAt != null)
            const SizedBox(height: 12),
          if (experience.createdAt != null)
            Text(
              _formatRelativeTime(experience.createdAt),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              textAlign: TextAlign.left,
            ),
        ],
      ),
    );
  }

  Widget _buildMediaGallery(
    BuildContext context,
    ExperienceEntity experience,
    bool hasMultipleMedia,
  ) {
    final user = experience.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final galleryWidth = screenWidth - 32; // 16px padding en cada lado

    return Container(
      height: galleryWidth, // Mantener proporción 1:1 (cuadrado)
      width: galleryWidth,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Galería de imágenes con PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemCount: experience.media.length,
            itemBuilder: (context, index) {
              final media = experience.media[index];

              // Validar que la URL sea válida
              final url = media.url.trim();
              final isValidUrl =
                  url.isNotEmpty &&
                  (url.startsWith('http://') || url.startsWith('https://'));

              if (!isValidUrl) {
                return Container(
                  color: Colors.grey[900],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: Colors.grey[600],
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'URL no válida',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              if (media.mediaType.toString().contains('image')) {
                return GestureDetector(
                  onLongPress: () {
                    _showMediaOptions(context, media.url);
                  },
                  child: CachedNetworkImage(
                    imageUrl: media.url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No se pudo cargar',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // Video placeholder
                return Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(
                      Icons.video_library,
                      color: Colors.grey,
                      size: 64,
                    ),
                  ),
                );
              }
            },
          ),

          // Navegación izquierda/derecha
          if (hasMultipleMedia) ...[
            // Botón anterior
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _previousImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            // Botón siguiente
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _nextImage(experience.media.length),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Indicador de página
          if (hasMultipleMedia)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${experience.media.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailGallery(ExperienceEntity experience) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(experience.media.length, (index) {
            final media = experience.media[index];
            final isSelected = index == _currentImageIndex;

            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? ColorTokens.primary30
                        : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: media.url,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[800]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showMediaOptions(BuildContext context, String mediaUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.save_alt, color: Colors.blue),
                title: const Text('Descargar imagen'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar descarga
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Compartir'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar compartir
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: const Text('Reportar'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar reporte
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el overlay del usuario (sobreimpreso en la esquina superior izquierda)
  Widget _buildUserOverlay(BuildContext context, dynamic user) {
    return GestureDetector(
      onTap: () {
        context.push('/user-profile/${user.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey[700],
              backgroundImage: user.photo.isNotEmpty
                  ? NetworkImage(user.photo)
                  : null,
              child: user.photo.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.fullName.isNotEmpty ? user.fullName : user.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.userName.isNotEmpty)
                  Text(
                    '@${user.userName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón de opciones (menú de tres puntos)
  Widget _buildPostOptions(BuildContext context, ExperienceEntity experience) {
    return PopupMenuButton<String>(
      color: Colors.grey[800],
      onSelected: (value) {
        if (value == 'edit') {
          // TODO: Implementar editar post
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Editar post - Próximamente'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (value == 'delete') {
          _showDeletePostConfirmation(context, experience);
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Editar', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
      ),
    );
  }

  /// Muestra diálogo de confirmación para eliminar el post
  void _showDeletePostConfirmation(
    BuildContext context,
    ExperienceEntity experience,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Eliminar publicación',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta publicación? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _deletePostFromFirebase(context, experience);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Elimina el post de Firebase
  Future<void> _deletePostFromFirebase(
    BuildContext context,
    ExperienceEntity experience,
  ) async {
    try {
      final database = FirebaseDatabase.instance;

      // Intentar primero marcar como eliminado (actualización)
      try {
        await database.ref('experiences/${experience.id}').update({
          'isDeleted': true,
          'deletedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (updateError) {
        // Si falla la actualización, intentar eliminación directa
        if (updateError.toString().contains('Permission denied')) {
          await database.ref('experiences/${experience.id}').remove();
        } else {
          rethrow;
        }
      }

      // Mostrar éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación eliminada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navegar de vuelta después de 1 segundo
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
