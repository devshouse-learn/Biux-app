import 'dart:async';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/data/repositories/user_profile_repository_impl.dart';
import 'package:biux/features/users/domain/repositories/user_profile_repository.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileRepository _repository = UserProfileRepositoryImpl();
  final ExperienceRepository _experienceRepository = ExperienceRepositoryImpl();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listener subscription para el perfil actual
  StreamSubscription<DocumentSnapshot>? _profileStreamSubscription;

  // Estado de búsqueda
  List<BiuxUser> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  // Estado del perfil actual
  BiuxUser? _currentProfile;
  bool _isLoadingProfile = false;
  bool _isFollowing = false;
  List<BiuxUser> _followers = [];
  List<BiuxUser> _following = [];
  bool _isLoadingFollowers = false;
  bool _isLoadingFollowing = false;
  bool _isProcessingFollow = false; // ✅ NUEVA: Estado de procesamiento

  // Estado de posts y stories del usuario
  List<dynamic> _userPosts = [];
  List<dynamic> _userStories = [];
  bool _isLoadingContent = false;
  String? _error;

  // Map para rastrear cooldown de follow/unfollow (tiempo de espera entre acciones)
  final Map<String, DateTime> _followCooldowns = {};

  // Duración del cooldown (3 segundos para follow/unfollow)
  static const Duration _followCooldownDuration = Duration(seconds: 3);

  // Helper methods para cooldown
  bool _isInFollowCooldown(String userId) {
    final lastAction = _followCooldowns[userId];
    if (lastAction == null) return false;
    return DateTime.now().difference(lastAction) < _followCooldownDuration;
  }

  void _setFollowCooldown(String userId) {
    _followCooldowns[userId] = DateTime.now();
  }

  // Getters
  List<BiuxUser> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  BiuxUser? get currentProfile => _currentProfile;
  BiuxUser? get currentUser => _currentProfile; // Alias para compatibilidad
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoading => _isLoadingProfile || _isLoadingContent;
  bool get isFollowing => _isFollowing;
  bool get isProcessingFollow => _isProcessingFollow; // ✅ NUEVO
  List<BiuxUser> get followers => _followers;
  List<BiuxUser> get following => _following;
  bool get isLoadingFollowers => _isLoadingFollowers;
  bool get isLoadingFollowing => _isLoadingFollowing;
  List<dynamic> get userPosts => _userPosts;
  List<dynamic> get userStories => _userStories;
  int get followersCount => _currentProfile?.followerS ?? 0;
  int get followingCount => _currentProfile?.following.length ?? 0;
  String? get error => _error;

  // Búsqueda de usuarios
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchQuery = query;
    notifyListeners();

    try {
      final results = await _repository.searchUsers(query);

      // Aplicar filtrado adicional en memoria para mejorar resultados
      final q = query.toLowerCase().trim();
      final filtered = results.where((user) {
        final fullName = user.fullName.toLowerCase();
        final userName = user.userName.toLowerCase();
        final description = user.description.toLowerCase();

        // Dar prioridad a coincidencias exactas y al inicio
        return fullName.startsWith(q) ||
            userName.startsWith(q) ||
            fullName.contains(q) ||
            userName.contains(q) ||
            description.contains(q);
      }).toList();

      // Ordenar: primero los que comienzan con la búsqueda, luego los que la contienen
      filtered.sort((a, b) {
        final aFullName = a.fullName.toLowerCase();
        final aUserName = a.userName.toLowerCase();
        final bFullName = b.fullName.toLowerCase();
        final bUserName = b.userName.toLowerCase();

        final aStartsWithQuery =
            aFullName.startsWith(q) || aUserName.startsWith(q);
        final bStartsWithQuery =
            bFullName.startsWith(q) || bUserName.startsWith(q);

        if (aStartsWithQuery && !bStartsWithQuery) return -1;
        if (!aStartsWithQuery && bStartsWithQuery) return 1;
        return 0;
      });

      _searchResults = filtered;
    } catch (e) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Limpiar búsqueda
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  // Cargar perfil de usuario
  Future<void> loadUserProfile(String userId) async {
    _isLoadingProfile = true;
    _error = null;
    _currentProfile =
        null; // Limpiar perfil anterior para asegurar datos frescos
    notifyListeners();

    try {
      final profile = await _repository.getUserProfile(userId);
      _currentProfile = profile;

      if (profile != null) {
        // Verificar si ya lo sigue
        _isFollowing = await _repository.isFollowing(userId);

        // Cargar posts y stories del usuario
        await _loadUserContent(userId);
      }
    } catch (e) {
      _error = 'Error al cargar el perfil del usuario';
      _currentProfile = null;
      _isFollowing = false;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
      // Configurar listener en tiempo real
      if (_currentProfile != null) {
        _setupProfileListener(_currentProfile!.id);
      }
    }
  }

  // Configurar listener en tiempo real para el perfil actual
  void _setupProfileListener(String userId) {
    // Cancelar listener anterior si existía
    _profileStreamSubscription?.cancel();

    try {
      _profileStreamSubscription = _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((doc) {
            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>;
              try {
                _currentProfile = BiuxUser.fromJsonMap({...data, 'id': userId});
                notifyListeners();
              } catch (e) {}
            }
          }, onError: (error) {});
    } catch (e) {}
  }

  /// Actualización rápida del perfil sin cargar contenido (para después de follow/unfollow)
  Future<void> refreshProfileQuick(String userId) async {
    try {
      final profile = await _repository.getUserProfile(userId);
      if (profile != null) {
        _currentProfile = profile;
      }
    } catch (e) {
    } finally {
      notifyListeners();
    }
  }

  // Cargar contenido del usuario (posts y stories)
  Future<void> _loadUserContent(String userId) async {
    _isLoadingContent = true;
    notifyListeners();

    try {
      // Cargar experiencias del usuario
      var userExperiences = await _experienceRepository.getUserExperiences(
        userId,
      );

      // ✅ Validar que las publicaciones estén disponibles
      // Filtrar publicaciones que no tengan media o cuya media esté vacía
      final validExperiences = userExperiences.where((exp) {
        // ignore: unnecessary_null_comparison, dead_null_aware_expression
        final hasMedia = exp.media != null && exp.media.isNotEmpty;
        if (!hasMedia) {
          print('⚠️ Eliminando publicación sin media: ${exp.id}');
        }
        return hasMedia;
      }).toList();

      _userPosts = validExperiences;

      // Stories: solo experiencias efímeras válidas
      final now = DateTime.now();
      final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

      _userStories = validExperiences
          .where(
            (exp) =>
                exp.createdAt.isAfter(twentyFourHoursAgo) &&
                exp.description.trim().length <= 20 &&
                exp.media.length == 1 &&
                exp.media.first.url.trim().isNotEmpty &&
                (exp.media.first.url.startsWith('http://') ||
                    exp.media.first.url.startsWith('https://')),
          )
          .toList();
    } catch (e) {
      _userPosts = [];
      _userStories = [];
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  // Seguir usuario
  Future<bool> followUser(String userId) async {
    // ⛔ PROTECCIÓN: No permitir si ya está procesando
    if (_isProcessingFollow) {
      debugPrint('⏳ Ya se está procesando una acción de follow/unfollow');
      return false;
    }

    // Cooldown: evitar múltiples clicks en el mismo usuario
    if (_isInFollowCooldown(userId)) {
      debugPrint(
        '⏳ Follow en cooldown para $userId, espera ${_followCooldownDuration.inSeconds}s',
      );
      return false;
    }

    _isProcessingFollow = true;
    notifyListeners();

    try {
      final success = await _repository.followUser(userId);
      if (success) {
        _isFollowing = true;
        // Actualizar contador de followers si tenemos el perfil cargado
        if (_currentProfile?.id == userId) {
          int newFollowerCount = _currentProfile!.followerS + 1;
          _currentProfile = BiuxUser.fromJsonMap({
            ..._currentProfile!.toJson(),
            'followerS': newFollowerCount,
          });
        }

        // Establecer cooldown después de éxito
        _setFollowCooldown(userId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      return false;
    } finally {
      _isProcessingFollow = false;
      notifyListeners();
    }
  }

  // Dejar de seguir usuario
  Future<bool> unfollowUser(String userId) async {
    // ⛔ PROTECCIÓN: No permitir si ya está procesando
    if (_isProcessingFollow) {
      debugPrint('⏳ Ya se está procesando una acción de follow/unfollow');
      return false;
    }

    // Cooldown: evitar múltiples clicks en el mismo usuario
    if (_isInFollowCooldown(userId)) {
      debugPrint(
        '⏳ Unfollow en cooldown para $userId, espera ${_followCooldownDuration.inSeconds}s',
      );
      return false;
    }

    _isProcessingFollow = true;
    notifyListeners();

    try {
      final success = await _repository.unfollowUser(userId);
      if (success) {
        _isFollowing = false;
        // Actualizar contador de followers si tenemos el perfil cargado
        if (_currentProfile?.id == userId) {
          // Asegurar que no sea negativo
          int newFollowerCount = (_currentProfile!.followerS - 1)
              .clamp(0, double.maxFinite)
              .toInt();
          _currentProfile = BiuxUser.fromJsonMap({
            ..._currentProfile!.toJson(),
            'followerS': newFollowerCount,
          });
        }

        // Establecer cooldown después de éxito
        _setFollowCooldown(userId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      return false;
    } finally {
      _isProcessingFollow = false;
      notifyListeners();
    }
  }

  // Cargar followers
  Future<void> loadFollowers(String userId) async {
    _isLoadingFollowers = true;
    notifyListeners();

    try {
      _followers = await _repository.getFollowers(userId);
    } catch (e) {
      _followers = [];
    } finally {
      _isLoadingFollowers = false;
      notifyListeners();
    }
  }

  // Cargar following
  Future<void> loadFollowing(String userId) async {
    _isLoadingFollowing = true;
    notifyListeners();

    try {
      _following = await _repository.getFollowing(userId);
    } catch (e) {
      _following = [];
    } finally {
      _isLoadingFollowing = false;
      notifyListeners();
    }
  }

  // Limpiar estado del perfil
  void clearProfileState() {
    _profileStreamSubscription?.cancel();
    _currentProfile = null;
    _isFollowing = false;
    _followers = [];
    _following = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _profileStreamSubscription?.cancel();
    super.dispose();
  }
}
