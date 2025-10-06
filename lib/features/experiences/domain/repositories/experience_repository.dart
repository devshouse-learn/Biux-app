import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';

part 'experience_repository.freezed.dart';

/// Repository abstracto para la gestión de experiencias
abstract class ExperienceRepository {
  /// Obtiene todas las experiencias del usuario actual
  Future<List<ExperienceEntity>> getUserExperiences(String userId);

  /// Obtiene experiencias de una rodada específica
  Future<List<ExperienceEntity>> getRideExperiences(String rideId);

  /// Obtiene experiencias de usuarios que sigue el usuario actual
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId);

  /// Crea una nueva experiencia
  Future<ExperienceEntity> createExperience(CreateExperienceRequest request);

  /// Elimina una experiencia
  Future<void> deleteExperience(String experienceId);

  /// Agrega una reacción a una experiencia
  Future<void> addReaction(String experienceId, ReactionType reaction);

  /// Elimina una reacción de una experiencia
  Future<void> removeReaction(String experienceId);

  /// Marca una experiencia como vista
  Future<void> markAsViewed(String experienceId);

  /// Sube un archivo multimedia y retorna la URL
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  });
}

/// Request para crear una nueva experiencia
@freezed
class CreateExperienceRequest with _$CreateExperienceRequest {
  const factory CreateExperienceRequest({
    required String description,
    required List<String> tags,
    required List<CreateMediaRequest> mediaFiles,
    required ExperienceType type,
    String? rideId,
  }) = _CreateExperienceRequest;
}

/// Request para crear un archivo multimedia
@freezed
class CreateMediaRequest with _$CreateMediaRequest {
  const factory CreateMediaRequest({
    required String filePath,
    required MediaType mediaType,
    required int duration,
    double? aspectRatio,
  }) = _CreateMediaRequest;
}
