import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/entities/advertisement_entity.dart';
import 'package:biux/features/experiences/presentation/widgets/experiences_stories_widget.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/shared/widgets/post_card.dart';

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
      _startFeedListener();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    context.read<ExperienceProvider>().stopFeedListener();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App vuelve a primer plano - recargar y reiniciar listener
      _loadFeed();
      _startFeedListener();
    } else if (state == AppLifecycleState.paused) {
      // App va a segundo plano - pausar listener
      _autoRefreshTimer?.cancel();
      context.read<ExperienceProvider>().stopFeedListener();
    }
  }

  void _startFeedListener() {
    final userId = _currentUserId;
    if (userId != null) {
      context.read<ExperienceProvider>().startFeedListener(userId);
    }
    // Mantener timer como respaldo cada 5 minutos
    _startAutoRefresh();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorTokens.primary30,
        title: GestureDetector(
          onTap: _loadFeed,
          child: const Text(
            'Mi Feed',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/users/search');
            },
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Buscar usuarios',
          ),
        ],
      ),
      body: Consumer<ExperienceProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
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
    // - Incluye fotos y videos con contenido válido
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
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.iconTheme.color?.withValues(alpha: 0.5),
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
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final userId = _currentUserId;
              if (userId != null) {
                provider.loadPersonalizedFeed(userId);
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
    // ignore: unused_local_variable
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
                color: theme.iconTheme.color?.withValues(alpha: 0.5),
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
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
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
    final provider = context.read<ExperienceProvider>();

    // Crear lista intercalada de posts y anuncios
    final intercaledList = _intercaleAdvertisements(experiences);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Detectar cuando el usuario llega al 80% del scroll
        if (!provider.isLoadingMore &&
            provider.hasMorePosts &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.8) {
          final userId = _currentUserId;
          if (userId != null) {
            provider.loadMorePosts(userId);
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: intercaledList.length + (provider.hasMorePosts ? 1 : 0),
        itemBuilder: (context, index) {
          // Mostrar post normal o anuncio
          if (index < intercaledList.length) {
            final item = intercaledList[index];

            if (item is ExperienceEntity) {
              return _ExperienceCard(experience: item);
            } else if (item is AdvertisementEntity) {
              return _AdvertisementCard(advertisement: item);
            }
          }

          // Mostrar indicador de carga al final
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: provider.isLoadingMore
                  ? CircularProgressIndicator()
                  : SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  /// Intercala anuncios en el feed cada 5 experiencias normales
  /// Retorna una lista mezclada de ExperienceEntity y AdvertisementEntity
  List<dynamic> _intercaleAdvertisements(List<ExperienceEntity> experiences) {
    if (experiences.isEmpty) {
      return [];
    }

    final result = <dynamic>[];
    int postCount = 0;

    for (int i = 0; i < experiences.length; i++) {
      result.add(experiences[i]);
      postCount++;

      // Intercalar anuncio cada 5 posts normales
      if (postCount == 5) {
        result.add(_createMockAdvertisement(i ~/ 5));
        postCount = 0;
      }
    }

    return result;
  }

  /// Crea un anuncio de ejemplo
  /// En producción, esto vendría de un repositorio que consulte el backend
  AdvertisementEntity _createMockAdvertisement(int index) {
    final advertisements = [
      AdvertisementEntity(
        id: 'ad_1',
        title: 'Biux Premium',
        description:
            'Desbloquea funciones exclusivas y conecta con más ciclistas',
        imageUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=300&fit=crop',
        callToActionText: 'Descubrir',
        callToActionUrl: 'https://biux.app/premium',
        advertiserName: 'Biux',
        createdAt: DateTime.now(),
      ),
      AdvertisementEntity(
        id: 'ad_2',
        title: 'Accesorios para Ciclismo',
        description: 'Los mejores accesorios para tus rodadas. Envío gratis.',
        imageUrl:
            'https://images.unsplash.com/photo-1552820728-8ac41f1ce891?w=500&h=300&fit=crop',
        callToActionText: 'Ver catálogo',
        callToActionUrl: 'https://shop.biux.app',
        advertiserName: 'Biux Shop',
        createdAt: DateTime.now(),
      ),
      AdvertisementEntity(
        id: 'ad_3',
        title: 'Rodadas Organizadas',
        description:
            'Únete a nuestras rodadas semanales y conoce ciclistas de tu zona',
        imageUrl:
            'https://images.unsplash.com/photo-1519578962823-e54908f409b7?w=500&h=300&fit=crop',
        callToActionText: 'Explorar',
        callToActionUrl: 'https://biux.app/rides',
        advertiserName: 'Biux Community',
        createdAt: DateTime.now(),
      ),
    ];

    return advertisements[index % advertisements.length];
  }

  /// Navegar directamente a crear publicación (comportamiento original)
  // ignore: unused_element
  void _navigateToCreatePost(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const CreateExperienceScreen(
              experienceType: ExperienceType.general,
              isPostMode: true, // Modo publicación permanente
              textOnly: false, // Permite multimedia
            ),
          ),
        )
        .then((result) {
          // Si se creó exitosamente, recargar el feed
          if (result == true) {
            _loadFeed();
          }
        });
  }

  /// Muestra opciones para crear POST (con multimedia o solo texto)
  // ignore: unused_element
  void _showCreatePostOptions(BuildContext context) {
    // ignore: unused_local_variable
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
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Opciones de post - DESHABILITADAS: Las publicaciones deben ser dentro de un contexto
            /*
            Column(
              children: [
                // Post con multimedia
                _PostOptionTile(
                  icon: Icons.photo_library,
                  title: 'Post con Multimedia',
                  subtitle: 'Solo fotos',
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
            */
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // MÉTODOS COMENTADOS - Ya no se crean publicaciones generales
  /*
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
  */
}

/// Widget para mostrar una experiencia individual en la lista
class _ExperienceCard extends StatelessWidget {
  final ExperienceEntity experience;

  const _ExperienceCard({required this.experience});

  @override
  Widget build(BuildContext context) {
    final imageUrls = experience.media.map((m) => m.url).toList();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // ignore: unused_local_variable
    final isOwner = currentUserId == experience.user.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: PostCard(
        user: PostCardUser(
          id: experience.user.id,
          fullName: experience.user.fullName,
          userName: experience.user.userName,
          photo: experience.user.photo,
        ),
        imageUrls: imageUrls,
        description: experience.description,
        timestamp: _formatDate(experience.createdAt),
        isEdited: experience.isEdited,
        onUserTap: () {
          if (experience.user.id.isNotEmpty) {
            if (currentUserId == experience.user.id) {
              context.push('/profile');
            } else {
              context.push('/user-profile/${experience.user.id}');
            }
          }
        },
        onImageTap: (_) {
          context.push('/social/post/${experience.id}');
        },
        headerTrailing: [
          GestureDetector(
            onTap: () => _showPostMenu(context),
            child: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
          ),
        ],
        actionsWidget: PostSocialActions(
          postId: experience.id,
          postOwnerId: experience.user.id,
          postPreview: experience.description.length > 50
              ? experience.description.substring(0, 50)
              : experience.description,
        ),
        bottomWidget: PostCommentsPreview(
          postId: experience.id,
          postOwnerId: experience.user.id,
          maxComments: 2,
        ),
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
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // ignore: unused_local_variable
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
                  context.push(
                    '/edit-post/${experience.id}',
                    extra: experience,
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
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
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
      // En lugar de compartir un link, abrir la app directamente con deep link
      final deepLink = 'biux://posts/${experience.id}';
      await launchUrl(
        Uri.parse(deepLink),
        mode: LaunchMode.externalApplication,
      ).catchError((e) {
        // Fallback: si el deep link falla, mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La app debe estar instalada para compartir')),
        );
        return false;
      });
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
// CLASE COMENTADA - Ya no se usa _PostOptionTile
/*
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
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
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
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/// Widget para mostrar un anuncio publicitario en el feed
class _AdvertisementCard extends StatelessWidget {
  final AdvertisementEntity advertisement;

  const _AdvertisementCard({required this.advertisement});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: ColorTokens.secondary50.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showAdvertisementModal(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Etiqueta de "Anuncio"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ColorTokens.secondary50.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.campaign,
                    size: 14,
                    color: ColorTokens.secondary50,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Anuncio publicitario',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColorTokens.secondary50,
                    ),
                  ),
                  if (advertisement.advertiserName != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '• ${advertisement.advertiserName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorTokens.secondary50.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Imagen del anuncio
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Image.network(
                    advertisement.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: theme.iconTheme.color?.withValues(
                              alpha: 0.5,
                            ),
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Contenido del anuncio
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    advertisement.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    advertisement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Botón CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.secondary50,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _handleAdvertisementAction(context),
                      child: Text(
                        advertisement.callToActionText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un modal expandido con los detalles del anuncio
  void _showAdvertisementModal(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            // Handle del modal
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen expandida
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Image.network(
                          advertisement.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: theme.iconTheme.color?.withValues(
                                    alpha: 0.5,
                                  ),
                                  size: 64,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Contenido textual
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Marca del anunciante
                          if (advertisement.advertiserName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                advertisement.advertiserName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ColorTokens.secondary50,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                          // Título
                          Text(
                            advertisement.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.headlineSmall?.color,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Descripción completa
                          Text(
                            advertisement.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Botón CTA expandido
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorTokens.secondary50,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _handleAdvertisementAction(context);
                              },
                              child: Text(
                                advertisement.callToActionText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botón de cerrar
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    theme.textTheme.bodyMedium?.color,
                                side: BorderSide(
                                  color: theme.dividerColor,
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cerrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maneja la acción del botón CTA del anuncio
  void _handleAdvertisementAction(BuildContext context) async {
    try {
      if (advertisement.callToActionUrl != null &&
          advertisement.callToActionUrl!.isNotEmpty) {
        final uri = Uri.parse(advertisement.callToActionUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir el enlace del anuncio'),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Enlace no disponible')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
