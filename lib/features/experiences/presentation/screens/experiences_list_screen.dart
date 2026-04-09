import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/entities/advertisement_entity.dart';
import 'package:biux/features/experiences/presentation/widgets/experiences_stories_widget.dart';
import 'package:biux/features/experiences/presentation/screens/create_experience_screen.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/features/social/presentation/widgets/post_social_actions.dart';
import 'package:biux/features/social/presentation/providers/likes_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/shared/widgets/post_card.dart';
import 'package:biux/features/social/presentation/widgets/report_content_dialog.dart';
import 'package:biux/shared/widgets/shimmer_loading.dart';

/// Pantalla principal para mostrar la lista de experiencias
class ExperiencesListScreen extends StatefulWidget {
  const ExperiencesListScreen({super.key});

  @override
  State<ExperiencesListScreen> createState() => _ExperiencesListScreenState();
}

class _ExperiencesListScreenState extends State<ExperiencesListScreen>
    with WidgetsBindingObserver {
  Timer? _autoRefreshTimer;
  Timer? _fabTimer;
  late final ExperienceProvider _experienceProvider;
  bool _showFab = true;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _experienceProvider = context.read<ExperienceProvider>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    _fabTimer?.cancel();
    _experienceProvider.stopFeedListener();
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
      _experienceProvider.stopFeedListener();
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
      final provider = context.read<ExperienceProvider>();
      await provider.loadPersonalizedFeed(userId);
      provider.loadMyReposts(userId);
      // Cargar grupos que sigue el usuario
      context.read<GroupProvider>().loadUserGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo is ScrollUpdateNotification) {
            if (_showFab) setState(() => _showFab = false);
            _fabTimer?.cancel();
            _fabTimer = Timer(const Duration(milliseconds: 800), () {
              if (mounted) setState(() => _showFab = true);
            });
          }
          if (scrollInfo is ScrollEndNotification) {
            _fabTimer?.cancel();
            if (!_showFab && mounted) setState(() => _showFab = true);
          }
          return false;
        },
        child: Consumer<ExperienceProvider>(
          builder: (context, provider, child) {
            return _buildBody(provider);
          },
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _showFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => const CreateExperienceScreen(
                      experienceType: ExperienceType.general,
                      isPostMode: true,
                      textOnly: false,
                    ),
                  ),
                )
                .then((result) {
                  if (result == true) {
                    _loadFeed();
                  }
                });
          },
          backgroundColor: ColorTokens.primary30,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody(ExperienceProvider provider) {
    if (provider.isLoading) {
      return const ShimmerListLoading(itemHeight: 120);
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

    // Layout tipo Instagram: Stories arriba, publicaciones abajo — todo en un scroll
    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: posts.isEmpty
          ? _buildEmptyStateInLayout()
          : _buildExperiencesList(posts),
    );
  }

  Widget _buildErrorState(String error, ExperienceProvider provider) {
    final theme = Theme.of(context);
    final l = Provider.of<LocaleNotifier>(context, listen: false);

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
            l.t('experiences_error_loading'),
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
            child: Text(l.t('retry')),
          ),
        ],
      ),
    );
  }

  /// Estado vacío cuando no hay posts pero sí hay stories
  Widget _buildEmptyStateInLayout() {
    final theme = Theme.of(context);
    final l = Provider.of<LocaleNotifier>(context, listen: false);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const ExperiencesStoriesWidget(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
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
                    l.t('experiences_share_first_post'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.t('empty_no_posts_desc'),
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
        ],
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
        physics: const AlwaysScrollableScrollPhysics(),
        // +1 para el widget de historias al inicio, +1 para el loader al final
        itemCount: 1 + intercaledList.length + (provider.hasMorePosts ? 1 : 0),
        itemBuilder: (context, index) {
          // Primer ítem: sección de historias
          if (index == 0) {
            return const ExperiencesStoriesWidget();
          }

          final itemIndex = index - 1;

          // Mostrar post normal o anuncio
          if (itemIndex < intercaledList.length) {
            final item = intercaledList[itemIndex];

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
    final l = Provider.of<LocaleNotifier>(context, listen: false);

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
              l.t('experiences_create_post'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('experiences_choose_post_type'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostCard(
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
            headerSubtitle: experience.isRepost
                ? _RepostBanner(
                    userName:
                        (experience.originalAuthorUserName?.isNotEmpty == true)
                        ? experience.originalAuthorUserName!
                        : 'usuario',
                    authorId: experience.originalAuthorId,
                    currentUserId: currentUserId,
                  )
                : null,
            onUserTap: () {
              if (experience.user.id.isNotEmpty) {
                if (currentUserId == experience.user.id) {
                  context.push('/profile');
                } else {
                  context.push('/user-profile/${experience.user.id}');
                }
              }
            },
            // Sin onImageTap: zoom directo en la galería estilo Instagram
            onDoubleTap: () {
              // Doble-tap = like (estilo Instagram)
              final likesProvider = context.read<LikesProvider>();
              likesProvider.likePost(
                postId: experience.id,
                postOwnerId: experience.user.id,
                postPreview: experience.description.length > 50
                    ? experience.description.substring(0, 50)
                    : experience.description,
              );
            },
            headerTrailing: [
              GestureDetector(
                onTap: () => _showPostMenu(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).iconTheme.color ?? Colors.grey,
                    size: 22,
                  ),
                ),
              ),
            ],
            actionsWidget: Builder(
              builder: (ctx) {
                final provider = ctx.watch<ExperienceProvider>();
                final uid = FirebaseAuth.instance.currentUser?.uid;
                final isOwner = uid == experience.user.id;
                // Es repost propio (el item en sí es un repost del usuario)
                final isMyOwnRepost = experience.isRepost && isOwner;
                // El usuario reposteó este post original
                final hasRepostedOriginal = provider.hasRepostedPost(
                  experience.id,
                );
                final isReposted = isMyOwnRepost || hasRepostedOriginal;
                // No mostrar botón de repost para posts propios que NO son reposts
                final showRepostButton = !(isOwner && !experience.isRepost);

                return PostSocialActions(
                  postId: experience.id,
                  postOwnerId: experience.user.id,
                  postPreview: experience.description.length > 50
                      ? experience.description.substring(0, 50)
                      : experience.description,
                  isReposted: isReposted,
                  onRepost: showRepostButton && !isReposted
                      ? () => _repostPost(context)
                      : null,
                  onUnrepost: showRepostButton && isReposted
                      ? () async {
                          try {
                            if (isMyOwnRepost) {
                              // Eliminar el repost directamente
                              await provider.deleteExperience(experience.id);
                            } else {
                              await provider.removeRepost(experience.id);
                            }
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text('Reposteo eliminado'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (_) {}
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '~';
    }
  }

  void _showPostMenu(BuildContext context) {
    final theme = Theme.of(context);
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
                title: Text(
                  l.t('delete_post'),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: theme.iconTheme.color),
                title: Text(
                  l.t('edit_post'),
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
            ],
            if (!isOwner)
              ListTile(
                leading: Icon(Icons.flag, color: theme.iconTheme.color),
                title: Text(
                  l.t('report_post'),
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ReportContentDialog.show(
                    context: context,
                    contentId: experience.id,
                    contentOwnerId: experience.user.id,
                    contentType: 'post',
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.share, color: theme.iconTheme.color),
              title: Text(
                l.t('share'),
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

  void _repostPost(BuildContext context) async {
    final theme = Theme.of(context);
    final captionController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        title: const Text('Repostear publicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'De @${experience.user.userName.isNotEmpty ? experience.user.userName : experience.user.fullName}',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: captionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Añade un comentario (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Repostear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    try {
      final provider = context.read<ExperienceProvider>();
      await provider.repostStory(
        experience,
        caption: captionController.text.trim(),
      );
      // Recargar mapa de reposts para que el botón refleje estado actual
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && context.mounted) {
        provider.loadMyReposts(uid);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicación reposteada!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al repostear: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    final l = Provider.of<LocaleNotifier>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        title: Text(
          l.t('delete_post_confirm'),
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: Text(
          l.t('delete_post_content'),
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(context);
            },
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );
  }

  void _deletePost(BuildContext context) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      final provider = context.read<ExperienceProvider>();
      await provider.deleteExperience(experience.id);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.t('post_deleted_success'))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l.t('error_generic')}: $e')));
      }
    }
  }

  void _sharePost(BuildContext context) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      // En lugar de compartir un link, abrir la app directamente con deep link
      final deepLink = 'biux://posts/${experience.id}';
      await launchUrl(
        Uri.parse(deepLink),
        mode: LaunchMode.externalApplication,
      ).catchError((e) {
        // Fallback: si el deep link falla, mostrar mensaje
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.t('error_generic'))));
        }
        return false;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l.t('error_generic')}: $e')));
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

/// Banner de repost que se muestra debajo del chip de usuario en el PostCard
class _RepostBanner extends StatelessWidget {
  final String userName;
  final String? authorId;
  final String? currentUserId;

  const _RepostBanner({
    required this.userName,
    required this.authorId,
    required this.currentUserId,
  });

  Future<void> _navigate(BuildContext context) async {
    if (authorId != null && authorId!.isNotEmpty) {
      if (currentUserId == authorId) {
        context.push('/profile');
      } else {
        context.push('/user-profile/$authorId');
      }
    } else {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where('userName', isEqualTo: userName)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty && context.mounted) {
          final foundId =
              snap.docs.first.data()['id'] as String? ?? snap.docs.first.id;
          if (currentUserId == foundId) {
            context.push('/profile');
          } else {
            context.push('/user-profile/$foundId');
          }
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.repeat_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'Reposteado de @$userName',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar un anuncio publicitario en el feed
class _AdvertisementCard extends StatelessWidget {
  final AdvertisementEntity advertisement;

  const _AdvertisementCard({required this.advertisement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = Provider.of<LocaleNotifier>(context, listen: false);

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
                    l.t('ad_label'),
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
    final theme = Theme.of(context);
    final l = Provider.of<LocaleNotifier>(context, listen: false);

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
                              child: Text(
                                l.t('close'),
                                style: const TextStyle(
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      if (advertisement.callToActionUrl != null &&
          advertisement.callToActionUrl!.isNotEmpty) {
        final uri = Uri.parse(advertisement.callToActionUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l.t('error_generic'))));
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.t('error_generic'))));
        }
      }
    } catch (e) {
      if (context.mounted) {
        final l = Provider.of<LocaleNotifier>(context, listen: false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l.t('error_generic')}: $e')));
      }
    }
  }
}
