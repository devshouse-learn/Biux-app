import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';

/// Pantalla de perfil público de usuario
/// Muestra información básica y posts (botón de seguir removido)
class PublicUserProfileScreen extends StatefulWidget {
  final String userId;

  const PublicUserProfileScreen({super.key, required this.userId});

  @override
  State<PublicUserProfileScreen> createState() =>
      _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar datos del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadUserProfile(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Scaffold(
              backgroundColor: ColorTokens.neutral10,
              body: Center(
                child: CircularProgressIndicator(color: ColorTokens.primary50),
              ),
            );
          }

          if (provider.error != null) {
            return Scaffold(
              backgroundColor: ColorTokens.neutral10,
              appBar: AppBar(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
                title: const Text('Perfil de Usuario'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: ColorTokens.error50,
                    ),
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
              ),
            );
          }

          final user = provider.currentUser;
          if (user == null) {
            return Scaffold(
              backgroundColor: ColorTokens.neutral10,
              appBar: AppBar(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
                title: const Text('Perfil de Usuario'),
              ),
              body: const Center(
                child: Text(
                  'Usuario no encontrado',
                  style: TextStyle(fontSize: 18, color: ColorTokens.neutral70),
                ),
              ),
            );
          }

          // Debug del usuario
          print('=== PUBLIC PROFILE USER DATA ===');
          print('User ID: "${user.id}"');
          print('User FullName: "${user.fullName}"');
          print('User UserName: "${user.userName}"');
          print('User Email: "${user.email}"');
          print('User Photo: "${user.photo}"');
          print('FullName isEmpty: ${user.fullName.isEmpty}');
          print('UserName isEmpty: ${user.userName.isEmpty}');
          print('Photo isEmpty: ${user.photo.isEmpty}');
          print('================================');

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Header del perfil
                SliverAppBar(
                  expandedHeight:
                      450, // Incrementado de 420 a 450 para eliminar el overflow
                  floating: false,
                  pinned: true,
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: ColorTokens.neutral100,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorTokens.primary30,
                            ColorTokens.primary40,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 40,
                              ), // Espacio para el AppBar
                              const Spacer(flex: 1), // Espacio flexible arriba
                              // Foto de perfil
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorTokens.neutral100,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: user.photo.isNotEmpty
                                      ? Image.network(
                                          user.photo,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: ColorTokens.neutral30,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: ColorTokens
                                                              .primary50,
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                print(
                                                  '❌ Error cargando imagen: $error',
                                                );
                                                print(
                                                  'URL de imagen: ${user.photo}',
                                                );
                                                return const CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor:
                                                      ColorTokens.neutral60,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color:
                                                        ColorTokens.neutral100,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          width: 100,
                                          height: 100,
                                          decoration: const BoxDecoration(
                                            color: ColorTokens.neutral60,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: ColorTokens.neutral100,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Nombre del usuario
                              Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName
                                    : (user.userName.isNotEmpty
                                          ? user.userName
                                          : 'Usuario sin nombre'), // Solo mostrar info pública
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: ColorTokens.neutral100,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // Solo mostrar username si existe, NUNCA email (privado)
                              if (user.userName.isNotEmpty)
                                Text(
                                  '@${user.userName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: ColorTokens.neutral90,
                                  ),
                                ),
                              const SizedBox(height: 20),

                              // Estadísticas básicas
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: _buildStatItem(
                                        'Posts',
                                        '${provider.userPosts.length}',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildStatItem(
                                        'Seguidores',
                                        '${provider.followersCount}',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildStatItem(
                                        'Siguiendo',
                                        '${provider.followingCount}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Botón de seguir removido
                              const Spacer(flex: 1), // Espacio flexible abajo
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tabs
                SliverPersistentHeader(
                  delegate: _TabHeaderDelegate(
                    child: Container(
                      color: ColorTokens.neutral10,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: ColorTokens.primary50,
                        labelColor: ColorTokens.primary50,
                        unselectedLabelColor: ColorTokens.neutral60,
                        tabs: const [
                          Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                          Tab(
                            icon: Icon(Icons.play_circle_outline),
                            text: 'Historias',
                          ),
                        ],
                      ),
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab de Posts
                _buildPostsTab(provider),
                // Tab de Historias
                _buildStoriesTab(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorTokens.neutral100,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12, // Reducido de 14 a 12 para evitar overflow
            color: ColorTokens.neutral90,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPostsTab(UserProfileProvider provider) {
    if (provider.userPosts.isEmpty) {
      return const Center(
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
              'No hay posts aún',
              style: TextStyle(fontSize: 18, color: ColorTokens.neutral60),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: provider.userPosts.length,
      itemBuilder: (context, index) {
        final post = provider.userPosts[index];
        return Container(
          decoration: BoxDecoration(
            color: ColorTokens.neutral20,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: post.media.isNotEmpty
                ? Image.network(
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
                  )
                : Container(
                    color: ColorTokens.neutral30,
                    child: const Icon(
                      Icons.image,
                      color: ColorTokens.neutral60,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildStoriesTab(UserProfileProvider provider) {
    if (provider.userStories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: ColorTokens.neutral60,
            ),
            SizedBox(height: 16),
            Text(
              'No hay historias aún',
              style: TextStyle(fontSize: 18, color: ColorTokens.neutral60),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 9 / 16,
      ),
      itemCount: provider.userStories.length,
      itemBuilder: (context, index) {
        final story = provider.userStories[index];
        return Container(
          decoration: BoxDecoration(
            color: ColorTokens.neutral20,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: story.media.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        story.media.first.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: ColorTokens.neutral30,
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: ColorTokens.neutral60,
                              size: 48,
                            ),
                          );
                        },
                      ),
                      // Overlay con gradiente
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                      // Icono de play si es video
                      if (story.media.first.mediaType.toString().contains(
                        'video',
                      ))
                        const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: ColorTokens.neutral100,
                            size: 48,
                          ),
                        ),
                    ],
                  )
                : Container(
                    color: ColorTokens.neutral30,
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: ColorTokens.neutral60,
                      size: 48,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// Delegate para el header persistente de las tabs
class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
