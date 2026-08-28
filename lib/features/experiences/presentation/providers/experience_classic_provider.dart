import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/services/retry_service.dart';
import 'package:biux/core/error/error_handler.dart';

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

  /// Mapa de { originalPostId a†’ repostExperienceId } del usuario actual
  Map<String, String> _myReposts = {};
  static const int _postsPerPage =
      20; // Posts por página (aumentado para mejor UX)
  static const int _initialPostsCount =
      15; // Posts iniciales (suficientes para pantalla completa)

  // Stream para detectar contenido nuevo en tiempo real
  StreamSubscription<DateTime?>? _feedStreamSubscription;
  DateTime? _latestKnownTimestamp;
  String? _currentFeedUserId;
  bool _isCreating =
      false; // Bandera para evitar race conditions con loadPersonalizedFeed

  // Getters
  List<ExperienceEntity> get experiences => _experiences;
  List<ExperienceEntity> get allExperiences => _allExperiences;
  List<ExperienceEntity> get userExperiences => _userExperiences;
  List<ExperienceEntity> get rideExperiences => _rideExperiences;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePosts => _hasMorePosts;
  String? get error => _error;

  /// Verifica si los reposts del usuario ya se han cargado
  bool get repostsLoaded => _myReposts.containsKey('_loaded');

  /// Limpia la caché de experiencias para forzar recarga
  Future<void> clearCache() async {
    _experiences.clear();
    _allExperiences.clear();
    _userExperiences.clear();
    _rideExperiences.clear();
    _myReposts.clear();
    _hasMorePosts = true;
    _error = null;
    notifyListeners();
  }

  /// Carga experiencias de un usuario específico
  Future<void> loadUserExperiences(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await RetryService.run(
        () => _repository.getUserExperiences(userId),
      );
      _setUserExperiences(experiences);
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene una experiencia específica por ID
  Future<ExperienceEntity?> getExperienceById(String experienceId) async {
    try {
      AppLogger.debug(
        'Cargando experiencia: $experienceId',
        tag: 'ExperienceProvider',
      );
      final experience = await _repository.getExperienceById(experienceId);
      return experience;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error cargando experiencia',
        tag: 'ExperienceProvider',
        error: e,
      );
      _setError('Error cargando experiencia: ${e.toString()}');
      return null;
    }
  }

  /// Carga experiencias de una rodada específica
  Future<void> loadRideExperiences(String rideId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await RetryService.run(
        () => _repository.getRideExperiences(rideId),
      );
      _setRideExperiences(experiences);
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Carga experiencias de usuarios seguidos
  Future<void> loadFollowingExperiences(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      final experiences = await RetryService.run(
        () => _repository.getFollowingExperiences(userId),
      );
      _setExperiences(experiences);
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Carga el feed personalizado que incluye:
  /// - Los grupos que sigo
  /// - Mis publicaciones
  /// - Las publicaciones de los perfiles que sigo
  Future<void> loadPersonalizedFeed(String userId) async {
    // No recargar el feed mientras se está creando una experiencia
    // para evitar que el resultado de la query (que no incluye la nueva experiencia)
    // sobreescriba la lista local que sí la contiene.
    if (_isCreating) return;

    try {
      _setLoading(true);
      _error = null;
      _hasMorePosts = true; // Reset paginación

      // Cargar experiencias del usuario actual (mis publicaciones)
      final myExperiences = await _repository.getUserExperiences(userId);

      // Cargar experiencias de usuarios seguidos (o descubrimiento si no hay seguidos)
      final followingExperiences = await _repository.getFollowingExperiences(
        userId,
      );

      // Combinar todas las experiencias y ordenar por fecha (más recientes primero)
      final allExperiences = [...myExperiences, ...followingExperiences];
      allExperiences.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 🎯 LÓGICA: Si followingExperiences tiene posts, probablemente sea descubrimiento
      // (porque el usuario tiene 0 seguidos). En ese caso, no aplicar filtros tan estrictos
      final isDiscovery =
          followingExperiences.isNotEmpty && myExperiences.isEmpty;

      // ✅ FILTRO TEMPORAL: Solo publicaciones de las Ãºltimas 72 horas (excepto descubrimiento)
      if (!isDiscovery) {
        final cutoff = DateTime.now().subtract(const Duration(hours: 72));
        allExperiences.removeWhere((exp) => exp.createdAt.isBefore(cutoff));
      }

      // ✅ FILTRADO: Solo posts con media válida
      final validExperiences = <ExperienceEntity>[];
      for (var exp in allExperiences) {
        // ignore: unnecessary_null_comparison
        if (exp.media == null || exp.media.isEmpty) continue;

        bool allUrlsValid = true;
        for (final media in exp.media) {
          final url = media.url.trim();
          // Validación básica: URL debe ser HTTP/HTTPS y no estar vacía
          if (url.isEmpty ||
              (!url.startsWith('http://') && !url.startsWith('https://'))) {
            allUrlsValid = false;
            break;
          }

          // En descubrimiento, solo validar que no sea URL corrupta
          if (isDiscovery) {
            if (url.contains('placeholder') ||
                url.contains('null') ||
                url.toLowerCase().contains('error')) {
              allUrlsValid = false;
              break;
            }
          } else {
            // En feed personalizado, aplicar validaciones estrictas
            if (url.contains('placeholder') ||
                url.contains('null') ||
                url.toLowerCase().contains('error') ||
                url.toLowerCase().contains('broken') ||
                url.toLowerCase().contains('404') ||
                url.length < 20) {
              allUrlsValid = false;
              break;
            }
          }
        }
        if (allUrlsValid) {
          validExperiences.add(exp);
        }
      }

      // Actualizar timestamp conocido para detección de contenido nuevo
      if (validExperiences.isNotEmpty) {
        _latestKnownTimestamp = validExperiences.first.createdAt;
      }

      // Guardar todos los posts disponibles para paginación
      _allExperiences = validExperiences;

      // 🎯 SI EL FEED ESTÁ VACÍO, CARGAR POSTS DE DESCUBRIMIENTO
      if (_allExperiences.isEmpty) {
        debugPrint(
          '[ExperienceProvider] Feed vacío después de filtrar, usando lo disponible',
        );
      }

      // Cargar posts iniciales
      final initialPosts = _allExperiences.take(_initialPostsCount).toList();
      _hasMorePosts = _allExperiences.length > _initialPostsCount;

      _setExperiences(initialPosts);
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
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

      // Obtener los siguientes posts de la lista completa ya cargada
      final currentLength = _experiences.length;
      final newPosts = _allExperiences
          .skip(currentLength)
          .take(_postsPerPage)
          .toList();

      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        _experiences.addAll(newPosts);
        _hasMorePosts = _experiences.length < _allExperiences.length;
        notifyListeners();
      }
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Crea una nueva experiencia
  Future<bool> createExperience(CreateExperienceRequest request) async {
    try {
      _isCreating = true;
      _error = null;

      final newExperience = await _repository.createExperience(request);

      // Recargar experiencias después de crear una nueva
      _refreshAfterCreate(newExperience);
      return true;
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
      return false;
    } finally {
      _isCreating = false;
    }
  }

  /// Elimina una experiencia
  Future<bool> deleteExperience(String experienceId) async {
    // Remover de las listas locales inmediatamente (optimistic UI)
    _removeExperienceFromLists(experienceId);

    try {
      await _repository.deleteExperience(experienceId);
      return true;
    } on FirebaseException catch (e) {
      return false;
    }
  }

  /// Elimina un media individual de una experiencia
  /// Retorna true si se eliminó la experiencia completa, false si solo se eliminó la foto
  Future<bool> removeMediaFromExperience(
    String experienceId,
    int mediaIndex,
  ) async {
    // Buscar la experiencia en las listas locales para saber cuántos media tiene
    ExperienceEntity? exp;
    for (final list in [
      _experiences,
      _allExperiences,
      _userExperiences,
      _rideExperiences,
    ]) {
      final idx = list.indexWhere((e) => e.id == experienceId);
      if (idx != -1) {
        exp = list[idx];
        break;
      }
    }
    final willDeleteEntire = exp == null || exp.media.length <= 1;

    // Optimistic UI: actualizar listas locales inmediatamente
    if (willDeleteEntire) {
      _removeExperienceFromLists(experienceId);
    } else {
      _removeMediaFromExperienceInLists(experienceId, mediaIndex);
    }

    // Eliminar en segundo plano
    try {
      await _repository.removeMediaFromExperience(experienceId, mediaIndex);
      return willDeleteEntire;
    } on FirebaseException catch (e) {
      return false;
    }
  }

  /// Actualiza una experiencia
  Future<bool> updateExperience(
    String experienceId, {
    required String description,
    List<CreateMediaRequest>? newMediaFiles,
    List<String>? existingMediaUrls,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _repository.updateExperience(
        experienceId,
        description: description,
        isEdited: true,
        newMediaFiles: newMediaFiles,
        existingMediaUrls: existingMediaUrls,
      );

      // Actualizar en las listas locales
      _updateExperienceInLists(experienceId, description);
      return true;
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
      debugPrint('Firebase error updating experience: ${e.toString()}');
      return false;
    } catch (e) {
      _setError('exp_create_error_updating');
      debugPrint('Error updating experience: ${e.toString()}');
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
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
      return false;
    }
  }

  /// Elimina una reacción de una experiencia
  Future<bool> removeReaction(String experienceId) async {
    try {
      await _repository.removeReaction(experienceId);
      return true;
    } on FirebaseException catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
      return false;
    }
  }

  /// Marca una experiencia como vista
  Future<void> markAsViewed(String experienceId) async {
    try {
      await _repository.markAsViewed(experienceId);
    } on FirebaseException catch (e) {
      // Error silencioso para las visualizaciones
      AppLogger.warning(
        'Error marcando como vista',
        error: e,
        tag: 'ExperienceProvider',
      );
    }
  }

  /// Registra al usuario actual como viewer de una historia
  Future<void> recordStoryView(String experienceId, UserEntity viewer) async {
    try {
      await _repository.addViewer(experienceId, viewer);
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error registrando viewer',
        error: e,
        tag: 'ExperienceProvider',
      );
    }
  }

  /// Retorna un stream en tiempo real de los viewers de una historia
  Stream<List<UserEntity>> watchViewers(String experienceId) {
    return _repository.watchViewers(experienceId);
  }

  /// Repostea una historia en el perfil del usuario actual
  Future<void> repostStory(
    ExperienceEntity original, {
    String caption = '',
  }) async {
    try {
      await _repository.repostExperience(original, caption: caption);
      // Invalidar cache de reposts para que se recargue la próxima vez
      _myReposts.remove('_loaded');
    } catch (e) {
      debugPrint('Error reposteando historia: ${e.toString()}');
      _setError('error_reposting');
      rethrow;
    }
  }

  /// Carga los reposts del usuario actual desde Firestore
  Future<void> loadMyReposts(String userId) async {
    try {
      debugPrint('[ExperienceProvider] Cargando reposts del usuario: $userId');

      _myReposts = await _repository.getUserReposts(userId);
      _myReposts['_loaded'] = 'true'; // marca para no recargar

      debugPrint(
        '[ExperienceProvider] ✅ Reposts cargados: ${_myReposts.length - 1} reposts',
      );
      debugPrint('[ExperienceProvider] Reposts del usuario: $_myReposts');

      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint(
        '[ExperienceProvider] ❌ FirebaseException cargando reposts: $e',
      );
      _setError('error_loading_reposts');
    } catch (e, st) {
      debugPrint('[ExperienceProvider] ❌ Error cargando reposts: $e');
      debugPrint('[ExperienceProvider] Stack trace: $st');
      _setError('error_loading_reposts');
    }
  }

  /// Verifica si el usuario ya reposteó el post con ese ID
  bool hasRepostedPost(String postId) {
    final result = _myReposts.containsKey(postId);
    debugPrint('[ExperienceProvider] hasRepostedPost($postId) = $result');
    if (!result) {
      debugPrint(
        '[ExperienceProvider] Claves en _myReposts: ${_myReposts.keys.toList()}',
      );
    }
    return result;
  }

  /// Elimina el repost del usuario actual para un post original
  Future<void> removeRepost(String originalPostId) async {
    final repostId = _myReposts[originalPostId];
    if (repostId == null) return;
    try {
      await deleteExperience(repostId);
      _myReposts.remove(originalPostId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error eliminando repost: $e');
      rethrow;
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Inicia el listener en tiempo real para detectar contenido nuevo
  void startFeedListener(String userId) {
    _currentFeedUserId = userId;
    _feedStreamSubscription?.cancel();
    _feedStreamSubscription = _repository
        .watchLatestExperienceTimestamp()
        .listen((latestTimestamp) {
          if (latestTimestamp == null) return;
          if (_latestKnownTimestamp == null ||
              latestTimestamp.isAfter(_latestKnownTimestamp!)) {
            // Hay contenido nuevo, recargar feed silenciosamente
            if (!_isLoading && _currentFeedUserId != null) {
              loadPersonalizedFeed(_currentFeedUserId!);
            }
          }
        });
  }

  /// Detiene el listener en tiempo real
  void stopFeedListener() {
    _feedStreamSubscription?.cancel();
    _feedStreamSubscription = null;
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
    stopFeedListener();
    notifyListeners();
  }

  @override
  void dispose() {
    stopFeedListener();
    super.dispose();
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
    // Agregar a la lista general (y a _allExperiences para que no se pierda en paginación)
    _experiences = [newExperience, ..._experiences];
    _allExperiences = [newExperience, ..._allExperiences];

    // Agregar a experiencias de usuario si corresponde
    _userExperiences = [newExperience, ..._userExperiences];

    // Agregar a experiencias de rodada si corresponde
    if (newExperience.rideId != null) {
      _rideExperiences = [newExperience, ..._rideExperiences];
    }

    notifyListeners();
  }

  void _updateExperienceInLists(String experienceId, String newDescription) {
    // Actualizar en _experiences
    for (int i = 0; i < _experiences.length; i++) {
      if (_experiences[i].id == experienceId) {
        _experiences[i] = _experiences[i].copyWith(
          description: newDescription,
          isEdited: true,
        );
      }
    }

    // Actualizar en _userExperiences
    for (int i = 0; i < _userExperiences.length; i++) {
      if (_userExperiences[i].id == experienceId) {
        _userExperiences[i] = _userExperiences[i].copyWith(
          description: newDescription,
          isEdited: true,
        );
      }
    }

    // Actualizar en _rideExperiences
    for (int i = 0; i < _rideExperiences.length; i++) {
      if (_rideExperiences[i].id == experienceId) {
        _rideExperiences[i] = _rideExperiences[i].copyWith(
          description: newDescription,
          isEdited: true,
        );
      }
    }

    notifyListeners();
  }

  void _removeExperienceFromLists(String experienceId) {
    _allExperiences.removeWhere((exp) => exp.id == experienceId);
    _experiences.removeWhere((exp) => exp.id == experienceId);
    _userExperiences.removeWhere((exp) => exp.id == experienceId);
    _rideExperiences.removeWhere((exp) => exp.id == experienceId);
    // Si el item eliminado era un repost, limpiar la entrada en _myReposts
    _myReposts.removeWhere((_, repostId) => repostId == experienceId);
    notifyListeners();
  }

  void _removeMediaFromExperienceInLists(String experienceId, int mediaIndex) {
    for (final list in [
      _allExperiences,
      _experiences,
      _userExperiences,
      _rideExperiences,
    ]) {
      final idx = list.indexWhere((exp) => exp.id == experienceId);
      if (idx != -1) {
        final exp = list[idx];
        final updatedMedia = List<ExperienceMediaEntity>.from(exp.media)
          ..removeAt(mediaIndex);
        list[idx] = exp.copyWith(media: updatedMedia);
      }
    }
    notifyListeners();
  }
}
