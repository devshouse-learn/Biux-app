import 'package:flutter/foundation.dart';
import 'package:biux/features/experiences/domain/entities/user_story_group_entity.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/usecases/group_stories_by_user_usecase.dart';
import 'package:biux/features/experiences/data/datasources/story_views_local_service.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';

/// Provider para gestionar historias agrupadas por usuario (estilo Instagram)
/// Maneja el estado de visualización de manera local para evitar consumo de red
class StoryGroupsProvider with ChangeNotifier {
  final ExperienceRepository _repository;
  final GroupStoriesByUserUseCase _groupStoriesUseCase;
  final StoryViewsLocalService _viewsService;

  // Estado
  List<UserStoryGroupEntity> _storyGroups = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<UserStoryGroupEntity> get storyGroups => _storyGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnseenStories => _storyGroups.any((g) => g.hasUnseenStories);
  int get totalUnseenCount => _storyGroups.fold(
    0,
    (sum, group) => sum + (group.hasUnseenStories ? group.unseenCount : 0),
  );

  StoryGroupsProvider(
    this._repository,
    this._groupStoriesUseCase,
    this._viewsService,
  );

  /// Carga las historias de usuarios seguidos y las agrupa
  Future<void> loadStoryGroups(String currentUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar experiencias de usuarios seguidos
      final experiences = await _repository.getFollowingExperiences(
        currentUserId,
      );

      // Filtrar y agrupar solo historias recientes (últimas 24 horas)
      final storyGroups = await _groupStoriesUseCase.callForRecentStories(
        experiences,
        timeLimit: const Duration(hours: 24),
      );

      _storyGroups = storyGroups;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar historias: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Agrupa experiencias existentes sin cargar de red
  /// Útil para agrupar experiencias que ya están en memoria
  Future<void> groupExistingStories(List<ExperienceEntity> experiences) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Filtrar y agrupar historias recientes (últimas 24 horas)
      final storyGroups = await _groupStoriesUseCase.callForRecentStories(
        experiences,
        timeLimit: const Duration(hours: 24),
      );

      _storyGroups = storyGroups;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al agrupar historias: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marca una historia como vista localmente
  Future<void> markStoryAsViewed(String storyId) async {
    await _viewsService.markStoryAsViewed(storyId);

    // Actualizar el estado local de los grupos
    await _refreshGroupsViewStatus();
  }

  /// Marca todas las historias de un usuario como vistas
  Future<void> markUserStoriesAsViewed(String userId) async {
    final userGroup = _storyGroups.where((group) => group.userId == userId);

    if (userGroup.isEmpty) return;

    final storyIds = userGroup.first.stories.map((s) => s.id).toList();
    await _viewsService.markStoriesAsViewed(storyIds);

    // Actualizar el estado local
    await _refreshGroupsViewStatus();
  }

  /// Verifica si una historia específica fue vista
  Future<bool> isStoryViewed(String storyId) async {
    return await _viewsService.isStoryViewed(storyId);
  }

  /// Obtiene el grupo de historias de un usuario específico
  UserStoryGroupEntity? getGroupByUserId(String userId) {
    try {
      return _storyGroups.firstWhere((group) => group.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Refresca el estado de visualización de los grupos sin recargar de red
  Future<void> _refreshGroupsViewStatus() async {
    if (_storyGroups.isEmpty) return;

    final updatedGroups = <UserStoryGroupEntity>[];

    for (final group in _storyGroups) {
      // Verificar estado de visualización de cada historia del grupo
      final storyIds = group.stories.map((s) => s.id).toList();
      final viewedStatus = await _viewsService.areStoriesViewed(storyIds);

      // Calcular historias no vistas
      int unseenCount = 0;
      for (final storyId in storyIds) {
        if (viewedStatus[storyId] == false) {
          unseenCount++;
        }
      }

      final hasUnseenStories = unseenCount > 0;

      // Actualizar el grupo
      final updatedGroup = group.copyWith(
        hasUnseenStories: hasUnseenStories,
        unseenCount: unseenCount,
      );

      updatedGroups.add(updatedGroup);
    }

    // Reordenar: no vistas primero
    updatedGroups.sort((a, b) {
      if (a.hasUnseenStories && !b.hasUnseenStories) {
        return -1;
      } else if (!a.hasUnseenStories && b.hasUnseenStories) {
        return 1;
      }
      return b.latestStoryTime.compareTo(a.latestStoryTime);
    });

    _storyGroups = updatedGroups;
    notifyListeners();
  }

  /// Limpia todas las vistas locales (útil para logout o debugging)
  Future<void> clearAllViews() async {
    await _viewsService.clearAllViews();
    await _refreshGroupsViewStatus();
  }

  /// Limpia las vistas expiradas (automático cada 6 horas)
  Future<void> cleanupExpiredViews() async {
    await _viewsService.cleanupExpiredViews();
    await _refreshGroupsViewStatus();
  }

  /// Agrega una nueva experiencia y actualiza los grupos
  Future<void> addNewExperience(ExperienceEntity experience) async {
    // Si la experiencia es formato story y es reciente
    if (experience.isStoryFormat) {
      final now = DateTime.now();
      final timeDifference = now.difference(experience.createdAt);

      if (timeDifference <= const Duration(hours: 24)) {
        // Buscar si ya existe un grupo para este usuario
        final existingGroupIndex = _storyGroups.indexWhere(
          (group) => group.userId == experience.user.id,
        );

        if (existingGroupIndex != -1) {
          // Agregar a grupo existente
          final existingGroup = _storyGroups[existingGroupIndex];
          final updatedStories = [experience, ...existingGroup.stories];

          final updatedGroup = existingGroup.copyWith(
            stories: updatedStories,
            latestStoryTime: experience.createdAt,
            hasUnseenStories: true,
            unseenCount: existingGroup.unseenCount + 1,
          );

          _storyGroups[existingGroupIndex] = updatedGroup;
        } else {
          // Crear nuevo grupo
          final newGroup = UserStoryGroupEntity(
            user: experience.user,
            stories: [experience],
            latestStoryTime: experience.createdAt,
            hasUnseenStories: true,
            unseenCount: 1,
          );

          _storyGroups = [newGroup, ..._storyGroups];
        }

        // Reordenar grupos
        _storyGroups.sort((a, b) {
          if (a.hasUnseenStories && !b.hasUnseenStories) {
            return -1;
          } else if (!a.hasUnseenStories && b.hasUnseenStories) {
            return 1;
          }
          return b.latestStoryTime.compareTo(a.latestStoryTime);
        });

        notifyListeners();
      }
    }
  }

  /// Elimina una experiencia de los grupos
  void removeExperience(String experienceId) {
    final updatedGroups = <UserStoryGroupEntity>[];

    for (final group in _storyGroups) {
      final updatedStories = group.stories
          .where((story) => story.id != experienceId)
          .toList();

      // Si quedan historias en el grupo, mantenerlo
      if (updatedStories.isNotEmpty) {
        final updatedGroup = group.copyWith(stories: updatedStories);
        updatedGroups.add(updatedGroup);
      }
      // Si no quedan historias, el grupo se elimina automáticamente
    }

    _storyGroups = updatedGroups;
    notifyListeners();
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reinicia el estado
  void reset() {
    _storyGroups = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
