import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Entidad principal para las Experiencias (antes Historias)
/// Soporta imágenes y videos con funcionalidad tipo Instagram Stories
class ExperienceEntity {
  final String id;
  final String description;
  final List<String> tags;
  final UserEntity user;
  final DateTime createdAt;
  final List<ExperienceMediaEntity> media;
  final ExperienceType type;
  final String? rideId; // Solo para experiencias de rodadas
  final int views;
  final List<ExperienceReactionEntity> reactions;

  const ExperienceEntity({
    required this.id,
    required this.description,
    required this.tags,
    required this.user,
    required this.createdAt,
    required this.media,
    required this.type,
    this.rideId,
    this.views = 0,
    this.reactions = const [],
  });

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

  /// Crear copia con campos modificados
  ExperienceEntity copyWith({
    String? id,
    String? description,
    List<String>? tags,
    UserEntity? user,
    DateTime? createdAt,
    List<ExperienceMediaEntity>? media,
    ExperienceType? type,
    String? rideId,
    int? views,
    List<ExperienceReactionEntity>? reactions,
  }) {
    return ExperienceEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      media: media ?? this.media,
      type: type ?? this.type,
      rideId: rideId ?? this.rideId,
      views: views ?? this.views,
      reactions: reactions ?? this.reactions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExperienceEntity &&
        other.id == id &&
        other.description == description &&
        other.tags.toString() == tags.toString() &&
        other.user == user &&
        other.createdAt == createdAt &&
        other.media.toString() == media.toString() &&
        other.type == type &&
        other.rideId == rideId &&
        other.views == views &&
        other.reactions.toString() == reactions.toString();
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        tags.hashCode ^
        user.hashCode ^
        createdAt.hashCode ^
        media.hashCode ^
        type.hashCode ^
        rideId.hashCode ^
        views.hashCode ^
        reactions.hashCode;
  }

  @override
  String toString() {
    return 'ExperienceEntity(id: $id, description: $description, tags: $tags, user: $user, createdAt: $createdAt, media: $media, type: $type, rideId: $rideId, views: $views, reactions: $reactions)';
  }
}

/// Entidad para cada archivo multimedia en la experiencia
class ExperienceMediaEntity {
  final String id;
  final String url;
  final MediaType mediaType;
  final int duration; // En segundos
  final double? aspectRatio;
  final String? thumbnailUrl; // Para videos

  const ExperienceMediaEntity({
    required this.id,
    required this.url,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailUrl,
  });

  /// Crear copia con campos modificados
  ExperienceMediaEntity copyWith({
    String? id,
    String? url,
    MediaType? mediaType,
    int? duration,
    double? aspectRatio,
    String? thumbnailUrl,
  }) {
    return ExperienceMediaEntity(
      id: id ?? this.id,
      url: url ?? this.url,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExperienceMediaEntity &&
        other.id == id &&
        other.url == url &&
        other.mediaType == mediaType &&
        other.duration == duration &&
        other.aspectRatio == aspectRatio &&
        other.thumbnailUrl == thumbnailUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        url.hashCode ^
        mediaType.hashCode ^
        duration.hashCode ^
        aspectRatio.hashCode ^
        thumbnailUrl.hashCode;
  }

  @override
  String toString() {
    return 'ExperienceMediaEntity(id: $id, url: $url, mediaType: $mediaType, duration: $duration, aspectRatio: $aspectRatio, thumbnailUrl: $thumbnailUrl)';
  }
}

/// Entidad para reacciones en experiencias
class ExperienceReactionEntity {
  final String id;
  final UserEntity user;
  final ReactionType type;
  final DateTime createdAt;

  const ExperienceReactionEntity({
    required this.id,
    required this.user,
    required this.type,
    required this.createdAt,
  });

  /// Crear copia con campos modificados
  ExperienceReactionEntity copyWith({
    String? id,
    UserEntity? user,
    ReactionType? type,
    DateTime? createdAt,
  }) {
    return ExperienceReactionEntity(
      id: id ?? this.id,
      user: user ?? this.user,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExperienceReactionEntity &&
        other.id == id &&
        other.user == user &&
        other.type == type &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ user.hashCode ^ type.hashCode ^ createdAt.hashCode;
  }

  @override
  String toString() {
    return 'ExperienceReactionEntity(id: $id, user: $user, type: $type, createdAt: $createdAt)';
  }
}

/// Tipos de experiencias
enum ExperienceType {
  general, // Experiencias normales de usuarios
  ride, // Experiencias de rodadas (pueden tener videos)
}

/// Tipos de medios soportados
enum MediaType { image, video }

/// Tipos de reacciones
enum ReactionType { like, love, laugh, wow, sad, angry }
