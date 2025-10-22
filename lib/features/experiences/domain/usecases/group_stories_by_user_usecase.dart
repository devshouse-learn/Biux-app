import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/entities/user_story_group_entity.dart';
import 'package:biux/features/experiences/data/datasources/story_views_local_service.dart';

/// Caso de uso para agrupar experiencias (stories) por usuario
/// Similar a cómo Instagram agrupa las historias en la parte superior
class GroupStoriesByUserUseCase {
  final StoryViewsLocalService _viewsService;

  GroupStoriesByUserUseCase(this._viewsService);

  /// Agrupa una lista de experiencias por usuario y calcula el estado de visualización
  ///
  /// Parámetros:
  /// - experiences: Lista de experiencias a agrupar
  ///
  /// Retorna:
  /// - Lista de UserStoryGroupEntity ordenada con no vistas primero
  Future<List<UserStoryGroupEntity>> call(
    List<ExperienceEntity> experiences,
  ) async {
    // Limpieza automática de vistas expiradas si es necesario
    await _viewsService.cleanupIfNeeded();

    // Agrupar experiencias por userId
    final Map<String, List<ExperienceEntity>> groupedByUser = {};

    for (final experience in experiences) {
      final userId = experience.user.id;

      if (!groupedByUser.containsKey(userId)) {
        groupedByUser[userId] = [];
      }

      groupedByUser[userId]!.add(experience);
    }

    // Crear grupos de historias con información de visualización
    final List<UserStoryGroupEntity> storyGroups = [];

    for (final entry in groupedByUser.entries) {
      final userStories = entry.value;

      // Ordenar historias del usuario por fecha (más antiguas primero para orden cronológico)
      userStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Obtener IDs de las historias para verificar visualización
      final storyIds = userStories.map((s) => s.id).toList();
      final viewedStatus = await _viewsService.areStoriesViewed(storyIds);

      // Calcular cuántas historias no han sido vistas
      int unseenCount = 0;
      for (final storyId in storyIds) {
        if (viewedStatus[storyId] == false) {
          unseenCount++;
        }
      }

      final hasUnseenStories = unseenCount > 0;

      // Obtener la hora de la historia más reciente (ahora es la última porque ordenamos cronológicamente)
      final latestStoryTime = userStories.last.createdAt;

      // Crear el grupo
      final group = UserStoryGroupEntity(
        user: userStories.first.user, // Todos tienen el mismo usuario
        stories: userStories,
        latestStoryTime: latestStoryTime,
        hasUnseenStories: hasUnseenStories,
        unseenCount: unseenCount,
      );

      storyGroups.add(group);
    }

    // Ordenar grupos: primero los que tienen historias no vistas,
    // luego por la hora de la historia más reciente
    storyGroups.sort((a, b) {
      // Primero ordenar por historias no vistas
      if (a.hasUnseenStories && !b.hasUnseenStories) {
        return -1; // a va primero
      } else if (!a.hasUnseenStories && b.hasUnseenStories) {
        return 1; // b va primero
      }

      // Si ambos tienen el mismo estado de visualización,
      // ordenar por hora más reciente
      return b.latestStoryTime.compareTo(a.latestStoryTime);
    });

    return storyGroups;
  }

  /// Filtra solo historias del tipo Story (formato corto con imágenes/videos)
  /// y excluye Posts regulares
  Future<List<UserStoryGroupEntity>> callForStoriesOnly(
    List<ExperienceEntity> experiences,
  ) async {
    // Filtrar solo experiencias en formato Story
    final storyFormatExperiences = experiences
        .where((exp) => exp.isStoryFormat)
        .toList();

    return await call(storyFormatExperiences);
  }

  /// Obtiene grupos de historias filtrados por periodo de tiempo
  /// Por defecto obtiene historias de las últimas 24 horas
  Future<List<UserStoryGroupEntity>> callForRecentStories(
    List<ExperienceEntity> experiences, {
    Duration timeLimit = const Duration(hours: 24),
  }) async {
    final now = DateTime.now();

    // Filtrar experiencias creadas dentro del período de tiempo
    final recentExperiences = experiences.where((exp) {
      final timeDifference = now.difference(exp.createdAt);
      return timeDifference <= timeLimit;
    }).toList();

    return await callForStoriesOnly(recentExperiences);
  }
}
