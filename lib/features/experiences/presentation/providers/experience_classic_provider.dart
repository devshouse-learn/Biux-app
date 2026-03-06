import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';
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
  static const int _postsPerPage =
      20; // Posts por página (aumentado para mejor UX)
  static const int _initialPostsCount =
      15; // Posts iniciales (suficientes para pantalla completa)

  // Stream para detectar contenido nuevo en tiempo real
  StreamSubscription<DateTime?>? _feedStreamSubscription;
  DateTime? _latestKnownTimestamp;
  String? _currentFeedUserId;

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

      final experiences = await RetryService.run(
        () => _repository.getUserExperiences(userId),
      );
      _setUserExperiences(experiences);
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    try {
      _setLoading(true);
      _error = null;
      _hasMorePosts = true; // Reset paginación

      // Cargar experiencias del usuario actual (mis publicaciones)
      final myExperiences = await _repository.getUserExperiences(userId);

      // Cargar experiencias de usuarios seguidos
      final followingExperiences = await _repository.getFollowingExperiences(
        userId,
      );

      // Combinar todas las experiencias y ordenar por fecha (más recientes primero)
      final allExperiences = [...myExperiences, ...followingExperiences];
      allExperiences.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // ✅ FILTRO TEMPORAL: Solo publicaciones de las últimas 72 horas
      final cutoff = DateTime.now().subtract(const Duration(hours: 72));
      allExperiences.removeWhere((exp) => exp.createdAt.isBefore(cutoff));

      // ✅ FILTRADO: Solo posts con media realmente válida (imágenes y videos)
      final validExperiences = <ExperienceEntity>[];
      for (var exp in allExperiences) {
        // ignore: unnecessary_null_comparison
        if (exp.media == null || exp.media.isEmpty) continue;

        bool allUrlsValid = true;
        for (final media in exp.media) {
          final url = media.url.trim();
          if (url.isEmpty ||
              (!url.startsWith('http://') && !url.startsWith('https://'))) {
            allUrlsValid = false;
            break;
          }
          // Validaciones de contenido corrupto
          if (url.contains('placeholder') ||
              url.contains('null') ||
              url.toLowerCase().contains('error') ||
              url.toLowerCase().contains('broken') ||
              url.toLowerCase().contains('404') ||
              url.length < 20) {
            allUrlsValid = false;
            break;
          }
          // Para imágenes: validar extensiones de imagen
          if (media.mediaType == MediaType.image) {
            if (!url.contains('alt=') &&
                !url.contains('.jpg') &&
                !url.contains('.jpeg') &&
                !url.contains('.png') &&
                !url.contains('.gif') &&
                !url.contains('.webp')) {
              allUrlsValid = false;
              break;
            }
          }
          // Para videos: validar que tenga URL de video o thumbnail válido
          if (media.mediaType == MediaType.video) {
            final thumb = media.thumbnailUrl?.trim() ?? '';
            final hasValidVideo =
                url.contains('.mp4') ||
                url.contains('.mov') ||
                url.contains('.avi') ||
                url.contains('.webm') ||
                url.contains('.3gp') ||
                url.contains('alt=') ||
                url.contains('firebasestorage');
            final hasValidThumb =
                thumb.isNotEmpty &&
                thumb.startsWith('http') &&
                thumb.length >= 20;
            if (!hasValidVideo && !hasValidThumb) {
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

      // Cargar posts iniciales (suficientes para llenar pantalla)
      final initialPosts = validExperiences.take(_initialPostsCount).toList();
      _hasMorePosts = validExperiences.length > _initialPostsCount;

      _setExperiences(initialPosts);
    } catch (e) {
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
    } catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
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
      _setError(ErrorHandler.getUserMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina una experiencia
  Future<bool> deleteExperience(String experienceId) async {
    // Remover de las listas locales inmediatamente (optimistic UI)
    _removeExperienceFromLists(experienceId);

    try {
      await _repository.deleteExperience(experienceId);
      return true;
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
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
      _setError(ErrorHandler.getUserMessage(e));
      return false;
    }
  }

  /// Elimina una reacción de una experiencia
  Future<bool> removeReaction(String experienceId) async {
    try {
      await _repository.removeReaction(experienceId);
      return true;
    } catch (e) {
      _setError(ErrorHandler.getUserMessage(e));
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
