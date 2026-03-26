import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';

/// Pantalla de perfil p├║blico de usuario
/// Muestra informaci├│n b├ísica, posts y bot├│n de seguir/dejar de seguir
class PublicUserProfileScreen extends StatefulWidget {
  final String userId;

  const PublicUserProfileScreen({super.key, required this.userId});

  @override
  State<PublicUserProfileScreen> createState() =>
      _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context, listen: false);
  bool isFollowing = false;
  bool isCurrentUser = false;

  @override
  void initState() {
    super.initState();

    // Cargar datos del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadUserProfile(widget.userId);

      // Verificar si es el usuario actual
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      setState(() {
        isCurrentUser = currentUserUid == widget.userId;
      });

      // Verificar si ya est├í siguiendo a este usuario
      if (!isCurrentUser && currentUserUid != null) {
        final userProvider = context.read<UserProvider>();
        if (userProvider.user?.following != null) {
          setState(() {
            isFollowing = userProvider.user!.following!.containsKey(
              widget.userId,
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorTokens.primary50),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: ColorTokens.error50),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar el perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.neutral90,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorTokens.neutral70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary50,
                    foregroundColor: ColorTokens.neutral100,
                  ),
                  child: const Text('Volver'),
                ),
              ],
            ),
          );
        }

        final user = provider.currentUser;
        if (user == null) {
          return Center(
            child: Text(
              'Usuario no encontrado',
              style: TextStyle(fontSize: 18, color: ColorTokens.neutral70),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // ========== SECCIÓN DE PERFIL (misma estructura que mi perfil) ==========
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
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    children: [
                      SizedBox(height: 8),

                      // Fila: Foto + Nombre/Usuario
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Foto de perfil
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
                                  ? NetworkImage(user.photo)
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
                                      : (user.userName.isNotEmpty
                                            ? user.userName
                                            : 'Usuario sin nombre'),
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

                      SizedBox(height: 16),

                      // Estadísticas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${provider.userPosts.length}',
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
                            onTap: () => _showFollowersModal(context, provider),
                            child: Column(
                              children: [
                                Text(
                                  '${provider.followersCount}',
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
                                    color: ColorTokens.neutral100.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showFollowingModal(context, provider),
                            child: Column(
                              children: [
                                Text(
                                  '${provider.followingCount}',
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
                                    color: ColorTokens.neutral100.withValues(
                                      alpha: 0.8,
                                    ),
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

                      SizedBox(height: 12),

                      // Botón de Seguir (solo si no es el usuario actual)
                      if (!isCurrentUser)
                        SizedBox(
                          width: double.infinity,
                          child: _buildFollowButton(provider, widget.userId),
                        ),
                    ],
                  ),
                ),
              ),

              // ========== CONTENIDO: Posts o Muro Privado ==========
              if (provider.isPrivateAccount &&
                  !provider.isFollowing &&
                  AuthenticationRepository().getUserId != widget.userId)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildPrivateAccountWall(),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
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
                      _buildPostsGrid(provider),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostsGrid(UserProfileProvider provider) {
    final validPosts = provider.userPosts.where((post) {
      try {
        if (post.media == null || post.media.isEmpty) return false;
        if (post.media.first == null) return false;
        final url = post.media.first.url ?? '';
        if (url.isEmpty) return false;
        if (!url.startsWith('http://') && !url.startsWith('https://'))
          return false;
        return true;
      } catch (e) {
        return false;
      }
    }).toList();

    if (validPosts.isEmpty) {
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

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: validPosts.length,
      itemBuilder: (context, index) {
        final post = validPosts[index];
        return GestureDetector(
          onTap: () {
            context.push('/stories/post/${post.id}');
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorTokens.primary30, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.media.first.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: ColorTokens.neutral30,
                    child: const Icon(
                      Icons.image,
                      color: ColorTokens.neutral60,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowButton(
    UserProfileProvider provider,
    String profileUserId,
  ) {
    final currentUserId = AuthenticationRepository().getUserId;
    final isOwnProfile = currentUserId == profileUserId;

    // Si es el perfil propio, no mostrar bot├│n de seguir
    if (isOwnProfile) {
      return SizedBox.shrink();
    }

    // Deshabilitar si est├í procesando
    final isDisabled = provider.isProcessingFollow;

    // Determinar estado: following, requested, or follow
    final isFollowing = provider.isFollowing;
    final hasPendingRequest = provider.hasPendingFollowRequest;

    String buttonLabel;
    if (isFollowing) {
      buttonLabel = l.t('following');
    } else if (hasPendingRequest) {
      buttonLabel = l.t('requested');
    } else {
      buttonLabel = l.t('follow');
    }

    return SizedBox(
      width: 100,
      height: 36,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () async {
                if (isFollowing) {
                  await provider.unfollowUser(profileUserId);
                } else if (hasPendingRequest) {
                  // Cancelar solicitud pendiente
                  await provider.cancelFollowRequest(profileUserId);
                } else {
                  // Seguir (o enviar solicitud si es privado)
                  await provider.followUser(profileUserId);
                }
              },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          backgroundColor: (isFollowing || hasPendingRequest)
              ? ColorTokens.neutral100.withValues(alpha: 0.2)
              : ColorTokens.neutral100,
          foregroundColor: (isFollowing || hasPendingRequest)
              ? ColorTokens.neutral100
              : ColorTokens.primary30,
          side: BorderSide(
            color: ColorTokens.neutral100,
            width: (isFollowing || hasPendingRequest) ? 1 : 0,
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
                    (isFollowing || hasPendingRequest)
                        ? ColorTokens.neutral100
                        : ColorTokens.primary30,
                  ),
                ),
              )
            : Text(
                buttonLabel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
      ),
    );
  }

  Widget _buildPrivateAccountWall() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? ColorTokens.primary30.withValues(alpha: 0.3)
            : ColorTokens.neutral10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? ColorTokens.neutral60.withValues(alpha: 0.3)
              : ColorTokens.neutral30,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: isDark ? ColorTokens.neutral60 : ColorTokens.neutral70,
          ),
          SizedBox(height: 16),
          Text(
            l.t('this_account_is_private'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? ColorTokens.neutral100 : ColorTokens.neutral80,
            ),
          ),
          SizedBox(height: 8),
          Text(
            l.t('follow_to_see_posts'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? ColorTokens.neutral60 : ColorTokens.neutral60,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowersModal(BuildContext context, UserProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<void>(
          future: provider.loadFollowers(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(color: ColorTokens.primary50),
                      SizedBox(height: 12),
                      Text('Cargando seguidores...'),
                    ],
                  ),
                ),
              );
            }

            final followers = provider.followers;
            if (followers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: ColorTokens.neutral60,
                      ),
                      const SizedBox(height: 12),
                      const Text('Sin seguidores a├║n'),
                    ],
                  ),
                ),
              );
            }

            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Seguidores (${followers.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...followers.map((user) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photo.isNotEmpty
                              ? NetworkImage(user.photo)
                              : null,
                          child: user.photo.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName
                              : user.userName,
                        ),
                        subtitle: Text('@${user.userName}'),
                        onTap: () {
                          context.pop();
                          context.push('/user-profile/${user.id}');
                        },
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showFollowingModal(BuildContext context, UserProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<void>(
          future: provider.loadFollowing(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(color: ColorTokens.primary50),
                      SizedBox(height: 12),
                      Text('Cargando seguidos...'),
                    ],
                  ),
                ),
              );
            }

            final following = provider.following;
            if (following.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: ColorTokens.neutral60,
                      ),
                      const SizedBox(height: 12),
                      const Text('No sigue a nadie a├║n'),
                    ],
                  ),
                ),
              );
            }

            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Siguiendo (${following.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...following.map((user) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photo.isNotEmpty
                              ? NetworkImage(user.photo)
                              : null,
                          child: user.photo.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName
                              : user.userName,
                        ),
                        subtitle: Text('@${user.userName}'),
                        onTap: () {
                          context.pop();
                          context.push('/user-profile/${user.id}');
                        },
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
