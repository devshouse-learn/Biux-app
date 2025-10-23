import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/presentation/widgets/experiences_stories_widget.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Pantalla principal para mostrar la lista de experiencias
class ExperiencesListScreen extends StatefulWidget {
  const ExperiencesListScreen({super.key});

  @override
  State<ExperiencesListScreen> createState() => _ExperiencesListScreenState();
}

class _ExperiencesListScreenState extends State<ExperiencesListScreen>
    with WidgetsBindingObserver {
  Timer? _autoRefreshTimer;

  /// Obtiene el ID del usuario actual autenticado
  String? get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Cargar feed personalizado al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeed();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App vuelve a primer plano - recargar y reiniciar timer
      _loadFeed();
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused) {
      // App va a segundo plano - pausar timer
      _autoRefreshTimer?.cancel();
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _loadFeed(),
    );
  }

  Future<void> _loadFeed() async {
    final userId = _currentUserId;
    if (userId != null) {
      // Cambiar a feed personalizado que incluye grupos, mis posts y posts de seguidos
      await context.read<ExperienceProvider>().loadPersonalizedFeed(userId);
      // Cargar grupos que sigue el usuario
      context.read<GroupProvider>().loadUserGroups();
    } else {
      print('⚠️ Usuario no autenticado, no se puede cargar el feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mi Feed',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/users/search');
            },
            icon: const Icon(Icons.search),
            tooltip: 'Buscar usuarios',
          ),
        ],
      ),
      body: Consumer<ExperienceProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostOptions(context),
        backgroundColor:
            theme.floatingActionButtonTheme.backgroundColor ??
            theme.primaryColor,
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
    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: Column(
        children: [
          // Sección de Grupos que sigo (temporalmente comentado)
          // _buildGroupsSection(),

          // Sección de Stories con indicador
          const ExperiencesStoriesWidget(),

          // Lista de posts abajo o estado vacío
          Expanded(
            child: posts.isEmpty
                ? _buildEmptyStateInLayout()
                : _buildExperiencesList(posts),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ExperienceProvider provider) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar experiencias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
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
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Estado vacío cuando no hay posts pero sí hay stories
  Widget _buildEmptyStateInLayout() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: theme.iconTheme.color?.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '¡Comparte tu primera publicación!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Las stories van arriba en círculos.\nAquí van las publicaciones con más contenido.',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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

  /// Muestra opciones para crear POST (con multimedia o solo texto)
  void _showCreatePostOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor:
          theme.bottomSheetTheme.backgroundColor ?? theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
              'Crear Publicación',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige el tipo de post que quieres compartir',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Opciones de post
            Column(
              children: [
                // Post con multimedia
                _PostOptionTile(
                  icon: Icons.photo_library,
                  title: 'Post con Multimedia',
                  subtitle: 'Fotos o videos',
                  color: ColorTokens.secondary50,
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToCreatePostWithMedia(context);
                  },
                ),

                const SizedBox(height: 12),

                // Post solo texto
                _PostOptionTile(
                  icon: Icons.text_fields,
                  title: 'Post de Texto',
                  subtitle: 'Solo texto, sin multimedia',
                  color: ColorTokens.primary30,
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToCreateTextPost(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToCreatePostWithMedia(BuildContext context) {
    // Navegar a crear post CON multimedia (fotos/videos)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateExperienceScreen(
          experienceType: ExperienceType.general,
          isPostMode: true,
          textOnly: false, // Permite multimedia
        ),
      ),
    );
  }

  void _navigateToCreateTextPost(BuildContext context) {
    // Navegar a crear post SOLO texto (SIN multimedia)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateExperienceScreen(
          experienceType: ExperienceType.general,
          isPostMode: true,
          textOnly: true, // Bloquea multimedia
        ),
      ),
    );
  }
}

/// Widget para mostrar una experiencia individual en la lista
class _ExperienceCard extends StatelessWidget {
  final ExperienceEntity experience;

  const _ExperienceCard({required this.experience});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
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
          if (experience.media.isNotEmpty) _buildMediaSection(context),

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
                      color: theme.textTheme.bodyMedium?.color,
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

          // Divider
          const Divider(height: 1),

          // Acciones sociales (Likes y Comentarios)
          PostSocialActions(
            postId: experience.id,
            postOwnerId: experience.user.id,
            postPreview: experience.description.length > 50
                ? experience.description.substring(0, 50)
                : experience.description,
          ),

          // Vista previa de comentarios
          PostCommentsPreview(
            postId: experience.id,
            postOwnerId: experience.user.id,
            maxComments: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    final theme = Theme.of(context);
    final media = experience.media.first;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: media.mediaType == MediaType.image
              ? Image.network(
                  media.url,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) {
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: theme.iconTheme.color?.withOpacity(0.5),
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Wrap(
          spacing: 8,
          runSpacing: 4,
          children: experience.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMetadata() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Row(
          children: [
            // Type indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                experience.type == ExperienceType.ride ? 'Rodada' : 'General',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Media count
            if (experience.media.length > 1) ...[
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${experience.media.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAuthorHeader(BuildContext context) {
    final theme = Theme.of(context);
    final user = experience.user;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar y nombre del autor - con navegación al perfil
          GestureDetector(
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
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user.photo.isNotEmpty
                      ? NetworkImage(user.photo)
                      : null,
                  child: user.photo.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isNotEmpty
                          ? user.fullName
                          : (user.userName.isNotEmpty
                                ? user.userName
                                : 'Usuario sin nombre'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Row(
                      children: [
                        if (user.userName.isNotEmpty)
                          Text(
                            '@${user.userName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        if (user.userName.isNotEmpty)
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        Text(
                          _formatDate(experience.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: SizedBox()),
          // Botón de menú (3 puntos) - alineado a la derecha con padding
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color, size: 20),
            onPressed: () => _showPostMenu(context),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  void _showPostMenu(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == experience.user.id;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          theme.bottomSheetTheme.backgroundColor ?? theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Eliminar publicación',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: theme.iconTheme.color),
                title: Text(
                  'Editar publicación',
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de editar próximamente'),
                    ),
                  );
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.flag, color: theme.iconTheme.color),
                title: Text(
                  'Reportar publicación',
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de reportar próximamente'),
                    ),
                  );
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.share, color: theme.iconTheme.color),
              title: Text(
                'Compartir',
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                _sharePost(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          'Eliminar publicación',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta publicación? Esta acción no se puede deshacer.',
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
              _deletePost(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePost(BuildContext context) async {
    try {
      final provider = context.read<ExperienceProvider>();
      await provider.deleteExperience(experience.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación eliminada correctamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  void _sharePost(BuildContext context) async {
    try {
      // Construir el mensaje para compartir
      final userName = experience.user.fullName.isNotEmpty
          ? experience.user.fullName
          : experience.user.userName;

      String shareText = '🚴 ¡Mira esta publicación de $userName en Biux!\n\n';

      if (experience.description.isNotEmpty) {
        // Limitar la descripción a 150 caracteres
        final description = experience.description.length > 150
            ? '${experience.description.substring(0, 150)}...'
            : experience.description;
        shareText += '$description\n\n';
      }

      // Agregar deep link con dominio personalizado
      shareText += 'https://biux.devshouse.org/posts/${experience.id}\n\n';
      shareText += '📱 Si no tienes la app, descárgala para ver más';

      // Usar Share.share del paquete share_plus
      await Share.share(shareText, subject: 'Publicación de Biux');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al compartir: $e')));
      }
    }
  }
}

/// Widget para cada opción de post
class _PostOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PostOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
