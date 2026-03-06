import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/presentation/providers/user_profile_provider.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<BiuxUser> _filteredResults = [];

  @override
  void initState() {
    super.initState();
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

  // Función para calcular similitud entre strings (Levenshtein)
  double _calculateSimilarity(String s1, String s2) {
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final List<List<int>> distances = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) distances[i][0] = i;
    for (int j = 0; j <= s2.length; j++) distances[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        distances[i][j] = [
          distances[i - 1][j] + 1,
          distances[i][j - 1] + 1,
          distances[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    final maxLength = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distances[s1.length][s2.length] / maxLength);
  }

  // Función inteligente de búsqueda
  double _calculateSearchScore(BiuxUser user, String query) {
    final q = query.toLowerCase().trim();
    final fullName = user.fullName.toLowerCase();
    final userName = user.userName.toLowerCase();
    final description = user.description.toLowerCase();

    double score = 0.0;

    // 1. Coincidencia exacta (máxima prioridad)
    if (fullName == q || userName == q) return 1.0;

    // 2. Comienza con (muy alta prioridad)
    if (fullName.startsWith(q)) score = 0.95;
    if (userName.startsWith(q)) score = 0.95;

    // 3. Contiene (alta prioridad)
    if (score < 0.9) {
      if (fullName.contains(q)) score = 0.85;
      if (userName.contains(q)) score = 0.85;
    }

    // 4. Similitud fuzzy (prioridad media)
    if (score < 0.8) {
      final nameSimi = _calculateSimilarity(fullName, q);
      final usernameSimi = _calculateSimilarity(userName, q);
      final maxSimi = nameSimi > usernameSimi ? nameSimi : usernameSimi;
      if (maxSimi > 0.5) score = 0.5 + (maxSimi * 0.3); // 0.5 - 0.8
    }

    // 5. Descripción (baja prioridad)
    if (score < 0.5 && description.contains(q)) {
      score = 0.3;
    }

    return score;
  }

  // Función para aplicar búsqueda fuzzy
  List<BiuxUser> _applyFuzzySearch(List<BiuxUser> users, String query) {
    if (query.isEmpty) return [];

    final results = <MapEntry<BiuxUser, double>>[];

    for (final user in users) {
      final score = _calculateSearchScore(user, query);

      // Incluir si la puntuación es mayor a 0.15 (15%)
      // Umbral bajo permite búsquedas por 1-2 caracteres (como Instagram)
      if (score > 0.15) {
        results.add(MapEntry(user, score));
      }
    }

    // Ordenar por puntuación descendente
    results.sort((a, b) => b.value.compareTo(a.value));

    return results.map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: ColorTokens.primary30,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text(l.t('search_users')),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda estilo Instagram
          Container(
            padding: EdgeInsets.all(16),
            color: ColorTokens.primary30,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: TextStyle(color: ColorTokens.neutral100, fontSize: 16),
              decoration: InputDecoration(
                hintText: l.t('search_users_hint'),
                hintStyle: TextStyle(
                  color: ColorTokens.neutral80,
                  fontSize: 16,
                ),
                prefixIcon: Icon(Icons.search, color: ColorTokens.neutral90),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: ColorTokens.neutral90),
                        onPressed: () {
                          _searchController.clear();
                          context.read<UserProfileProvider>().clearSearch();
                          setState(() {
                            _filteredResults = [];
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: ColorTokens.primary40,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.trim().isNotEmpty) {
                  context.read<UserProfileProvider>().searchUsers(value);
                } else {
                  context.read<UserProfileProvider>().clearSearch();
                  _filteredResults = [];
                }
              },
            ),
          ),

          // Resultados de búsqueda
          Expanded(
            child: Consumer<UserProfileProvider>(
              builder: (context, provider, child) {
                // Aplicar búsqueda fuzzy
                _filteredResults = _applyFuzzySearch(
                  provider.searchResults,
                  _searchController.text,
                );

                if (provider.searchQuery.isEmpty) {
                  return _buildEmptyState();
                }

                if (provider.isSearching) {
                  return _buildLoadingState();
                }

                if (_filteredResults.isEmpty) {
                  return _buildNoResultsState();
                }

                return _buildSearchResults(_filteredResults);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: ColorTokens.neutral100),
          SizedBox(height: 24),
          Text(
            l.t('search_users_empty_title'),
            style: TextStyle(
              color: ColorTokens.neutral100,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            l.t('search_users_description'),
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorTokens.neutral80, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.secondary50),
          ),
          SizedBox(height: 16),
          Text(
            l.t('searching_users'),
            style: TextStyle(color: ColorTokens.neutral100, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: ColorTokens.neutral100),
          SizedBox(height: 24),
          Text(
            l.t('no_users_found'),
            style: TextStyle(
              color: ColorTokens.neutral100,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            l.t('try_another_search'),
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorTokens.neutral80, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<BiuxUser> users) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _InstagramStyleUserCard(
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

class _InstagramStyleUserCard extends StatefulWidget {
  final BiuxUser user;
  final VoidCallback onTap;

  const _InstagramStyleUserCard({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_InstagramStyleUserCard> createState() =>
      _InstagramStyleUserCardState();
}

class _InstagramStyleUserCardState extends State<_InstagramStyleUserCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorTokens.primary40, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto de perfil
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorTokens.primary30,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: ColorTokens.primary40,
                      backgroundImage: widget.user.photo.isNotEmpty
                          ? CachedNetworkImageProvider(
                              widget.user.photo,
                              cacheManager:
                                  OptimizedCacheManager.avatarInstance,
                            )
                          : null,
                      child: widget.user.photo.isEmpty
                          ? Icon(
                              Icons.person_outline,
                              color: ColorTokens.neutral100,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Información del usuario
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre completo
                        Text(
                          widget.user.fullName.isNotEmpty
                              ? widget.user.fullName
                              : l.t('no_name'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorTokens.neutral100,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        // Username
                        if (widget.user.userName.isNotEmpty)
                          Text(
                            '@${widget.user.userName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorTokens.neutral80,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 4),
                        // Descripción
                        if (widget.user.description.isNotEmpty)
                          Text(
                            widget.user.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorTokens.neutral80,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        // Seguidores
                        if (widget.user.followerS > 0)
                          Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: ColorTokens.primary30.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.user.followerS} ${widget.user.followerS == 1 ? l.t('follower_singular') : l.t('followers')}',
                                style: TextStyle(
                                  color: ColorTokens.primary30,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  // Icono de navegación
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary30.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: ColorTokens.primary30,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
