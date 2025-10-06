// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExperienceEntity {
  String get id => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  UserEntity get user => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<ExperienceMediaEntity> get media => throw _privateConstructorUsedError;
  ExperienceType get type => throw _privateConstructorUsedError;
  String? get rideId =>
      throw _privateConstructorUsedError; // Solo para experiencias de rodadas
  int get views => throw _privateConstructorUsedError;
  List<ExperienceReactionEntity> get reactions =>
      throw _privateConstructorUsedError;

  /// Create a copy of ExperienceEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceEntityCopyWith<ExperienceEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceEntityCopyWith<$Res> {
  factory $ExperienceEntityCopyWith(
    ExperienceEntity value,
    $Res Function(ExperienceEntity) then,
  ) = _$ExperienceEntityCopyWithImpl<$Res, ExperienceEntity>;
  @useResult
  $Res call({
    String id,
    String description,
    List<String> tags,
    UserEntity user,
    DateTime createdAt,
    List<ExperienceMediaEntity> media,
    ExperienceType type,
    String? rideId,
    int views,
    List<ExperienceReactionEntity> reactions,
  });
}

/// @nodoc
class _$ExperienceEntityCopyWithImpl<$Res, $Val extends ExperienceEntity>
    implements $ExperienceEntityCopyWith<$Res> {
  _$ExperienceEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? tags = null,
    Object? user = null,
    Object? createdAt = null,
    Object? media = null,
    Object? type = null,
    Object? rideId = freezed,
    Object? views = null,
    Object? reactions = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            user:
                null == user
                    ? _value.user
                    : user // ignore: cast_nullable_to_non_nullable
                        as UserEntity,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            media:
                null == media
                    ? _value.media
                    : media // ignore: cast_nullable_to_non_nullable
                        as List<ExperienceMediaEntity>,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as ExperienceType,
            rideId:
                freezed == rideId
                    ? _value.rideId
                    : rideId // ignore: cast_nullable_to_non_nullable
                        as String?,
            views:
                null == views
                    ? _value.views
                    : views // ignore: cast_nullable_to_non_nullable
                        as int,
            reactions:
                null == reactions
                    ? _value.reactions
                    : reactions // ignore: cast_nullable_to_non_nullable
                        as List<ExperienceReactionEntity>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExperienceEntityImplCopyWith<$Res>
    implements $ExperienceEntityCopyWith<$Res> {
  factory _$$ExperienceEntityImplCopyWith(
    _$ExperienceEntityImpl value,
    $Res Function(_$ExperienceEntityImpl) then,
  ) = __$$ExperienceEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String description,
    List<String> tags,
    UserEntity user,
    DateTime createdAt,
    List<ExperienceMediaEntity> media,
    ExperienceType type,
    String? rideId,
    int views,
    List<ExperienceReactionEntity> reactions,
  });
}

/// @nodoc
class __$$ExperienceEntityImplCopyWithImpl<$Res>
    extends _$ExperienceEntityCopyWithImpl<$Res, _$ExperienceEntityImpl>
    implements _$$ExperienceEntityImplCopyWith<$Res> {
  __$$ExperienceEntityImplCopyWithImpl(
    _$ExperienceEntityImpl _value,
    $Res Function(_$ExperienceEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExperienceEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? tags = null,
    Object? user = null,
    Object? createdAt = null,
    Object? media = null,
    Object? type = null,
    Object? rideId = freezed,
    Object? views = null,
    Object? reactions = null,
  }) {
    return _then(
      _$ExperienceEntityImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        user:
            null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                    as UserEntity,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        media:
            null == media
                ? _value._media
                : media // ignore: cast_nullable_to_non_nullable
                    as List<ExperienceMediaEntity>,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as ExperienceType,
        rideId:
            freezed == rideId
                ? _value.rideId
                : rideId // ignore: cast_nullable_to_non_nullable
                    as String?,
        views:
            null == views
                ? _value.views
                : views // ignore: cast_nullable_to_non_nullable
                    as int,
        reactions:
            null == reactions
                ? _value._reactions
                : reactions // ignore: cast_nullable_to_non_nullable
                    as List<ExperienceReactionEntity>,
      ),
    );
  }
}

/// @nodoc

class _$ExperienceEntityImpl extends _ExperienceEntity {
  const _$ExperienceEntityImpl({
    required this.id,
    required this.description,
    required final List<String> tags,
    required this.user,
    required this.createdAt,
    required final List<ExperienceMediaEntity> media,
    required this.type,
    this.rideId,
    this.views = 0,
    final List<ExperienceReactionEntity> reactions = const [],
  }) : _tags = tags,
       _media = media,
       _reactions = reactions,
       super._();

  @override
  final String id;
  @override
  final String description;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final UserEntity user;
  @override
  final DateTime createdAt;
  final List<ExperienceMediaEntity> _media;
  @override
  List<ExperienceMediaEntity> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  @override
  final ExperienceType type;
  @override
  final String? rideId;
  // Solo para experiencias de rodadas
  @override
  @JsonKey()
  final int views;
  final List<ExperienceReactionEntity> _reactions;
  @override
  @JsonKey()
  List<ExperienceReactionEntity> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  @override
  String toString() {
    return 'ExperienceEntity(id: $id, description: $description, tags: $tags, user: $user, createdAt: $createdAt, media: $media, type: $type, rideId: $rideId, views: $views, reactions: $reactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.views, views) || other.views == views) &&
            const DeepCollectionEquality().equals(
              other._reactions,
              _reactions,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    description,
    const DeepCollectionEquality().hash(_tags),
    user,
    createdAt,
    const DeepCollectionEquality().hash(_media),
    type,
    rideId,
    views,
    const DeepCollectionEquality().hash(_reactions),
  );

  /// Create a copy of ExperienceEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceEntityImplCopyWith<_$ExperienceEntityImpl> get copyWith =>
      __$$ExperienceEntityImplCopyWithImpl<_$ExperienceEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _ExperienceEntity extends ExperienceEntity {
  const factory _ExperienceEntity({
    required final String id,
    required final String description,
    required final List<String> tags,
    required final UserEntity user,
    required final DateTime createdAt,
    required final List<ExperienceMediaEntity> media,
    required final ExperienceType type,
    final String? rideId,
    final int views,
    final List<ExperienceReactionEntity> reactions,
  }) = _$ExperienceEntityImpl;
  const _ExperienceEntity._() : super._();

  @override
  String get id;
  @override
  String get description;
  @override
  List<String> get tags;
  @override
  UserEntity get user;
  @override
  DateTime get createdAt;
  @override
  List<ExperienceMediaEntity> get media;
  @override
  ExperienceType get type;
  @override
  String? get rideId; // Solo para experiencias de rodadas
  @override
  int get views;
  @override
  List<ExperienceReactionEntity> get reactions;

  /// Create a copy of ExperienceEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceEntityImplCopyWith<_$ExperienceEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExperienceMediaEntity {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  MediaType get mediaType => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError; // En segundos
  double? get aspectRatio => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  /// Create a copy of ExperienceMediaEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceMediaEntityCopyWith<ExperienceMediaEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceMediaEntityCopyWith<$Res> {
  factory $ExperienceMediaEntityCopyWith(
    ExperienceMediaEntity value,
    $Res Function(ExperienceMediaEntity) then,
  ) = _$ExperienceMediaEntityCopyWithImpl<$Res, ExperienceMediaEntity>;
  @useResult
  $Res call({
    String id,
    String url,
    MediaType mediaType,
    int duration,
    double? aspectRatio,
    String? thumbnailUrl,
  });
}

/// @nodoc
class _$ExperienceMediaEntityCopyWithImpl<
  $Res,
  $Val extends ExperienceMediaEntity
>
    implements $ExperienceMediaEntityCopyWith<$Res> {
  _$ExperienceMediaEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceMediaEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? mediaType = null,
    Object? duration = null,
    Object? aspectRatio = freezed,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            url:
                null == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String,
            mediaType:
                null == mediaType
                    ? _value.mediaType
                    : mediaType // ignore: cast_nullable_to_non_nullable
                        as MediaType,
            duration:
                null == duration
                    ? _value.duration
                    : duration // ignore: cast_nullable_to_non_nullable
                        as int,
            aspectRatio:
                freezed == aspectRatio
                    ? _value.aspectRatio
                    : aspectRatio // ignore: cast_nullable_to_non_nullable
                        as double?,
            thumbnailUrl:
                freezed == thumbnailUrl
                    ? _value.thumbnailUrl
                    : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExperienceMediaEntityImplCopyWith<$Res>
    implements $ExperienceMediaEntityCopyWith<$Res> {
  factory _$$ExperienceMediaEntityImplCopyWith(
    _$ExperienceMediaEntityImpl value,
    $Res Function(_$ExperienceMediaEntityImpl) then,
  ) = __$$ExperienceMediaEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String url,
    MediaType mediaType,
    int duration,
    double? aspectRatio,
    String? thumbnailUrl,
  });
}

/// @nodoc
class __$$ExperienceMediaEntityImplCopyWithImpl<$Res>
    extends
        _$ExperienceMediaEntityCopyWithImpl<$Res, _$ExperienceMediaEntityImpl>
    implements _$$ExperienceMediaEntityImplCopyWith<$Res> {
  __$$ExperienceMediaEntityImplCopyWithImpl(
    _$ExperienceMediaEntityImpl _value,
    $Res Function(_$ExperienceMediaEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExperienceMediaEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? mediaType = null,
    Object? duration = null,
    Object? aspectRatio = freezed,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(
      _$ExperienceMediaEntityImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        url:
            null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String,
        mediaType:
            null == mediaType
                ? _value.mediaType
                : mediaType // ignore: cast_nullable_to_non_nullable
                    as MediaType,
        duration:
            null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                    as int,
        aspectRatio:
            freezed == aspectRatio
                ? _value.aspectRatio
                : aspectRatio // ignore: cast_nullable_to_non_nullable
                    as double?,
        thumbnailUrl:
            freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$ExperienceMediaEntityImpl implements _ExperienceMediaEntity {
  const _$ExperienceMediaEntityImpl({
    required this.id,
    required this.url,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailUrl,
  });

  @override
  final String id;
  @override
  final String url;
  @override
  final MediaType mediaType;
  @override
  final int duration;
  // En segundos
  @override
  final double? aspectRatio;
  @override
  final String? thumbnailUrl;

  @override
  String toString() {
    return 'ExperienceMediaEntity(id: $id, url: $url, mediaType: $mediaType, duration: $duration, aspectRatio: $aspectRatio, thumbnailUrl: $thumbnailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceMediaEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    url,
    mediaType,
    duration,
    aspectRatio,
    thumbnailUrl,
  );

  /// Create a copy of ExperienceMediaEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceMediaEntityImplCopyWith<_$ExperienceMediaEntityImpl>
  get copyWith =>
      __$$ExperienceMediaEntityImplCopyWithImpl<_$ExperienceMediaEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _ExperienceMediaEntity implements ExperienceMediaEntity {
  const factory _ExperienceMediaEntity({
    required final String id,
    required final String url,
    required final MediaType mediaType,
    required final int duration,
    final double? aspectRatio,
    final String? thumbnailUrl,
  }) = _$ExperienceMediaEntityImpl;

  @override
  String get id;
  @override
  String get url;
  @override
  MediaType get mediaType;
  @override
  int get duration; // En segundos
  @override
  double? get aspectRatio;
  @override
  String? get thumbnailUrl;

  /// Create a copy of ExperienceMediaEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceMediaEntityImplCopyWith<_$ExperienceMediaEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExperienceReactionEntity {
  String get id => throw _privateConstructorUsedError;
  UserEntity get user => throw _privateConstructorUsedError;
  ReactionType get type => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of ExperienceReactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceReactionEntityCopyWith<ExperienceReactionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceReactionEntityCopyWith<$Res> {
  factory $ExperienceReactionEntityCopyWith(
    ExperienceReactionEntity value,
    $Res Function(ExperienceReactionEntity) then,
  ) = _$ExperienceReactionEntityCopyWithImpl<$Res, ExperienceReactionEntity>;
  @useResult
  $Res call({
    String id,
    UserEntity user,
    ReactionType type,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ExperienceReactionEntityCopyWithImpl<
  $Res,
  $Val extends ExperienceReactionEntity
>
    implements $ExperienceReactionEntityCopyWith<$Res> {
  _$ExperienceReactionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceReactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? type = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            user:
                null == user
                    ? _value.user
                    : user // ignore: cast_nullable_to_non_nullable
                        as UserEntity,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as ReactionType,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExperienceReactionEntityImplCopyWith<$Res>
    implements $ExperienceReactionEntityCopyWith<$Res> {
  factory _$$ExperienceReactionEntityImplCopyWith(
    _$ExperienceReactionEntityImpl value,
    $Res Function(_$ExperienceReactionEntityImpl) then,
  ) = __$$ExperienceReactionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    UserEntity user,
    ReactionType type,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ExperienceReactionEntityImplCopyWithImpl<$Res>
    extends
        _$ExperienceReactionEntityCopyWithImpl<
          $Res,
          _$ExperienceReactionEntityImpl
        >
    implements _$$ExperienceReactionEntityImplCopyWith<$Res> {
  __$$ExperienceReactionEntityImplCopyWithImpl(
    _$ExperienceReactionEntityImpl _value,
    $Res Function(_$ExperienceReactionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExperienceReactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? type = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ExperienceReactionEntityImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        user:
            null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                    as UserEntity,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as ReactionType,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$ExperienceReactionEntityImpl implements _ExperienceReactionEntity {
  const _$ExperienceReactionEntityImpl({
    required this.id,
    required this.user,
    required this.type,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final UserEntity user;
  @override
  final ReactionType type;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ExperienceReactionEntity(id: $id, user: $user, type: $type, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceReactionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, user, type, createdAt);

  /// Create a copy of ExperienceReactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceReactionEntityImplCopyWith<_$ExperienceReactionEntityImpl>
  get copyWith => __$$ExperienceReactionEntityImplCopyWithImpl<
    _$ExperienceReactionEntityImpl
  >(this, _$identity);
}

abstract class _ExperienceReactionEntity implements ExperienceReactionEntity {
  const factory _ExperienceReactionEntity({
    required final String id,
    required final UserEntity user,
    required final ReactionType type,
    required final DateTime createdAt,
  }) = _$ExperienceReactionEntityImpl;

  @override
  String get id;
  @override
  UserEntity get user;
  @override
  ReactionType get type;
  @override
  DateTime get createdAt;

  /// Create a copy of ExperienceReactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceReactionEntityImplCopyWith<_$ExperienceReactionEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
