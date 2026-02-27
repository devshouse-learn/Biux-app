import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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
      backgroundColor: ColorTokens.neutral100,
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingProfile) {
            return _buildLoadingState();
          }

          if (provider.currentProfile == null) {
            return _buildErrorState();
          }

          return _buildProfileContent(provider.currentProfile!, provider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
      ),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary30),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: ColorTokens.neutral60),
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
                context.read<UserProfileProvider>().loadUserProfile(
                  widget.userId,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
              ),
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BiuxUser user, UserProfileProvider provider) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            backgroundColor: ColorTokens.primary30,
            foregroundColor: ColorTokens.neutral100,
            expandedHeight: 220,
            pinned: true,
            actions: [
              // Botón de compartir perfil
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareProfile(user),
                tooltip: 'Compartir perfil',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(user, provider),
            ),
          ),
        ];
      },
      body: Column(
        children: [
          // Tabs
          Container(
            color: ColorTokens.neutral100,
            child: TabBar(
              controller: _tabController,
              labelColor: ColorTokens.primary30,
              unselectedLabelColor: ColorTokens.neutral60,
              indicatorColor: ColorTokens.primary30,
              tabs: [
                Tab(text: 'Publicaciones'),
                Tab(text: 'Seguidores'),
                Tab(text: 'Siguiendo'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsTab(user),
                _buildFollowersTab(user, provider),
                _buildFollowingTab(user, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BiuxUser user, UserProfileProvider provider) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnProfile = currentUserId == user.id;

    return Container(
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
          padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              // Primera fila: menú(izq) + foto + nombre/username + controles(der)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menú izquierdo: Story + Post (solo si es perfil propio)
                  if (isOwnProfile)
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
                          context.go('/create-post');
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'story',
                          child: Row(
                            children: [
                              Icon(Icons.add_photo_alternate, size: 20),
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
                    ), // Espaciador cuando no es perfil propio
                  // Foto de perfil y nombre/username - Centro
                  Expanded(
                    child: Row(
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
                            radius: 32,
                            backgroundColor: ColorTokens.neutral20,
                            backgroundImage: user.photo.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    user.photo,
                                    cacheManager:
                                        OptimizedCacheManager.avatarInstance,
                                  )
                                : null,
                            child: user.photo.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 32,
                                    color: ColorTokens.neutral60,
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(width: 12),

                        // Nombre y username
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName
                                    : 'Sin nombre',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ColorTokens.neutral100,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              if (user.userName.isNotEmpty)
                                Text(
                                  '@${user.userName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ColorTokens.neutral100.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botones derechos
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOwnProfile) ...[
                        // Editar + Configuración (solo para perfil propio)
                        Tooltip(
                          message: 'Editar perfil',
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: ColorTokens.neutral100,
                              size: 20,
                            ),
                            onPressed: () {
                              // Mostrar opciones de editar perfil
                              showModalBottomSheet(
                                context: context,
                                builder: (ctx) => Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Editar perfil'),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          context.go('/profile');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
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
                      ] else
                        // Botón Seguir (para otros perfiles)
                        _buildFollowButton(provider, user.id),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Segunda fila: Estadísticas - Ancho completo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '0',
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
                          color: ColorTokens.neutral100.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        user.followerS.toString(),
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
                          color: ColorTokens.neutral100.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  Column(
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
                          color: ColorTokens.neutral100.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Descripción - Debajo de la foto, alineada a izquierda
              if (user.description.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    user.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: ColorTokens.neutral100.withValues(alpha: 0.9),
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
    );
  }

  Widget _buildFollowButton(
    UserProfileProvider provider,
    String profileUserId,
  ) {
    final currentUserId = AuthenticationRepository().getUserId;
    final isOwnProfile = currentUserId == profileUserId;

    // Si es el perfil propio, mostrar botón "Editar perfil"
    if (isOwnProfile) {
      return ElevatedButton(
        onPressed: () {
          // Navegar a la pantalla de editar perfil
          context.go('/profile');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTokens.neutral100,
          foregroundColor: ColorTokens.primary30,
        ),
        child: Text(
          'Editar perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    // Deshabilitar si está procesando o si ya sigue
    final isDisabled = provider.isProcessingFollow || provider.isFollowing;

    return ElevatedButton(
      onPressed: isDisabled
          ? null
          : () async {
              await provider.followUser(profileUserId);
            },
      style: ElevatedButton.styleFrom(
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
      ),
      child: provider.isProcessingFollow
          ? SizedBox(
              width: 16,
              height: 16,
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildPostsTab(BiuxUser user) {
    return Consumer<ExperienceProvider>(
      builder: (context, expProvider, child) {
        // Cargar experiencias del usuario si no están cargadas
        if (expProvider.userExperiences.isEmpty && !expProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            expProvider.loadUserExperiences(widget.userId);
          });
        }

        if (expProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary30),
            ),
          );
        }

        // Filtrar experiencias con media (fotos/videos)
        final experiencesWithMedia = expProvider.userExperiences
            .where((exp) => exp.media.isNotEmpty)
            .toList();

        if (experiencesWithMedia.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: ColorTokens.neutral60,
                ),
                SizedBox(height: 16),
                Text(
                  'Sin publicaciones aún',
                  style: TextStyle(fontSize: 16, color: ColorTokens.neutral60),
                ),
              ],
            ),
          );
        }

        // Obtener todas las URLs de media
        final List<String> allMediaUrls = [];
        for (var exp in experiencesWithMedia) {
          allMediaUrls.addAll(exp.media.map((m) => m.url));
        }

        // Mostrar grid de fotos
        return GridView.builder(
          padding: EdgeInsets.all(2),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: allMediaUrls.length,
          itemBuilder: (context, index) {
            final mediaUrl = allMediaUrls[index];
            return GestureDetector(
              onTap: () {
                // Ir al detalle de la experiencia
                final experience = experiencesWithMedia.firstWhere(
                  (exp) => exp.media.any((m) => m.url == mediaUrl),
                );
                // Navegar según el tipo
                if (experience.isStoryFormat) {
                  // TODO: Navegar a vista de historia
                  context.push('/stories');
                } else {
                  // TODO: Navegar a vista de post
                  context.push('/stories');
                }
              },
              child: CachedNetworkImage(
                imageUrl: mediaUrl,
                cacheManager: OptimizedCacheManager.instance,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: ColorTokens.neutral20,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColorTokens.primary30,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: ColorTokens.neutral20,
                  child: Icon(
                    Icons.error_outline,
                    color: ColorTokens.neutral60,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFollowersTab(BiuxUser user, UserProfileProvider provider) {
    // Cargar followers si no están cargados
    if (provider.followers.isEmpty && !provider.isLoadingFollowers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadFollowers(widget.userId);
      });
    }

    if (provider.isLoadingFollowers) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary30),
        ),
      );
    }

    if (provider.followers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: ColorTokens.neutral60),
            SizedBox(height: 16),
            Text(
              'Sin seguidores aún',
              style: TextStyle(fontSize: 16, color: ColorTokens.neutral60),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.followers.length,
      itemBuilder: (context, index) {
        final follower = provider.followers[index];
        return _UserListItem(
          user: follower,
          onTap: () {
            context.push('/user-profile/${follower.id}');
          },
        );
      },
    );
  }

  Widget _buildFollowingTab(BiuxUser user, UserProfileProvider provider) {
    // Cargar following si no están cargados
    if (provider.following.isEmpty && !provider.isLoadingFollowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadFollowing(widget.userId);
      });
    }

    if (provider.isLoadingFollowing) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary30),
        ),
      );
    }

    if (provider.following.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: ColorTokens.neutral60,
            ),
            SizedBox(height: 16),
            Text(
              'No sigue a nadie aún',
              style: TextStyle(fontSize: 16, color: ColorTokens.neutral60),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.following.length,
      itemBuilder: (context, index) {
        final following = provider.following[index];
        return _UserListItem(
          user: following,
          onTap: () {
            context.push('/user-profile/${following.id}');
          },
        );
      },
    );
  }

  // Método para compartir el perfil del usuario
  Future<void> _shareProfile(BiuxUser user) async {
    try {
      final userName = user.userName.isNotEmpty ? user.userName : user.fullName;
      final shareUrl = 'https://biux.devshouse.org/user/${user.id}';

      final shareText = '🚴 Mira el perfil de $userName en Biux\n\n$shareUrl';

      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (e) {
      print('Error al compartir perfil: $e');
    }
  }
}

class _UserListItem extends StatelessWidget {
  final BiuxUser user;
  final VoidCallback onTap;

  const _UserListItem({Key? key, required this.user, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          user.fullName.isNotEmpty ? user.fullName : 'Sin nombre',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: user.userName.isNotEmpty ? Text('@${user.userName}') : null,
        onTap: onTap,
      ),
    );
  }
}
