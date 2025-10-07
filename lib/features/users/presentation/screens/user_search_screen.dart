import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus en la búsqueda al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.neutral100,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text('Buscar Usuarios'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: EdgeInsets.all(16),
            color: ColorTokens.primary30,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: TextStyle(color: ColorTokens.neutral100),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o usuario...',
                hintStyle: TextStyle(color: ColorTokens.neutral60),
                prefixIcon: Icon(Icons.search, color: ColorTokens.neutral60),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: ColorTokens.neutral60),
                        onPressed: () {
                          _searchController.clear();
                          context.read<UserProfileProvider>().clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: ColorTokens.neutral20,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.trim().isNotEmpty) {
                  context.read<UserProfileProvider>().searchUsers(value);
                } else {
                  context.read<UserProfileProvider>().clearSearch();
                }
              },
            ),
          ),

          // Resultados de búsqueda
          Expanded(
            child: Consumer<UserProfileProvider>(
              builder: (context, provider, child) {
                if (provider.searchQuery.isEmpty) {
                  return _buildEmptyState();
                }

                if (provider.isSearching) {
                  return _buildLoadingState();
                }

                if (provider.searchResults.isEmpty) {
                  return _buildNoResultsState();
                }

                return _buildSearchResults(provider.searchResults);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: ColorTokens.neutral60),
          SizedBox(height: 16),
          Text(
            'Busca usuarios por nombre o usuario',
            style: TextStyle(color: ColorTokens.neutral60, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary30),
          ),
          SizedBox(height: 16),
          Text(
            'Buscando usuarios...',
            style: TextStyle(color: ColorTokens.neutral60, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 64, color: ColorTokens.neutral60),
          SizedBox(height: 16),
          Text(
            'No se encontraron usuarios',
            style: TextStyle(
              color: ColorTokens.neutral60,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(color: ColorTokens.neutral60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<BiuxUser> users) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserListItem(
          user: user,
          onTap: () {
            // Navegar al perfil del usuario
            context.push('/user-profile/${user.id}');
          },
        );
      },
    );
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
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: ColorTokens.neutral20,
          backgroundImage: user.photo.isNotEmpty
              ? CachedNetworkImageProvider(
                  user.photo,
                  cacheManager: OptimizedCacheManager.avatarInstance,
                )
              : null,
          child: user.photo.isEmpty
              ? Icon(Icons.person, color: ColorTokens.neutral60, size: 30)
              : null,
        ),
        title: Text(
          user.fullName.isNotEmpty ? user.fullName : 'Sin nombre',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorTokens.primary30,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.userName.isNotEmpty)
              Text(
                '@${user.userName}',
                style: TextStyle(color: ColorTokens.neutral60, fontSize: 14),
              ),
            if (user.description.isNotEmpty)
              Text(
                user.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: ColorTokens.neutral70, fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.followerS > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorTokens.primary30.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${user.followerS} seguidores',
                  style: TextStyle(
                    color: ColorTokens.primary30,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(width: 8),
            Icon(Icons.chevron_right, color: ColorTokens.neutral60),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
