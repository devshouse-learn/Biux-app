import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/core/design_system/color_tokens.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
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
      body: Consumer<ExperienceProvider>(
        builder: (context, provider, child) {
          // Buscar la experiencia en el listado
          ExperienceEntity? experience;
          try {
            experience = provider.experiences.firstWhere(
              (exp) => exp.id == widget.postId,
            );
          } catch (e) {
            experience = null;
          }

          if (experience == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Publicación no encontrada',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final hasMultipleMedia = experience.media.length > 1;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Galería de imágenes
                _buildMediaGallery(context, experience, hasMultipleMedia),

                // Información del autor
                _buildAuthorInfo(context, experience),

                // Galería de miniaturas (si hay múltiples imágenes)
                if (hasMultipleMedia) _buildThumbnailGallery(experience),

                // Descripción
                if (experience.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      experience.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),

                // Acciones sociales (Likes y Comentarios)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
        },
      ),
    );
  }

  Widget _buildMediaGallery(
    BuildContext context,
    ExperienceEntity experience,
    bool hasMultipleMedia,
  ) {
    return Container(
      height: 500,
      width: double.infinity,
      color: Colors.black,
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
              if (media.mediaType.toString().contains('image')) {
                return GestureDetector(
                  onLongPress: () {
                    // Opción para descargar o compartir
                    _showMediaOptions(context, media.url);
                  },
                  child: CachedNetworkImage(
                    imageUrl: media.url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 48,
                        ),
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

  Widget _buildAuthorInfo(BuildContext context, ExperienceEntity experience) {
    final user = experience.user;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.push('/user-profile/${user.id}');
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[800],
              backgroundImage: user.photo.isNotEmpty
                  ? NetworkImage(user.photo)
                  : null,
              child: user.photo.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/user-profile/${user.id}');
                },
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName : user.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (user.userName.isNotEmpty)
                Text(
                  '@${user.userName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
            ],
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
}
