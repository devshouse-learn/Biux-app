// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExperienceModelImpl _$$ExperienceModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExperienceModelImpl(
  id: json['id'] as String,
  description: json['description'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  media:
      (json['media'] as List<dynamic>)
          .map((e) => ExperienceMediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  type: $enumDecode(_$ExperienceTypeEnumMap, json['type']),
  rideId: json['rideId'] as String?,
  views: (json['views'] as num?)?.toInt() ?? 0,
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map(
            (e) => ExperienceReactionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ExperienceModelImplToJson(
  _$ExperienceModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'tags': instance.tags,
  'user': instance.user,
  'createdAt': instance.createdAt.toIso8601String(),
  'media': instance.media,
  'type': _$ExperienceTypeEnumMap[instance.type]!,
  'rideId': instance.rideId,
  'views': instance.views,
  'reactions': instance.reactions,
};

const _$ExperienceTypeEnumMap = {
  ExperienceType.general: 'general',
  ExperienceType.ride: 'ride',
};

_$ExperienceMediaModelImpl _$$ExperienceMediaModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExperienceMediaModelImpl(
  id: json['id'] as String,
  url: json['url'] as String,
  mediaType: $enumDecode(_$MediaTypeEnumMap, json['mediaType']),
  duration: (json['duration'] as num).toInt(),
  aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
  thumbnailUrl: json['thumbnailUrl'] as String?,
);

Map<String, dynamic> _$$ExperienceMediaModelImplToJson(
  _$ExperienceMediaModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
  'duration': instance.duration,
  'aspectRatio': instance.aspectRatio,
  'thumbnailUrl': instance.thumbnailUrl,
};

const _$MediaTypeEnumMap = {MediaType.image: 'image', MediaType.video: 'video'};

_$ExperienceReactionModelImpl _$$ExperienceReactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExperienceReactionModelImpl(
  id: json['id'] as String,
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  type: $enumDecode(_$ReactionTypeEnumMap, json['type']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ExperienceReactionModelImplToJson(
  _$ExperienceReactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'type': _$ReactionTypeEnumMap[instance.type]!,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$ReactionTypeEnumMap = {
  ReactionType.like: 'like',
  ReactionType.love: 'love',
  ReactionType.laugh: 'laugh',
  ReactionType.wow: 'wow',
  ReactionType.sad: 'sad',
  ReactionType.angry: 'angry',
};

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      photo: json['photo'] as String,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'userName': instance.userName,
      'email': instance.email,
      'photo': instance.photo,
    };
