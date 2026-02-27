import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/experiences/presentation/providers/experience_classic_provider.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTokens.neutral100),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              context.read<UserProfileProvider>().loadUserProfile(
                widget.userId,
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.read<UserProfileProvider>().currentProfile !=
                    null) {
                  _shareProfile(
                    context.read<UserProfileProvider>().currentProfile!,
                  );
                }
              });
            },
            tooltip: 'Compartir perfil',
          ),
        ],
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
                          // Primera fila: Espacio izquierda y botón Seguir derecha
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 24),
                              // Botón Seguir (para otros perfiles)
                              _buildFollowButton(provider, user.id),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Segunda fila: Foto + Nombre/Usuario
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
                          color: ColorTokens.primary30,
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

  Widget _buildPublicationsSection(BiuxUser user) {
    return FutureBuilder(
      future: ExperienceRepositoryImpl().getUserExperiences(widget.userId),
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

        // Mostrar grid de publicaciones
        final experiences = snapshot.data as dynamic;
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
                    // Imagen de la experiencia
                    experience.media.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: experience.media.first.url,
                            fit: BoxFit.cover,
                            cacheManager: OptimizedCacheManager.instance,
                            placeholder: (context, url) => Container(
                              color: ColorTokens.neutral20,
                              child: Center(
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorTokens.primary30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: ColorTokens.neutral20,
                              child: Icon(
                                Icons.image_not_supported,
                                color: ColorTokens.neutral60,
                              ),
                            ),
                          )
                        : Container(
                            color: ColorTokens.neutral20,
                            child: Icon(
                              Icons.image,
                              color: ColorTokens.neutral60,
                            ),
                          ),
                    // Overlay oscuro
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ),
                    // Título de la experiencia
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        experience.description ?? '',
                        style: TextStyle(
                          color: ColorTokens.neutral100,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              color: ColorTokens.neutral10,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorTokens.neutral20,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seguidores (${user.followerS})',
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
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: user.followers.length,
                      itemBuilder: (context, index) {
                        final followerId = user.followers.keys.toList()[index];
                        return Container(
                          color: ColorTokens.neutral10,
                          child: ListTile(
                            title: Text(
                              followerId,
                              style: TextStyle(color: ColorTokens.neutral100),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: ColorTokens.neutral80,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/user-profile/$followerId');
                            },
                          ),
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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              color: ColorTokens.neutral10,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorTokens.neutral20,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Siguiendo (${user.following.length})',
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
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: user.following.length,
                      itemBuilder: (context, index) {
                        final followingId = user.following[index];
                        return Container(
                          color: ColorTokens.neutral10,
                          child: ListTile(
                            title: Text(
                              followingId,
                              style: TextStyle(color: ColorTokens.neutral100),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: ColorTokens.neutral80,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/user-profile/$followingId');
                            },
                          ),
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
