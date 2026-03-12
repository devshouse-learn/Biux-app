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

  // Estado de follow request (cuentas privadas)
  bool _hasPendingFollowRequest = false;
  bool _isPrivateAccount = false;
  List<BiuxUser> _followRequests = [];
  bool _isLoadingFollowRequests = false;

  // Estado de posts y stories del usuario
  List<dynamic> _userPosts = [];
  List<dynamic> _userStories = [];
  bool _isLoadingContent = false;
  String? _error;

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
  bool get hasPendingFollowRequest => _hasPendingFollowRequest;
  bool get isPrivateAccount => _isPrivateAccount;
  List<BiuxUser> get followRequests => _followRequests;
  bool get isLoadingFollowRequests => _isLoadingFollowRequests;
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
    _hasPendingFollowRequest = false;
    _isPrivateAccount = false;
    notifyListeners();

    try {
      final profile = await _repository.getUserProfile(userId);
      _currentProfile = profile;

      if (profile != null) {
        // Verificar si ya lo sigue
        _isFollowing = await _repository.isFollowing(userId);

        // Verificar si la cuenta es privada
        _isPrivateAccount = profile.profileVisibility == 'private';

        // Si es privada y no lo sigue, verificar solicitud pendiente
        if (_isPrivateAccount && !_isFollowing) {
          _hasPendingFollowRequest = await _repository.hasPendingFollowRequest(
            userId,
          );
        }

        // Cargar posts y stories solo si no es privada O si ya lo sigue
        if (!_isPrivateAccount || _isFollowing) {
          await _loadUserContent(userId);
        } else {
          _userPosts = [];
          _userStories = [];
        }
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
          debugPrint('⚠️ Eliminando publicación sin media: ${exp.id}');
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

  // Seguir usuario (o enviar solicitud si es privado)
  Future<bool> followUser(String userId) async {
    if (_isProcessingFollow) return false;

    _isProcessingFollow = true;
    notifyListeners();

    try {
      // Si la cuenta es privada, enviar solicitud en vez de seguir directamente
      if (_isPrivateAccount) {
        final success = await _repository.sendFollowRequest(userId);
        if (success) {
          _hasPendingFollowRequest = true;
          notifyListeners();
        }
        return success;
      }

      // Cuenta pública: seguir directamente
      final success = await _repository.followUser(userId);
      if (success) {
        _isFollowing = true;
        notifyListeners();
        // Recargar perfil desde Firestore para obtener contadores reales
        await refreshProfileQuick(userId);
      }
      return success;
    } catch (e) {
      return false;
    } finally {
      _isProcessingFollow = false;
      notifyListeners();
    }
  }

  // Cancelar solicitud de seguimiento
  Future<bool> cancelFollowRequest(String userId) async {
    if (_isProcessingFollow) return false;

    _isProcessingFollow = true;
    notifyListeners();

    try {
      final success = await _repository.cancelFollowRequest(userId);
      if (success) {
        _hasPendingFollowRequest = false;
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

  // Aceptar solicitud de seguimiento
  Future<bool> acceptFollowRequest(String requesterId) async {
    try {
      final success = await _repository.acceptFollowRequest(requesterId);
      if (success) {
        _followRequests.removeWhere((user) => user.id == requesterId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Rechazar solicitud de seguimiento
  Future<bool> rejectFollowRequest(String requesterId) async {
    try {
      final success = await _repository.rejectFollowRequest(requesterId);
      if (success) {
        _followRequests.removeWhere((user) => user.id == requesterId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Cargar solicitudes de seguimiento pendientes
  Future<void> loadFollowRequests() async {
    _isLoadingFollowRequests = true;
    notifyListeners();

    try {
      _followRequests = await _repository.getFollowRequests();
    } catch (e) {
      _followRequests = [];
    } finally {
      _isLoadingFollowRequests = false;
      notifyListeners();
    }
  }

  // Dejar de seguir usuario
  Future<bool> unfollowUser(String userId) async {
    if (_isProcessingFollow) return false;

    _isProcessingFollow = true;
    notifyListeners();

    try {
      final success = await _repository.unfollowUser(userId);
      if (success) {
        _isFollowing = false;
        notifyListeners();
        // Recargar perfil desde Firestore para obtener contadores reales
        await refreshProfileQuick(userId);
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
    _hasPendingFollowRequest = false;
    _isPrivateAccount = false;
    _followers = [];
    _following = [];
    _followRequests = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _profileStreamSubscription?.cancel();
    super.dispose();
  }
}
