import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/data/repositories/user_profile_repository_impl.dart';
import 'package:biux/features/users/domain/repositories/user_profile_repository.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileRepository _repository = UserProfileRepositoryImpl();
  final ExperienceRepository _experienceRepository = ExperienceRepositoryImpl();

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
      _searchResults = results;
    } catch (e) {
      print('Error en búsqueda: $e');
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
    print('🔄 CARGANDO PERFIL DE USUARIO');
    print('UserID solicitado: "$userId"');

    _isLoadingProfile = true;
    _error = null;
    _currentProfile =
        null; // Limpiar perfil anterior para asegurar datos frescos
    notifyListeners();

    try {
      print('📡 Consultando perfil desde Firestore...');
      final profile = await _repository.getUserProfile(userId);

      print('📋 RESULTADO DE CONSULTA:');
      if (profile != null) {
        print('✅ Perfil encontrado:');
        print('  - ID: "${profile.id}"');
        print('  - FullName: "${profile.fullName}"');
        print('  - UserName: "${profile.userName}"');
        print('  - Email: "${profile.email}"');
        print('  - Photo: "${profile.photo}"');
        print('  - FullName isEmpty: ${profile.fullName.isEmpty}');
        print('  - UserName isEmpty: ${profile.userName.isEmpty}');
        print('  - Photo isEmpty: ${profile.photo.isEmpty}');
      } else {
        print('❌ Perfil NO encontrado para userId: "$userId"');
      }

      _currentProfile = profile;

      if (profile != null) {
        // Verificar si ya lo sigue
        _isFollowing = await _repository.isFollowing(userId);
        print('👥 Siguiendo usuario: $_isFollowing');

        // Cargar posts y stories del usuario
        await _loadUserContent(userId);
      }
    } catch (e) {
      print('❌ ERROR cargando perfil: $e');
      _error = 'Error al cargar el perfil del usuario';
      _currentProfile = null;
      _isFollowing = false;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // Cargar contenido del usuario (posts y stories)
  Future<void> _loadUserContent(String userId) async {
    _isLoadingContent = true;
    notifyListeners();

    try {
      print('🔍 PROFILE: Cargando experiencias para usuario: $userId');

      // Cargar experiencias reales del usuario
      final userExperiences = await _experienceRepository.getUserExperiences(
        userId,
      );

      // Filtrar posts y stories con criterios más específicos
      final now = DateTime.now();
      final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

      // Stories: experiencias recientes (últimas 24 horas) O que tengan solo un medio
      _userStories = userExperiences
          .where(
            (exp) =>
                exp.createdAt.isAfter(twentyFourHoursAgo) ||
                exp.media.length == 1,
          )
          .toList();

      // Posts: experiencias con múltiples medios O más antiguas de 24 horas
      _userPosts = userExperiences
          .where(
            (exp) =>
                exp.media.length > 1 ||
                exp.createdAt.isBefore(twentyFourHoursAgo),
          )
          .toList();

      // Si no hay diferenciación clara, dividir equitativamente
      if (_userStories.length == userExperiences.length &&
          _userPosts.length == userExperiences.length) {
        final halfPoint = (userExperiences.length / 2).ceil();
        _userStories = userExperiences.take(halfPoint).toList();
        _userPosts = userExperiences.skip(halfPoint).toList();
      }

      print('🔍 PROFILE: Experiencias cargadas: ${userExperiences.length}');
      print('🔍 PROFILE: Stories: ${_userStories.length}');
      print('🔍 PROFILE: Posts: ${_userPosts.length}');
      print(
        '🔍 PROFILE: Criterios aplicados - Stories: recientes O 1 medio, Posts: múltiples medios O antiguos',
      );
    } catch (e) {
      print('❌ Error cargando contenido del usuario: $e');
      _userPosts = [];
      _userStories = [];
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  // Seguir usuario
  Future<bool> followUser(String userId) async {
    try {
      final success = await _repository.followUser(userId);
      if (success) {
        _isFollowing = true;
        // Actualizar contador de followers si tenemos el perfil cargado
        if (_currentProfile?.id == userId) {
          _currentProfile = BiuxUser.fromJsonMap({
            ..._currentProfile!.toJson(),
            'followerS': _currentProfile!.followerS + 1,
          });
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error siguiendo usuario: $e');
      return false;
    }
  }

  // Dejar de seguir usuario
  Future<bool> unfollowUser(String userId) async {
    try {
      final success = await _repository.unfollowUser(userId);
      if (success) {
        _isFollowing = false;
        // Actualizar contador de followers si tenemos el perfil cargado
        if (_currentProfile?.id == userId) {
          _currentProfile = BiuxUser.fromJsonMap({
            ..._currentProfile!.toJson(),
            'followerS': _currentProfile!.followerS - 1,
          });
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error dejando de seguir usuario: $e');
      return false;
    }
  }

  // Cargar followers
  Future<void> loadFollowers(String userId) async {
    _isLoadingFollowers = true;
    notifyListeners();

    try {
      _followers = await _repository.getFollowers(userId);
    } catch (e) {
      print('Error cargando followers: $e');
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
      print('Error cargando following: $e');
      _following = [];
    } finally {
      _isLoadingFollowing = false;
      notifyListeners();
    }
  }

  // Limpiar estado del perfil
  void clearProfileState() {
    _currentProfile = null;
    _isFollowing = false;
    _followers = [];
    _following = [];
    notifyListeners();
  }
}
