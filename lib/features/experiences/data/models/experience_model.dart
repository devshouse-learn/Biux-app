import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

part 'experience_model.freezed.dart';
part 'experience_model.g.dart';

/// Modelo de datos para Experience con JSON serialization
@freezed
class ExperienceModel with _$ExperienceModel {
  const factory ExperienceModel({
    required String id,
    required String description,
    required List<String> tags,
    required UserModel user,
    required DateTime createdAt,
    required List<ExperienceMediaModel> media,
    required ExperienceType type,
    String? rideId,
    @Default(0) int views,
    @Default([]) List<ExperienceReactionModel> reactions,
  }) = _ExperienceModel;

  factory ExperienceModel.fromJson(Map<String, dynamic> json) =>
      _$ExperienceModelFromJson(json);

  const ExperienceModel._();

  /// Convertir a entidad de dominio
  ExperienceEntity toEntity() {
    return ExperienceEntity(
      id: id,
      description: description,
      tags: tags,
      user: user.toEntity(),
      createdAt: createdAt,
      media: media.map((m) => m.toEntity()).toList(),
      type: type,
      rideId: rideId,
      views: views,
      reactions: reactions.map((r) => r.toEntity()).toList(),
    );
  }

  /// Crear desde entidad de dominio
  factory ExperienceModel.fromEntity(ExperienceEntity entity) {
    return ExperienceModel(
      id: entity.id,
      description: entity.description,
      tags: entity.tags,
      user: UserModel.fromEntity(entity.user),
      createdAt: entity.createdAt,
      media:
          entity.media.map((m) => ExperienceMediaModel.fromEntity(m)).toList(),
      type: entity.type,
      rideId: entity.rideId,
      views: entity.views,
      reactions:
          entity.reactions
              .map((r) => ExperienceReactionModel.fromEntity(r))
              .toList(),
    );
  }
}

/// Modelo para archivos multimedia
@freezed
class ExperienceMediaModel with _$ExperienceMediaModel {
  const factory ExperienceMediaModel({
    required String id,
    required String url,
    required MediaType mediaType,
    required int duration,
    double? aspectRatio,
    String? thumbnailUrl,
  }) = _ExperienceMediaModel;

  factory ExperienceMediaModel.fromJson(Map<String, dynamic> json) =>
      _$ExperienceMediaModelFromJson(json);

  const ExperienceMediaModel._();

  ExperienceMediaEntity toEntity() {
    return ExperienceMediaEntity(
      id: id,
      url: url,
      mediaType: mediaType,
      duration: duration,
      aspectRatio: aspectRatio,
      thumbnailUrl: thumbnailUrl,
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
    );
  }
}

/// Modelo para reacciones
@freezed
class ExperienceReactionModel with _$ExperienceReactionModel {
  const factory ExperienceReactionModel({
    required String id,
    required UserModel user,
    required ReactionType type,
    required DateTime createdAt,
  }) = _ExperienceReactionModel;

  factory ExperienceReactionModel.fromJson(Map<String, dynamic> json) =>
      _$ExperienceReactionModelFromJson(json);

  const ExperienceReactionModel._();

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
}

/// UserModel simplificado para las experiencias
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String fullName,
    required String userName,
    required String email,
    required String photo,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  const UserModel._();

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
}
