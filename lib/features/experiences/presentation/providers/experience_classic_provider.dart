import 'package:flutter/foundation.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';

/// Provider de experiencias usando ChangeNotifier para compatibilidad con Provider clásico
class ExperienceProvider extends ChangeNotifier {
  final ExperienceRepository _repository;

  ExperienceProvider({ExperienceRepository? repository})
    : _repository = repository ?? ExperienceRepositoryImpl();

  // Estado
  List<ExperienceEntity> _experiences = [];
  List<ExperienceEntity> _allExperiences = []; // Todos los posts disponibles
  List<ExperienceEntity> _userExperiences = [];
  List<ExperienceEntity> _rideExperiences = [];
  bool _isLoading = false;
  bool _isLoadingMore = false; // Para cargar más posts
  bool _hasMorePosts = true; // Si hay más posts por cargar
  String? _error;
  static const int _postsPerPage =
      20; // Posts por página (aumentado para mejor UX)
  static const int _initialPostsCount =
      15; // Posts iniciales (suficientes para pantalla completa)

  // Getters
  List<ExperienceEntity> get experiences => _experiences;
  List<ExperienceEntity> get userExperiences => _userExperiences;
  List<ExperienceEntity> get rideExperiences => _rideExperiences;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePosts => _hasMorePosts;
  String? get error => _error;

  /// Carga experiencias de un usuario específico
  Future<void> loadUserExperiences(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await _repository.getUserExperiences(userId);
      _setUserExperiences(experiences);
    } catch (e) {
      _setError('Error cargando experiencias: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga experiencias de una rodada específica
  Future<void> loadRideExperiences(String rideId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await _repository.getRideExperiences(rideId);
      _setRideExperiences(experiences);
    } catch (e) {
      _setError('Error cargando experiencias de rodada: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga experiencias de usuarios seguidos
  Future<void> loadFollowingExperiences(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await _repository.getFollowingExperiences(userId);
      _setExperiences(experiences);
    } catch (e) {
      _setError('Error cargando experiencias: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga el feed personalizado que incluye:
  /// - Los grupos que sigo
  /// - Mis publicaciones
  /// - Las publicaciones de los perfiles que sigo
  Future<void> loadPersonalizedFeed(String userId) async {
    try {
      _setLoading(true);
      _error = null;
      _hasMorePosts = true; // Reset paginación

      print('🔍 FEED: Cargando feed personalizado para usuario: $userId');

      // Cargar experiencias del usuario actual (mis publicaciones)
      final myExperiences = await _repository.getUserExperiences(userId);
      print('🔍 FEED: Mis experiencias cargadas: ${myExperiences.length}');

      // Cargar experiencias de usuarios seguidos
      final followingExperiences = await _repository.getFollowingExperiences(
        userId,
      );
      print(
        '🔍 FEED: Experiencias de seguidos cargadas: ${followingExperiences.length}',
      );

      // Combinar todas las experiencias y ordenar por fecha (más recientes primero)
      final allExperiences = [...myExperiences, ...followingExperiences];
      allExperiences.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('🔍 FEED: Total experiencias en feed: ${allExperiences.length}');

      // Debug: mostrar autores de las experiencias
      for (int i = 0; i < allExperiences.length && i < 5; i++) {
        final exp = allExperiences[i];
        print(
          '🔍 FEED: Experiencia ${i + 1}: Autor: "${exp.user.fullName}" (${exp.user.id})',
        );
      }

      // Guardar todos los posts disponibles para paginación
      _allExperiences = allExperiences;

      // Cargar posts iniciales (suficientes para llenar pantalla)
      final initialPosts = allExperiences.take(_initialPostsCount).toList();
      _hasMorePosts = allExperiences.length > _initialPostsCount;

      print(
        '🔍 FEED: Cargando ${initialPosts.length} posts iniciales. Hay más: $_hasMorePosts',
      );
      _setExperiences(initialPosts);
    } catch (e) {
      print('❌ FEED: Error cargando feed personalizado: $e');
      _setError('Error cargando feed personalizado: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga más posts para infinite scroll (paginación)
  Future<void> loadMorePosts(String userId) async {
    // Si ya está cargando más o no hay más posts, no hacer nada
    if (_isLoadingMore || !_hasMorePosts || _isLoading) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      print('🔄 FEED: Cargando más posts... Actual: ${_experiences.length}');

      // Obtener los siguientes posts de la lista completa ya cargada
      final currentLength = _experiences.length;
      final newPosts = _allExperiences
          .skip(currentLength)
          .take(_postsPerPage)
          .toList();

      if (newPosts.isEmpty) {
        _hasMorePosts = false;
        print('✅ FEED: No hay más posts para cargar');
      } else {
        _experiences.addAll(newPosts);
        _hasMorePosts = _experiences.length < _allExperiences.length;
        print(
          '✅ FEED: ${newPosts.length} posts más cargados. Total: ${_experiences.length}/${_allExperiences.length}',
        );
        notifyListeners();
      }
    } catch (e) {
      print('❌ FEED: Error cargando más posts: $e');
      _setError('Error cargando más posts: ${e.toString()}');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Crea una nueva experiencia
  Future<bool> createExperience(CreateExperienceRequest request) async {
    try {
      _setLoading(true);
      _error = null;

      final newExperience = await _repository.createExperience(request);

      // Recargar experiencias después de crear una nueva
      _refreshAfterCreate(newExperience);
      return true;
    } catch (e) {
      _setError('Error creando experiencia: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina una experiencia
  Future<bool> deleteExperience(String experienceId) async {
    try {
      _setLoading(true);
      _error = null;

      await _repository.deleteExperience(experienceId);

      // Remover de las listas locales
      _removeExperienceFromLists(experienceId);
      return true;
    } catch (e) {
      _setError('Error eliminando experiencia: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Agrega una reacción a una experiencia
  Future<bool> addReaction(String experienceId, ReactionType reaction) async {
    try {
      await _repository.addReaction(experienceId, reaction);
      return true;
    } catch (e) {
      _setError('Error agregando reacción: ${e.toString()}');
      return false;
    }
  }

  /// Elimina una reacción de una experiencia
  Future<bool> removeReaction(String experienceId) async {
    try {
      await _repository.removeReaction(experienceId);
      return true;
    } catch (e) {
      _setError('Error eliminando reacción: ${e.toString()}');
      return false;
    }
  }

  /// Marca una experiencia como vista
  Future<void> markAsViewed(String experienceId) async {
    try {
      await _repository.markAsViewed(experienceId);
    } catch (e) {
      // Error silencioso para las visualizaciones
      debugPrint('Error marcando como vista: ${e.toString()}');
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reinicia el estado
  void reset() {
    _experiences = [];
    _allExperiences = [];
    _userExperiences = [];
    _rideExperiences = [];
    _isLoading = false;
    _isLoadingMore = false;
    _hasMorePosts = true;
    _error = null;
    notifyListeners();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _setExperiences(List<ExperienceEntity> experiences) {
    _experiences = experiences;
    notifyListeners();
  }

  void _setUserExperiences(List<ExperienceEntity> experiences) {
    _userExperiences = experiences;
    notifyListeners();
  }

  void _setRideExperiences(List<ExperienceEntity> experiences) {
    _rideExperiences = experiences;
    notifyListeners();
  }

  void _refreshAfterCreate(ExperienceEntity newExperience) {
    // Agregar a la lista general
    _experiences = [newExperience, ..._experiences];

    // Agregar a experiencias de usuario si corresponde
    _userExperiences = [newExperience, ..._userExperiences];

    // Agregar a experiencias de rodada si corresponde
    if (newExperience.rideId != null) {
      _rideExperiences = [newExperience, ..._rideExperiences];
    }

    notifyListeners();
  }

  void _removeExperienceFromLists(String experienceId) {
    _experiences.removeWhere((exp) => exp.id == experienceId);
    _userExperiences.removeWhere((exp) => exp.id == experienceId);
    _rideExperiences.removeWhere((exp) => exp.id == experienceId);
    notifyListeners();
  }
}
