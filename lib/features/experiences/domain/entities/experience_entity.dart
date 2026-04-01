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
  final ExperienceFormat format;
  final String? rideId; // Solo para experiencias de rodadas
  final int views;
  final List<ExperienceReactionEntity> reactions;
  final List<UserEntity> viewers; // Usuarios que han visto la historia
  final bool isEdited;
  final bool isRepost;
  final String? originalAuthorUserName;
  final String? originalAuthorId;

  const ExperienceEntity({
    required this.id,
    required this.description,
    required this.tags,
    required this.user,
    required this.createdAt,
    required this.media,
    required this.type,
    this.format = ExperienceFormat.post,
    this.rideId,
    this.views = 0,
    this.reactions = const [],
    this.viewers = const [],
    this.isEdited = false,
    this.isRepost = false,
    this.originalAuthorUserName,
    this.originalAuthorId,
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

  /// Verifica si debe mostrarse como Story (contenido efímero en círculos arriba)
  bool get isStoryFormat {
    return format == ExperienceFormat.story;
  }

  /// Verifica si debe mostrarse como Post regular en feed vertical
  bool get isPostFormat {
    return format == ExperienceFormat.post;
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
    ExperienceFormat? format,
    String? rideId,
    int? views,
    List<ExperienceReactionEntity>? reactions,
    List<UserEntity>? viewers,
    bool? isEdited,
    bool? isRepost,
    String? originalAuthorUserName,
    String? originalAuthorId,
  }) {
    return ExperienceEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      media: media ?? this.media,
      type: type ?? this.type,
      format: format ?? this.format,
      rideId: rideId ?? this.rideId,
      views: views ?? this.views,
      reactions: reactions ?? this.reactions,
      viewers: viewers ?? this.viewers,
      isEdited: isEdited ?? this.isEdited,
      isRepost: isRepost ?? this.isRepost,
      originalAuthorUserName:
          originalAuthorUserName ?? this.originalAuthorUserName,
      originalAuthorId: originalAuthorId ?? this.originalAuthorId,
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
        other.format == format &&
        other.rideId == rideId &&
        other.views == views &&
        other.reactions.toString() == reactions.toString() &&
        other.viewers.toString() == viewers.toString() &&
        other.isEdited == isEdited;
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
        format.hashCode ^
        rideId.hashCode ^
        views.hashCode ^
        reactions.hashCode ^
        viewers.hashCode ^
        isEdited.hashCode;
  }

  @override
  String toString() {
    return 'ExperienceEntity(id: $id, description: $description, tags: $tags, user: $user, createdAt: $createdAt, media: $media, type: $type, format: $format, rideId: $rideId, views: $views, reactions: $reactions, viewers: $viewers, isEdited: $isEdited)';
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
  final String? description; // Descripción individual por imagen

  const ExperienceMediaEntity({
    required this.id,
    required this.url,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailUrl,
    this.description,
  });

  /// Crear copia con campos modificados
  ExperienceMediaEntity copyWith({
    String? id,
    String? url,
    MediaType? mediaType,
    int? duration,
    double? aspectRatio,
    String? thumbnailUrl,
    String? description,
  }) {
    return ExperienceMediaEntity(
      id: id ?? this.id,
      url: url ?? this.url,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
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
        other.thumbnailUrl == thumbnailUrl &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        url.hashCode ^
        mediaType.hashCode ^
        duration.hashCode ^
        aspectRatio.hashCode ^
        thumbnailUrl.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'ExperienceMediaEntity(id: $id, url: $url, mediaType: $mediaType, duration: $duration, aspectRatio: $aspectRatio, thumbnailUrl: $thumbnailUrl, description: $description)';
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

/// Formato de publicación: historia efímera o publicación permanente
enum ExperienceFormat {
  story, // Historia efímera (círculos arriba)
  post, // Publicación permanente (perfil + feed)
}

/// Tipos de medios soportados
enum MediaType { image, video }

/// Tipos de reacciones
enum ReactionType { like, love, laugh, wow, sad, angry }
