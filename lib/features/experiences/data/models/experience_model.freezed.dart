// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExperienceModel _$ExperienceModelFromJson(Map<String, dynamic> json) {
  return _ExperienceModel.fromJson(json);
}

/// @nodoc
mixin _$ExperienceModel {
  String get id => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  UserModel get user => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<ExperienceMediaModel> get media => throw _privateConstructorUsedError;
  ExperienceType get type => throw _privateConstructorUsedError;
  String? get rideId => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  List<ExperienceReactionModel> get reactions =>
      throw _privateConstructorUsedError;

  /// Serializes this ExperienceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceModelCopyWith<ExperienceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceModelCopyWith<$Res> {
  factory $ExperienceModelCopyWith(
    ExperienceModel value,
    $Res Function(ExperienceModel) then,
  ) = _$ExperienceModelCopyWithImpl<$Res, ExperienceModel>;
  @useResult
  $Res call({
    String id,
    String description,
    List<String> tags,
    UserModel user,
    DateTime createdAt,
    List<ExperienceMediaModel> media,
    ExperienceType type,
    String? rideId,
    int views,
    List<ExperienceReactionModel> reactions,
  });

  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class _$ExperienceModelCopyWithImpl<$Res, $Val extends ExperienceModel>
    implements $ExperienceModelCopyWith<$Res> {
  _$ExperienceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceModel
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
                        as UserModel,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            media:
                null == media
                    ? _value.media
                    : media // ignore: cast_nullable_to_non_nullable
                        as List<ExperienceMediaModel>,
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
                        as List<ExperienceReactionModel>,
          )
          as $Val,
    );
  }

  /// Create a copy of ExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExperienceModelImplCopyWith<$Res>
    implements $ExperienceModelCopyWith<$Res> {
  factory _$$ExperienceModelImplCopyWith(
    _$ExperienceModelImpl value,
    $Res Function(_$ExperienceModelImpl) then,
  ) = __$$ExperienceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String description,
    List<String> tags,
    UserModel user,
    DateTime createdAt,
    List<ExperienceMediaModel> media,
    ExperienceType type,
    String? rideId,
    int views,
    List<ExperienceReactionModel> reactions,
  });

  @override
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class __$$ExperienceModelImplCopyWithImpl<$Res>
    extends _$ExperienceModelCopyWithImpl<$Res, _$ExperienceModelImpl>
    implements _$$ExperienceModelImplCopyWith<$Res> {
  __$$ExperienceModelImplCopyWithImpl(
    _$ExperienceModelImpl _value,
    $Res Function(_$ExperienceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExperienceModel
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
      _$ExperienceModelImpl(
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
                    as UserModel,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        media:
            null == media
                ? _value._media
                : media // ignore: cast_nullable_to_non_nullable
                    as List<ExperienceMediaModel>,
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
                    as List<ExperienceReactionModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExperienceModelImpl extends _ExperienceModel {
  const _$ExperienceModelImpl({
    required this.id,
    required this.description,
    required final List<String> tags,
    required this.user,
    required this.createdAt,
    required final List<ExperienceMediaModel> media,
    required this.type,
    this.rideId,
    this.views = 0,
    final List<ExperienceReactionModel> reactions = const [],
  }) : _tags = tags,
       _media = media,
       _reactions = reactions,
       super._();

  factory _$ExperienceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExperienceModelImplFromJson(json);

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
  final UserModel user;
  @override
  final DateTime createdAt;
  final List<ExperienceMediaModel> _media;
  @override
  List<ExperienceMediaModel> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  @override
  final ExperienceType type;
  @override
  final String? rideId;
  @override
  @JsonKey()
  final int views;
  final List<ExperienceReactionModel> _reactions;
  @override
  @JsonKey()
  List<ExperienceReactionModel> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  @override
  String toString() {
    return 'ExperienceModel(id: $id, description: $description, tags: $tags, user: $user, createdAt: $createdAt, media: $media, type: $type, rideId: $rideId, views: $views, reactions: $reactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of ExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceModelImplCopyWith<_$ExperienceModelImpl> get copyWith =>
      __$$ExperienceModelImplCopyWithImpl<_$ExperienceModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExperienceModelImplToJson(this);
  }
}

abstract class _ExperienceModel extends ExperienceModel {
  const factory _ExperienceModel({
    required final String id,
    required final String description,
    required final List<String> tags,
    required final UserModel user,
    required final DateTime createdAt,
    required final List<ExperienceMediaModel> media,
    required final ExperienceType type,
    final String? rideId,
    final int views,
    final List<ExperienceReactionModel> reactions,
  }) = _$ExperienceModelImpl;
  const _ExperienceModel._() : super._();

  factory _ExperienceModel.fromJson(Map<String, dynamic> json) =
      _$ExperienceModelImpl.fromJson;

  @override
  String get id;
  @override
  String get description;
  @override
  List<String> get tags;
  @override
  UserModel get user;
  @override
  DateTime get createdAt;
  @override
  List<ExperienceMediaModel> get media;
  @override
  ExperienceType get type;
  @override
  String? get rideId;
  @override
  int get views;
  @override
  List<ExperienceReactionModel> get reactions;

  /// Create a copy of ExperienceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceModelImplCopyWith<_$ExperienceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExperienceMediaModel _$ExperienceMediaModelFromJson(Map<String, dynamic> json) {
  return _ExperienceMediaModel.fromJson(json);
}

/// @nodoc
mixin _$ExperienceMediaModel {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  MediaType get mediaType => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  double? get aspectRatio => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  /// Serializes this ExperienceMediaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExperienceMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceMediaModelCopyWith<ExperienceMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceMediaModelCopyWith<$Res> {
  factory $ExperienceMediaModelCopyWith(
    ExperienceMediaModel value,
    $Res Function(ExperienceMediaModel) then,
  ) = _$ExperienceMediaModelCopyWithImpl<$Res, ExperienceMediaModel>;
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
class _$ExperienceMediaModelCopyWithImpl<
  $Res,
  $Val extends ExperienceMediaModel
>
    implements $ExperienceMediaModelCopyWith<$Res> {
  _$ExperienceMediaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceMediaModel
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
abstract class _$$ExperienceMediaModelImplCopyWith<$Res>
    implements $ExperienceMediaModelCopyWith<$Res> {
  factory _$$ExperienceMediaModelImplCopyWith(
    _$ExperienceMediaModelImpl value,
    $Res Function(_$ExperienceMediaModelImpl) then,
  ) = __$$ExperienceMediaModelImplCopyWithImpl<$Res>;
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
class __$$ExperienceMediaModelImplCopyWithImpl<$Res>
    extends _$ExperienceMediaModelCopyWithImpl<$Res, _$ExperienceMediaModelImpl>
    implements _$$ExperienceMediaModelImplCopyWith<$Res> {
  __$$ExperienceMediaModelImplCopyWithImpl(
    _$ExperienceMediaModelImpl _value,
    $Res Function(_$ExperienceMediaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExperienceMediaModel
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
      _$ExperienceMediaModelImpl(
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
@JsonSerializable()
class _$ExperienceMediaModelImpl extends _ExperienceMediaModel {
  const _$ExperienceMediaModelImpl({
    required this.id,
    required this.url,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailUrl,
  }) : super._();

  factory _$ExperienceMediaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExperienceMediaModelImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final MediaType mediaType;
  @override
  final int duration;
  @override
  final double? aspectRatio;
  @override
  final String? thumbnailUrl;

  @override
  String toString() {
    return 'ExperienceMediaModel(id: $id, url: $url, mediaType: $mediaType, duration: $duration, aspectRatio: $aspectRatio, thumbnailUrl: $thumbnailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceMediaModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of ExperienceMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceMediaModelImplCopyWith<_$ExperienceMediaModelImpl>
  get copyWith =>
      __$$ExperienceMediaModelImplCopyWithImpl<_$ExperienceMediaModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExperienceMediaModelImplToJson(this);
  }
}

abstract class _ExperienceMediaModel extends ExperienceMediaModel {
  const factory _ExperienceMediaModel({
    required final String id,
    required final String url,
    required final MediaType mediaType,
    required final int duration,
    final double? aspectRatio,
    final String? thumbnailUrl,
  }) = _$ExperienceMediaModelImpl;
  const _ExperienceMediaModel._() : super._();

  factory _ExperienceMediaModel.fromJson(Map<String, dynamic> json) =
      _$ExperienceMediaModelImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  MediaType get mediaType;
  @override
  int get duration;
  @override
  double? get aspectRatio;
  @override
  String? get thumbnailUrl;

  /// Create a copy of ExperienceMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceMediaModelImplCopyWith<_$ExperienceMediaModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExperienceReactionModel _$ExperienceReactionModelFromJson(
  Map<String, dynamic> json,
) {
  return _ExperienceReactionModel.fromJson(json);
}

/// @nodoc
mixin _$ExperienceReactionModel {
  String get id => throw _privateConstructorUsedError;
  UserModel get user => throw _privateConstructorUsedError;
  ReactionType get type => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ExperienceReactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExperienceReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceReactionModelCopyWith<ExperienceReactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceReactionModelCopyWith<$Res> {
  factory $ExperienceReactionModelCopyWith(
    ExperienceReactionModel value,
    $Res Function(ExperienceReactionModel) then,
  ) = _$ExperienceReactionModelCopyWithImpl<$Res, ExperienceReactionModel>;
  @useResult
  $Res call({String id, UserModel user, ReactionType type, DateTime createdAt});

  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class _$ExperienceReactionModelCopyWithImpl<
  $Res,
  $Val extends ExperienceReactionModel
>
    implements $ExperienceReactionModelCopyWith<$Res> {
  _$ExperienceReactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceReactionModel
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
                        as UserModel,
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

  /// Create a copy of ExperienceReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExperienceReactionModelImplCopyWith<$Res>
    implements $ExperienceReactionModelCopyWith<$Res> {
  factory _$$ExperienceReactionModelImplCopyWith(
    _$ExperienceReactionModelImpl value,
    $Res Function(_$ExperienceReactionModelImpl) then,
  ) = __$$ExperienceReactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, UserModel user, ReactionType type, DateTime createdAt});

  @override
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class __$$ExperienceReactionModelImplCopyWithImpl<$Res>
    extends
        _$ExperienceReactionModelCopyWithImpl<
          $Res,
          _$ExperienceReactionModelImpl
        >
    implements _$$ExperienceReactionModelImplCopyWith<$Res> {
  __$$ExperienceReactionModelImplCopyWithImpl(
    _$ExperienceReactionModelImpl _value,
    $Res Function(_$ExperienceReactionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExperienceReactionModel
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
      _$ExperienceReactionModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        user:
            null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                    as UserModel,
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
@JsonSerializable()
class _$ExperienceReactionModelImpl extends _ExperienceReactionModel {
  const _$ExperienceReactionModelImpl({
    required this.id,
    required this.user,
    required this.type,
    required this.createdAt,
  }) : super._();

  factory _$ExperienceReactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExperienceReactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final UserModel user;
  @override
  final ReactionType type;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ExperienceReactionModel(id: $id, user: $user, type: $type, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceReactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, user, type, createdAt);

  /// Create a copy of ExperienceReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceReactionModelImplCopyWith<_$ExperienceReactionModelImpl>
  get copyWith => __$$ExperienceReactionModelImplCopyWithImpl<
    _$ExperienceReactionModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExperienceReactionModelImplToJson(this);
  }
}

abstract class _ExperienceReactionModel extends ExperienceReactionModel {
  const factory _ExperienceReactionModel({
    required final String id,
    required final UserModel user,
    required final ReactionType type,
    required final DateTime createdAt,
  }) = _$ExperienceReactionModelImpl;
  const _ExperienceReactionModel._() : super._();

  factory _ExperienceReactionModel.fromJson(Map<String, dynamic> json) =
      _$ExperienceReactionModelImpl.fromJson;

  @override
  String get id;
  @override
  UserModel get user;
  @override
  ReactionType get type;
  @override
  DateTime get createdAt;

  /// Create a copy of ExperienceReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceReactionModelImplCopyWith<_$ExperienceReactionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get photo => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    String fullName,
    String userName,
    String email,
    String photo,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? userName = null,
    Object? email = null,
    Object? photo = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            fullName:
                null == fullName
                    ? _value.fullName
                    : fullName // ignore: cast_nullable_to_non_nullable
                        as String,
            userName:
                null == userName
                    ? _value.userName
                    : userName // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            photo:
                null == photo
                    ? _value.photo
                    : photo // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String fullName,
    String userName,
    String email,
    String photo,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? userName = null,
    Object? email = null,
    Object? photo = null,
  }) {
    return _then(
      _$UserModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        fullName:
            null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                    as String,
        userName:
            null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        photo:
            null == photo
                ? _value.photo
                : photo // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.photo,
  }) : super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String fullName;
  @override
  final String userName;
  @override
  final String email;
  @override
  final String photo;

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, userName: $userName, email: $email, photo: $photo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.photo, photo) || other.photo == photo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, fullName, userName, email, photo);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
    required final String id,
    required final String fullName,
    required final String userName,
    required final String email,
    required final String photo,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get fullName;
  @override
  String get userName;
  @override
  String get email;
  @override
  String get photo;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
