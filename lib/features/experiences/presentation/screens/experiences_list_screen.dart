import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/widgets/experiences_stories_widget.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';

/// Pantalla principal para mostrar la lista de experiencias
class ExperiencesListScreen extends StatefulWidget {
  const ExperiencesListScreen({super.key});

  @override
  State<ExperiencesListScreen> createState() => _ExperiencesListScreenState();
}

class _ExperiencesListScreenState extends State<ExperiencesListScreen> {
  /// Obtiene el ID del usuario actual autenticado
  String? get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  void initState() {
    super.initState();
    // Cargar feed personalizado al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = _currentUserId;
      if (userId != null) {
        // Cambiar a feed personalizado que incluye grupos, mis posts y posts de seguidos
        context.read<ExperienceProvider>().loadPersonalizedFeed(userId);
        // Cargar grupos que sigue el usuario
        context.read<GroupProvider>().loadUserGroups();
      } else {
        print('⚠️ Usuario no autenticado, no se puede cargar el feed');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mi Feed',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: ColorTokens.primary30,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/users/search');
            },
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Buscar usuarios',
          ),
          IconButton(
            onPressed: () {
              context.push('/stories/create');
            },
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Crear experiencia',
          ),
        ],
      ),
      body: Consumer<ExperienceProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/stories/create');
        },
        backgroundColor: ColorTokens.secondary50,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(ExperienceProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _buildErrorState(provider.error!, provider);
    }

    // Separar CORRECTAMENTE stories de posts regulares
    final allExperiences = provider.experiences; // Feed personalizado

    // POSTS: Experiencias que van en el feed principal vertical
    // - Pueden o no tener media
    // - Cualquier longitud de descripción
    // - EXCLUYE las que ya se muestran como stories
    final posts = allExperiences.where((exp) => exp.isPostFormat).toList();

    // Layout tipo Instagram: Grupos arriba, Stories en medio, publicaciones abajo
    return Column(
      children: [
        // Sección de Grupos que sigo (temporalmente comentado)
        // _buildGroupsSection(),

        // Sección de Stories con indicador
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget de stories
            const ExperiencesStoriesWidget(),
          ],
        ),

        // Divisor con indicador de Posts
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(height: 1, color: ColorTokens.neutral20),
        ),

        // Lista de posts abajo o estado vacío
        Expanded(
          child: posts.isEmpty
              ? _buildEmptyStateInLayout()
              : _buildExperiencesList(posts),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, ExperienceProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error al cargar experiencias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final userId = _currentUserId;
              if (userId != null) {
                provider.loadPersonalizedFeed(userId);
              } else {
                print('⚠️ Usuario no autenticado, no se puede recargar');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary50,
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado vacío cuando no hay posts pero sí hay stories
  Widget _buildEmptyStateInLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '¡Comparte tu primera publicación!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las stories van arriba en círculos.\nAquí van las publicaciones con más contenido.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencesList(List<ExperienceEntity> experiences) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final experience = experiences[index];
        return _ExperienceCard(experience: experience);
      },
    );
  }
}

/// Widget para mostrar una experiencia individual en la lista
class _ExperienceCard extends StatelessWidget {
  final ExperienceEntity experience;

  const _ExperienceCard({required this.experience});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con información del autor del post
          _buildAuthorHeader(context),

          // Media section
          if (experience.media.isNotEmpty) _buildMediaSection(),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (experience.description.isNotEmpty)
                  Text(
                    experience.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),

                const SizedBox(height: 12),

                // Tags
                if (experience.tags.isNotEmpty) _buildTags(),

                if (experience.tags.isNotEmpty) const SizedBox(height: 12),

                // Metadata
                _buildMetadata(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    final media = experience.media.first;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.grey[200],
          child: media.mediaType == MediaType.image
              ? Image.network(
                  media.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 48,
                        ),
                      ),
                    );
                  },
                )
              : Stack(
                  children: [
                    if (media.thumbnailUrl != null)
                      Image.network(
                        media.thumbnailUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: experience.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ColorTokens.primary50.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorTokens.primary50,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        // Type indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: experience.type == ExperienceType.ride
                ? ColorTokens.secondary50.withOpacity(0.1)
                : ColorTokens.primary50.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            experience.type == ExperienceType.ride ? 'Rodada' : 'General',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: experience.type == ExperienceType.ride
                  ? ColorTokens.secondary50
                  : ColorTokens.primary50,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Media count
        if (experience.media.length > 1)
          Row(
            children: [
              Icon(Icons.photo_library, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${experience.media.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

        const Spacer(),

        // Date
        Text(
          _formatDate(experience.createdAt),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }

  Widget _buildAuthorHeader(BuildContext context) {
    final user = experience.user;

    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          print(
            '🔄 Post author tapped - Navegando al perfil del usuario: ${user.id}',
          );
          if (user.id.isNotEmpty) {
            context.push('/user-profile/${user.id}');
          } else {
            print('❌ Error: User ID está vacío');
          }
        },
        child: Row(
          children: [
            // Avatar del autor
            CircleAvatar(
              radius: 20,
              backgroundImage: user.photo.isNotEmpty
                  ? NetworkImage(user.photo)
                  : null,
              child: user.photo.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
              backgroundColor: Colors.grey[400],
            ),
            const SizedBox(width: 12),
            // Información del autor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName.isNotEmpty
                        ? user.fullName
                        : (user.userName.isNotEmpty
                              ? user.userName
                              : 'Usuario sin nombre'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: ColorTokens.neutral80,
                    ),
                  ),
                  if (user.userName.isNotEmpty)
                    Text(
                      '@${user.userName}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            // Tiempo de publicación
            Text(
              _formatDate(experience.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }
}
