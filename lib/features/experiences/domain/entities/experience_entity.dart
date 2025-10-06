import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

part 'experience_entity.freezed.dart';

/// Entidad principal para las Experiencias (antes Historias)
/// Soporta imágenes y videos con funcionalidad tipo Instagram Stories
@freezed
class ExperienceEntity with _$ExperienceEntity {
  const factory ExperienceEntity({
    required String id,
    required String description,
    required List<String> tags,
    required UserEntity user,
    required DateTime createdAt,
    required List<ExperienceMediaEntity> media,
    required ExperienceType type,
    String? rideId, // Solo para experiencias de rodadas
    @Default(0) int views,
    @Default([]) List<ExperienceReactionEntity> reactions,
  }) = _ExperienceEntity;

  const ExperienceEntity._();

  /// Duración total de la experiencia en segundos
  int get totalDuration {
    return media.fold(0, (sum, item) => sum + item.duration);
  }

  /// Verifica si la experiencia tiene videos
  bool get hasVideo {
    return media.any((item) => item.mediaType == MediaType.video);
  }

  /// Verifica si es una experiencia de rodada
  bool get isRideExperience {
    return type == ExperienceType.ride && rideId != null;
  }
}

/// Entidad para cada archivo multimedia en la experiencia
@freezed
class ExperienceMediaEntity with _$ExperienceMediaEntity {
  const factory ExperienceMediaEntity({
    required String id,
    required String url,
    required MediaType mediaType,
    required int duration, // En segundos
    double? aspectRatio,
    String? thumbnailUrl, // Para videos
  }) = _ExperienceMediaEntity;
}

/// Entidad para reacciones en experiencias
@freezed
class ExperienceReactionEntity with _$ExperienceReactionEntity {
  const factory ExperienceReactionEntity({
    required String id,
    required UserEntity user,
    required ReactionType type,
    required DateTime createdAt,
  }) = _ExperienceReactionEntity;
}

/// Tipos de experiencias
enum ExperienceType {
  general, // Experiencias normales de usuarios
  ride,    // Experiencias de rodadas (pueden tener videos)
}

/// Tipos de medios soportados
enum MediaType {
  image,
  video,
}

/// Tipos de reacciones
enum ReactionType {
  like,
  love,
  laugh,
  wow,
  sad,
  angry,
}