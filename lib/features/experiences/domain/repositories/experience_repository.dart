import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Repository abstracto para la gestión de experiencias
abstract class ExperienceRepository {
  /// Obtiene una experiencia por su ID
  Future<ExperienceEntity?> getExperienceById(String experienceId);

  /// Obtiene todas las experiencias del usuario actual
  Future<List<ExperienceEntity>> getUserExperiences(String userId);

  /// Obtiene experiencias de una rodada específica
  Future<List<ExperienceEntity>> getRideExperiences(String rideId);

  /// Obtiene experiencias de usuarios que sigue el usuario actual
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId);

  /// Crea una nueva experiencia
  Future<ExperienceEntity> createExperience(CreateExperienceRequest request);

  /// Actualiza una experiencia existente
  Future<void> updateExperience(
    String experienceId, {
    required String description,
    bool isEdited = true,
    List<CreateMediaRequest>? newMediaFiles,
    List<String>? existingMediaUrls,
  });

  /// Elimina una experiencia
  Future<void> deleteExperience(String experienceId);

  /// Elimina un media individual de una experiencia (si es el último, elimina la experiencia)
  Future<bool> removeMediaFromExperience(String experienceId, int mediaIndex);

  /// Agrega una reacción a una experiencia
  Future<void> addReaction(String experienceId, ReactionType reaction);

  /// Elimina una reacción de una experiencia
  Future<void> removeReaction(String experienceId);

  /// Marca una experiencia como vista
  Future<void> markAsViewed(String experienceId);

  /// Agrega el usuario actual a la lista de viewers de una experiencia
  Future<void> addViewer(String experienceId, UserEntity viewer);

  /// Observa en tiempo real la lista de viewers de una experiencia
  Stream<List<UserEntity>> watchViewers(String experienceId);

  /// Repostea una experiencia en el perfil del usuario actual
  Future<void> repostExperience(ExperienceEntity original, {String caption});

  /// Obtiene los reposts del usuario: mapa de { originalStoryId → repostExperienceId }
  Future<Map<String, String>> getUserReposts(String userId);

  /// Observa cambios en la colección de experiencias (última publicación)
  Stream<DateTime?> watchLatestExperienceTimestamp();

  /// Sube un archivo multimedia y retorna la URL
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  });
}

/// Request para crear una nueva experiencia
class CreateExperienceRequest {
  final String description;
  final List<String> tags;
  final List<CreateMediaRequest> mediaFiles;
  final ExperienceType type;
  final ExperienceFormat format;
  final String? rideId;

  const CreateExperienceRequest({
    required this.description,
    required this.tags,
    required this.mediaFiles,
    required this.type,
    this.format = ExperienceFormat.post,
    this.rideId,
  });

  /// Crear copia con campos modificados
  CreateExperienceRequest copyWith({
    String? description,
    List<String>? tags,
    List<CreateMediaRequest>? mediaFiles,
    ExperienceType? type,
    ExperienceFormat? format,
    String? rideId,
  }) {
    return CreateExperienceRequest(
      description: description ?? this.description,
      tags: tags ?? this.tags,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      type: type ?? this.type,
      format: format ?? this.format,
      rideId: rideId ?? this.rideId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateExperienceRequest &&
        other.description == description &&
        other.tags.toString() == tags.toString() &&
        other.mediaFiles.toString() == mediaFiles.toString() &&
        other.type == type &&
        other.format == format &&
        other.rideId == rideId;
  }

  @override
  int get hashCode {
    return description.hashCode ^
        tags.hashCode ^
        mediaFiles.hashCode ^
        type.hashCode ^
        format.hashCode ^
        rideId.hashCode;
  }

  @override
  String toString() {
    return 'CreateExperienceRequest(description: $description, tags: $tags, mediaFiles: $mediaFiles, type: $type, format: $format, rideId: $rideId)';
  }
}

/// Request para crear un archivo multimedia
class CreateMediaRequest {
  final String filePath;
  final MediaType mediaType;
  final int duration;
  final double? aspectRatio;
  final String? description;

  const CreateMediaRequest({
    required this.filePath,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.description,
  });

  /// Crear copia con campos modificados
  CreateMediaRequest copyWith({
    String? filePath,
    MediaType? mediaType,
    int? duration,
    double? aspectRatio,
    String? description,
  }) {
    return CreateMediaRequest(
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateMediaRequest &&
        other.filePath == filePath &&
        other.mediaType == mediaType &&
        other.duration == duration &&
        other.aspectRatio == aspectRatio &&
        other.description == description;
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        mediaType.hashCode ^
        duration.hashCode ^
        aspectRatio.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'CreateMediaRequest(filePath: $filePath, mediaType: $mediaType, duration: $duration, aspectRatio: $aspectRatio, description: $description)';
  }
}
