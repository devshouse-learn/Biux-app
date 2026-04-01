import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Modelo de datos para Experience con JSON serialization
class ExperienceModel {
  final String id;
  final String description;
  final List<String> tags;
  final UserModel user;
  final DateTime createdAt;
  final List<ExperienceMediaModel> media;
  final ExperienceType type;
  final ExperienceFormat format;
  final String? rideId;
  final int views;
  final List<ExperienceReactionModel> reactions;
  final List<UserModel> viewers;
  final bool isEdited;
  final bool isRepost;
  final String? originalAuthorUserName;
  final String? originalAuthorId;

  const ExperienceModel({
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

  /// Convertir a entidad de dominio
  ExperienceEntity toEntity() {
    return ExperienceEntity(
      id: id,
      description: description,
      tags: tags,
      user: user.toEntity(),
      createdAt: createdAt,
      media: media.map((e) => e.toEntity()).toList(),
      type: type,
      format: format,
      rideId: rideId,
      views: views,
      reactions: reactions.map((e) => e.toEntity()).toList(),
      viewers: viewers.map((e) => e.toEntity()).toList(),
      isEdited: isEdited,
      isRepost: isRepost,
      originalAuthorUserName: originalAuthorUserName,
      originalAuthorId: originalAuthorId,
    );
  }

  factory ExperienceModel.fromEntity(ExperienceEntity entity) {
    return ExperienceModel(
      id: entity.id,
      description: entity.description,
      tags: entity.tags,
      user: UserModel.fromEntity(entity.user),
      createdAt: entity.createdAt,
      media: entity.media
          .map((e) => ExperienceMediaModel.fromEntity(e))
          .toList(),
      type: entity.type,
      format: entity.format,
      rideId: entity.rideId,
      views: entity.views,
      reactions: entity.reactions
          .map((e) => ExperienceReactionModel.fromEntity(e))
          .toList(),
      viewers: entity.viewers.map((e) => UserModel.fromEntity(e)).toList(),
      isEdited: entity.isEdited,
      isRepost: entity.isRepost,
      originalAuthorUserName: entity.originalAuthorUserName,
      originalAuthorId: entity.originalAuthorId,
    );
  }

  /// Convertir a JSON - esto es lo que necesitamos que funcione correctamente
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'tags': tags,
      'user': user
          .toJson(), // Aquí está la llamada automática al toJson de UserModel
      'createdAt': createdAt.toIso8601String(),
      'media': media.map((e) => e.toJson()).toList(),
      'type': type.name,
      'format': format.name,
      'rideId': rideId,
      'views': views,
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'viewers': viewers.map((e) => e.toJson()).toList(),
      'isEdited': isEdited,
      'isRepost': isRepost,
      'originalAuthorUserName': originalAuthorUserName,
      'originalAuthorId': originalAuthorId,
    };
  }

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as String,
      description: json['description'] as String,
      tags: List<String>.from(json['tags'] as List),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: (json['media'] as List)
          .map((e) => ExperienceMediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: ExperienceType.values.firstWhere((e) => e.name == json['type']),
      format: _parseFormat(json),
      rideId: json['rideId'] as String?,
      views: json['views'] as int? ?? 0,
      reactions: (json['reactions'] as List? ?? [])
          .map(
            (e) => ExperienceReactionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      viewers: (json['viewers'] as List? ?? [])
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isEdited: json['isEdited'] as bool? ?? false,
      isRepost: json['isRepost'] as bool? ?? false,
      originalAuthorUserName:
          json['originalAuthorUserName'] as String? ??
          (json['originalAuthor'] as Map<String, dynamic>?)?['userName']
              as String?,
      originalAuthorId:
          json['originalAuthorId'] as String? ??
          (json['originalAuthor'] as Map<String, dynamic>?)?['id'] as String?,
    );
  }

  /// Parsea el formato desde JSON con compatibilidad hacia atrás.
  /// Solo documentos con campo 'format' explícito se clasifican como story.
  /// Documentos legacy sin el campo siempre se tratan como post.
  static ExperienceFormat _parseFormat(Map<String, dynamic> json) {
    final formatStr = json['format'] as String?;
    if (formatStr != null) {
      return ExperienceFormat.values.firstWhere(
        (e) => e.name == formatStr,
        orElse: () => ExperienceFormat.post,
      );
    }
    // Documentos legacy sin campo 'format' → siempre post
    // Backwards compatibility: documentos sin el campo 'format'
    // Solo clasificar como story si no tiene descripción alguna
    final description = json['description'] as String? ?? '';
    final media = json['media'] as List? ?? [];
    final typeStr = json['type'] as String? ?? 'general';
    if (media.isNotEmpty && description.trim().isEmpty && typeStr != 'ride') {
      return ExperienceFormat.story;
    }
    return ExperienceFormat.post;
  }
}

/// Modelo para archivos multimedia
class ExperienceMediaModel {
  final String id;
  final String url;
  final MediaType mediaType;
  final int duration;
  final double? aspectRatio;
  final String? thumbnailUrl;
  final String? description;

  const ExperienceMediaModel({
    required this.id,
    required this.url,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailUrl,
    this.description,
  });

  ExperienceMediaEntity toEntity() {
    return ExperienceMediaEntity(
      id: id,
      url: url,
      thumbnailUrl: thumbnailUrl,
      mediaType: mediaType,
      duration: duration,
      aspectRatio: aspectRatio,
      description: description,
    );
  }

  factory ExperienceMediaModel.fromEntity(ExperienceMediaEntity entity) {
    return ExperienceMediaModel(
      id: entity.id,
      url: entity.url,
      mediaType: entity.mediaType,
      duration: entity.duration,
      aspectRatio: entity.aspectRatio,
      thumbnailUrl: entity.thumbnailUrl,
      description: entity.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'mediaType': mediaType.name,
      'duration': duration,
      'aspectRatio': aspectRatio,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
    };
  }

  factory ExperienceMediaModel.fromJson(Map<String, dynamic> json) {
    return ExperienceMediaModel(
      id: json['id'] as String,
      url: json['url'] as String,
      mediaType: MediaType.values.firstWhere(
        (e) => e.name == json['mediaType'],
      ),
      duration: json['duration'] as int,
      aspectRatio: json['aspectRatio'] as double?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      description: json['description'] as String?,
    );
  }
}

/// Modelo para reacciones
class ExperienceReactionModel {
  final String id;
  final UserModel user;
  final ReactionType type;
  final DateTime createdAt;

  const ExperienceReactionModel({
    required this.id,
    required this.user,
    required this.type,
    required this.createdAt,
  });

  ExperienceReactionEntity toEntity() {
    return ExperienceReactionEntity(
      id: id,
      user: user.toEntity(),
      type: type,
      createdAt: createdAt,
    );
  }

  factory ExperienceReactionModel.fromEntity(ExperienceReactionEntity entity) {
    return ExperienceReactionModel(
      id: entity.id,
      user: UserModel.fromEntity(entity.user),
      type: entity.type,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(), // Aquí también se llama automáticamente
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExperienceReactionModel.fromJson(Map<String, dynamic> json) {
    return ExperienceReactionModel(
      id: json['id'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      type: ReactionType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Modelo para usuarios - compatible con UserEntity existente
class UserModel {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String photo;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.photo,
  });

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      fullName: fullName,
      userName: userName,
      email: email,
      photo: photo,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      userName: entity.userName,
      email: entity.email,
      photo: entity.photo,
    );
  }

  /// Este es el método toJson que se necesita para la serialización anidada
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'userName': userName,
      'email': email,
      'photo': photo,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      photo: json['photo'] as String,
    );
  }
}
