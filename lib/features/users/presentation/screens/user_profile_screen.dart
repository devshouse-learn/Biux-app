import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _failedImageIds = {};
  late final Future<dynamic> _experiencesFuture;
  int _postCount = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _experiencesFuture = ExperienceRepositoryImpl().getUserExperiences(
      widget.userId,
    );

    // Cargar perfil del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadUserProfile(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTokens.neutral100),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingProfile) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorTokens.primary30,
                ),
              ),
            );
          }

          if (provider.currentProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: ColorTokens.neutral60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No se pudo cargar el perfil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral80,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Verifica tu conexión e intenta nuevamente',
                    style: TextStyle(color: ColorTokens.neutral60),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadUserProfile(widget.userId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                      foregroundColor: ColorTokens.neutral100,
                    ),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final user = provider.currentProfile!;
          return SingleChildScrollView(
            child: Column(
              children: [
                // ========== SECCIÓN DE PERFIL TIPO INSTAGRAM ==========
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorTokens.primary30,
                        ColorTokens.primary30.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: Column(
                        children: [
                          // Primera fila: Botones izquierda y Compartir + Seguir derecha
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Menú izquierdo: Story + Post (solo si es el usuario actual)
                              if (AuthenticationRepository().getUserId ==
                                  user.id)
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: ColorTokens.neutral100,
                                    size: 24,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'story') {
                                      context.go('/create-story');
                                    } else if (value == 'post') {
                                      context.go('/experiences/create');
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'story',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text('Agregar Historia'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'post',
                                      child: Row(
                                        children: [
                                          Icon(Icons.image_search, size: 20),
                                          SizedBox(width: 10),
                                          Text('Nueva Publicación'),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                SizedBox(
                                  width: 24,
                                ), // Espacio cuando no es el usuario actual
                              // Botones derechos: Seguir/Editar
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (AuthenticationRepository().getUserId ==
                                      user.id)
                                    Tooltip(
                                      message: 'Editar perfil',
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: ColorTokens.neutral100,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          // Navegar a editar perfil
                                          context.go('/edit-profile');
                                        },
                                        constraints: BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    )
                                  else
                                    SizedBox(width: 8),
                                  if (AuthenticationRepository().getUserId ==
                                      user.id)
                                    Tooltip(
                                      message: 'Configuración',
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.settings_outlined,
                                          color: ColorTokens.neutral100,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          context.go('/account-settings');
                                        },
                                        constraints: BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Segunda fila: Foto + Nombre/Usuario + Botón Seguir (si es otro usuario)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Foto
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorTokens.neutral100,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: ColorTokens.neutral20,
                                  backgroundImage: user.photo.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          user.photo,
                                          cacheManager: OptimizedCacheManager
                                              .avatarInstance,
                                        )
                                      : null,
                                  child: user.photo.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 40,
                                          color: ColorTokens.neutral60,
                                        )
                                      : null,
                                ),
                              ),
                              SizedBox(width: 16),

                              // Nombre y usuario
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName
                                          : 'Sin nombre',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ColorTokens.neutral100,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    if (user.userName.isNotEmpty)
                                      Text(
                                        '@${user.userName}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: ColorTokens.neutral100
                                              .withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),

                              // Botón Seguir (para otros perfiles, no para el usuario actual)
                              if (AuthenticationRepository().getUserId !=
                                  user.id)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: _buildFollowButton(provider, user.id),
                                ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Tercera fila: Estadísticas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    _postCount.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: ColorTokens.neutral100,
                                    ),
                                  ),
                                  Text(
                                    'Posts',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: ColorTokens.neutral100.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showFollowersModal(context, user);
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      user.followers.length.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: ColorTokens.neutral100,
                                      ),
                                    ),
                                    Text(
                                      'Seguidores',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: ColorTokens.neutral100
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showFollowingModal(context, user);
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      user.following.length.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: ColorTokens.neutral100,
                                      ),
                                    ),
                                    Text(
                                      'Siguiendo',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: ColorTokens.neutral100
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // Descripción
                          if (user.description.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                user.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ColorTokens.neutral100.withValues(
                                    alpha: 0.9,
                                  ),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // ========== SECCIÓN DE PUBLICACIONES ==========
                      Text(
                        'Publicaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ColorTokens.neutral100
                              : ColorTokens.primary30,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Mostrar publicaciones del usuario
                      _buildPublicationsSection(user),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowButton(
    UserProfileProvider provider,
    String profileUserId,
  ) {
    final currentUserId = AuthenticationRepository().getUserId;
    final isOwnProfile = currentUserId == profileUserId;

    // Si es el perfil propio, no mostrar botón de seguir
    if (isOwnProfile) {
      return SizedBox.shrink();
    }

    // Deshabilitar si está procesando
    final isDisabled = provider.isProcessingFollow;

    return SizedBox(
      width: 100,
      height: 36,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () async {
                if (provider.isFollowing) {
                  await provider.unfollowUser(profileUserId);
                } else {
                  await provider.followUser(profileUserId);
                }
              },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          backgroundColor: provider.isFollowing
              ? ColorTokens.neutral100.withValues(alpha: 0.2)
              : ColorTokens.neutral100,
          foregroundColor: provider.isFollowing
              ? ColorTokens.neutral100
              : ColorTokens.primary30,
          side: BorderSide(
            color: ColorTokens.neutral100,
            width: provider.isFollowing ? 1 : 0,
          ),
          disabledBackgroundColor: ColorTokens.neutral100.withValues(
            alpha: 0.5,
          ),
        ),
        child: provider.isProcessingFollow
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    provider.isFollowing
                        ? ColorTokens.neutral100
                        : ColorTokens.primary30,
                  ),
                ),
              )
            : Text(
                provider.isFollowing ? 'Siguiendo' : 'Seguir',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
      ),
    );
  }

  Widget _buildPublicationsSection(BiuxUser user) {
    return FutureBuilder(
      future: _experiencesFuture,
      builder: (context, snapshot) {
        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: ColorTokens.neutral10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorTokens.neutral30, width: 1),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorTokens.primary30,
                ),
              ),
            ),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: ColorTokens.neutral10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorTokens.neutral30, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: ColorTokens.error50),
                SizedBox(height: 12),
                Text(
                  'Error cargando publicaciones',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorTokens.error50,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Sin datos o lista vacía
        if (!snapshot.hasData ||
            snapshot.data == null ||
            (snapshot.data as dynamic).isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: ColorTokens.neutral10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorTokens.neutral30, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: ColorTokens.neutral60,
                ),
                SizedBox(height: 12),
                Text(
                  'Sin publicaciones aún',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorTokens.neutral70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Filtrar: solo PUBLICACIONES (no historias) con media válido
        final allExperiences = snapshot.data as dynamic;
        final experiences = allExperiences.where((exp) {
          // Excluir historias — solo publicaciones en el perfil
          if (exp.isStoryFormat == true) return false;
          try {
            if (exp.media == null || exp.media.isEmpty) return false;
            if (exp.media.first == null) return false;
            final media = exp.media.first;
            final url = media.url ?? '';
            if (url.isEmpty) return false;
            if (!url.startsWith('http://') && !url.startsWith('https://'))
              return false;
            // Para videos: validar que tenga thumbnail o URL válida
            if (media.mediaType == MediaType.video) {
              final thumb = media.thumbnailUrl ?? '';
              return thumb.isNotEmpty && thumb.startsWith('http') ||
                  url.isNotEmpty;
            }
            return true;
          } catch (e) {
            return false;
          }
        }).toList();

        // Eliminar publicaciones con imágenes que fallaron al cargar
        experiences.removeWhere(
          (exp) => _failedImageIds.contains(exp.id.toString()),
        );

        // Actualizar contador de posts
        if (_postCount != experiences.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _postCount = experiences.length);
          });
        }

        // Si después de filtrar no hay experiencias, mostrar el mensaje
        if (experiences.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: ColorTokens.neutral10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorTokens.neutral30, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: ColorTokens.neutral60,
                ),
                SizedBox(height: 12),
                Text(
                  'Sin publicaciones válidas',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorTokens.neutral70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Mostrar grid de publicaciones
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: experiences.length,
          itemBuilder: (context, index) {
            final experience = experiences[index];
            return GestureDetector(
              onTap: () {
                context.push('/stories/post/${experience.id}');
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorTokens.primary30, width: 1),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen/thumbnail de la experiencia optimizada
                    experience.media.isNotEmpty
                        ? Builder(
                            builder: (context) {
                              final media = experience.media.first;
                              final isVideo =
                                  media.mediaType == MediaType.video;
                              final displayUrl = isVideo
                                  ? (media.thumbnailUrl?.isNotEmpty == true
                                        ? media.thumbnailUrl!
                                        : media.url)
                                  : media.url;
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: displayUrl,
                                    fit: BoxFit.cover,
                                    cacheManager:
                                        OptimizedCacheManager.instance,
                                    memCacheWidth: 400,
                                    memCacheHeight: 400,
                                    fadeInDuration: const Duration(
                                      milliseconds: 100,
                                    ),
                                    fadeOutDuration: const Duration(
                                      milliseconds: 50,
                                    ),
                                    placeholder: (context, url) => Container(
                                      color: ColorTokens.neutral20,
                                      child: Center(
                                        child: Icon(
                                          isVideo
                                              ? Icons.videocam
                                              : Icons.image,
                                          color: ColorTokens.neutral60,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      final expId = experience.id.toString();
                                      if (!_failedImageIds.contains(expId)) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (mounted) {
                                                setState(() {
                                                  _failedImageIds.add(expId);
                                                });
                                              }
                                            });
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),
                                  if (isVideo)
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          )
                        : Container(
                            color: ColorTokens.neutral20,
                            child: Icon(
                              Icons.image,
                              color: ColorTokens.neutral60,
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFollowersModal(BuildContext context, BiuxUser user) {
    final provider = context.read<UserProfileProvider>();
    provider.loadFollowers(user.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: ColorTokens.neutral10,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorTokens.neutral20,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seguidores',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorTokens.neutral100,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: ColorTokens.neutral100,
                          ),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: provider,
                      builder: (context, _) {
                        if (provider.isLoadingFollowers) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorTokens.primary30,
                              ),
                            ),
                          );
                        }
                        if (provider.followers.isEmpty) {
                          return Center(
                            child: Text(
                              'Sin seguidores aún',
                              style: TextStyle(
                                color: ColorTokens.neutral60,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: provider.followers.length,
                          itemBuilder: (context, index) {
                            final follower = provider.followers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: ColorTokens.neutral20,
                                backgroundImage: follower.photo.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        follower.photo,
                                        cacheManager: OptimizedCacheManager
                                            .avatarInstance,
                                      )
                                    : null,
                                child: follower.photo.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 20,
                                        color: ColorTokens.neutral60,
                                      )
                                    : null,
                              ),
                              title: Text(
                                follower.fullName.isNotEmpty
                                    ? follower.fullName
                                    : 'Usuario',
                                style: TextStyle(
                                  color: ColorTokens.neutral100,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: follower.userName.isNotEmpty
                                  ? Text(
                                      '@${follower.userName}',
                                      style: TextStyle(
                                        color: ColorTokens.neutral60,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: ColorTokens.neutral60,
                              ),
                              onTap: () {
                                Navigator.pop(modalContext);
                                context.push('/user-profile/${follower.id}');
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFollowingModal(BuildContext context, BiuxUser user) {
    final provider = context.read<UserProfileProvider>();
    provider.loadFollowing(user.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: ColorTokens.neutral10,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorTokens.neutral20,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Siguiendo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorTokens.neutral100,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: ColorTokens.neutral100,
                          ),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: provider,
                      builder: (context, _) {
                        if (provider.isLoadingFollowing) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorTokens.primary30,
                              ),
                            ),
                          );
                        }
                        if (provider.following.isEmpty) {
                          return Center(
                            child: Text(
                              'No sigue a nadie aún',
                              style: TextStyle(
                                color: ColorTokens.neutral60,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: provider.following.length,
                          itemBuilder: (context, index) {
                            final followingUser = provider.following[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: ColorTokens.neutral20,
                                backgroundImage: followingUser.photo.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        followingUser.photo,
                                        cacheManager: OptimizedCacheManager
                                            .avatarInstance,
                                      )
                                    : null,
                                child: followingUser.photo.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 20,
                                        color: ColorTokens.neutral60,
                                      )
                                    : null,
                              ),
                              title: Text(
                                followingUser.fullName.isNotEmpty
                                    ? followingUser.fullName
                                    : 'Usuario',
                                style: TextStyle(
                                  color: ColorTokens.neutral100,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: followingUser.userName.isNotEmpty
                                  ? Text(
                                      '@${followingUser.userName}',
                                      style: TextStyle(
                                        color: ColorTokens.neutral60,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: ColorTokens.neutral60,
                              ),
                              onTap: () {
                                Navigator.pop(modalContext);
                                context.push(
                                  '/user-profile/${followingUser.id}',
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Método para compartir el perfil del usuario
  // ignore: unused_element
  Future<void> _shareProfile(BiuxUser user) async {
    try {
      final userName = user.userName.isNotEmpty ? user.userName : user.fullName;
      final shareUrl = 'https://biux.devshouse.org/user/${user.id}';

      final shareText = '🚴 Mira el perfil de $userName en Biux\n\n$shareUrl';

      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (e) {
      debugPrint('Error al compartir perfil: $e');
    }
  }
}

// ignore: unused_element
class _UserListItem extends StatelessWidget {
  final BiuxUser user;
  final VoidCallback onTap;

  const _UserListItem({Key? key, required this.user, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ColorTokens.neutral20,
          backgroundImage: user.photo.isNotEmpty
              ? CachedNetworkImageProvider(
                  user.photo,
                  cacheManager: OptimizedCacheManager.avatarInstance,
                )
              : null,
          child: user.photo.isEmpty
              ? Icon(Icons.person, color: ColorTokens.neutral60)
              : null,
        ),
        title: Text(
          user.fullName.isNotEmpty ? user.fullName : l.t('no_name'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: user.userName.isNotEmpty ? Text('@${user.userName}') : null,
        onTap: onTap,
      ),
    );
  }
}
