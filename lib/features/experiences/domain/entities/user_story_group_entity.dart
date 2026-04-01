import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Agrupa las experiencias (stories) de un usuario específico
/// Similar a cómo Instagram agrupa las historias por usuario
class UserStoryGroupEntity {
  final UserEntity user;
  final List<ExperienceEntity> stories;
  final DateTime latestStoryTime;
  final bool hasUnseenStories;
  final int unseenCount;

  const UserStoryGroupEntity({
    required this.user,
    required this.stories,
    required this.latestStoryTime,
    required this.hasUnseenStories,
    this.unseenCount = 0,
  });

  /// Obtiene la primera historia no vista (si hay), sino la primera del grupo
  ExperienceEntity get firstStory => stories.first;

  /// Obtiene la URL de la foto de perfil del usuario
  String get userProfilePhoto => user.photo;

  /// Obtiene el nombre de usuario (@username)
  String get userName =>
      user.userName.isNotEmpty ? user.userName : user.fullName;

  /// Obtiene el ID del usuario
  String get userId => user.id;

  /// Verifica si todas las historias fueron vistas
  bool get allStoriesViewed => !hasUnseenStories;

  /// Obtiene el total de historias en este grupo
  int get totalStories => stories.length;

  /// Crea una copia con campos actualizados
  UserStoryGroupEntity copyWith({
    UserEntity? user,
    List<ExperienceEntity>? stories,
    DateTime? latestStoryTime,
    bool? hasUnseenStories,
    int? unseenCount,
  }) {
    return UserStoryGroupEntity(
      user: user ?? this.user,
      stories: stories ?? this.stories,
      latestStoryTime: latestStoryTime ?? this.latestStoryTime,
      hasUnseenStories: hasUnseenStories ?? this.hasUnseenStories,
      unseenCount: unseenCount ?? this.unseenCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStoryGroupEntity &&
        other.user == user &&
        other.stories.length == stories.length &&
        other.latestStoryTime == latestStoryTime &&
        other.hasUnseenStories == hasUnseenStories &&
        other.unseenCount == unseenCount;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        stories.length.hashCode ^
        latestStoryTime.hashCode ^
        hasUnseenStories.hashCode ^
        unseenCount.hashCode;
  }
}
