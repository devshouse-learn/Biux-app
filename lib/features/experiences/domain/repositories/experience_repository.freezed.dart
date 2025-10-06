// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CreateExperienceRequest {
  String get description => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<CreateMediaRequest> get mediaFiles => throw _privateConstructorUsedError;
  ExperienceType get type => throw _privateConstructorUsedError;
  String? get rideId => throw _privateConstructorUsedError;

  /// Create a copy of CreateExperienceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateExperienceRequestCopyWith<CreateExperienceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateExperienceRequestCopyWith<$Res> {
  factory $CreateExperienceRequestCopyWith(
    CreateExperienceRequest value,
    $Res Function(CreateExperienceRequest) then,
  ) = _$CreateExperienceRequestCopyWithImpl<$Res, CreateExperienceRequest>;
  @useResult
  $Res call({
    String description,
    List<String> tags,
    List<CreateMediaRequest> mediaFiles,
    ExperienceType type,
    String? rideId,
  });
}

/// @nodoc
class _$CreateExperienceRequestCopyWithImpl<
  $Res,
  $Val extends CreateExperienceRequest
>
    implements $CreateExperienceRequestCopyWith<$Res> {
  _$CreateExperienceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateExperienceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? tags = null,
    Object? mediaFiles = null,
    Object? type = null,
    Object? rideId = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            mediaFiles:
                null == mediaFiles
                    ? _value.mediaFiles
                    : mediaFiles // ignore: cast_nullable_to_non_nullable
                        as List<CreateMediaRequest>,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateExperienceRequestImplCopyWith<$Res>
    implements $CreateExperienceRequestCopyWith<$Res> {
  factory _$$CreateExperienceRequestImplCopyWith(
    _$CreateExperienceRequestImpl value,
    $Res Function(_$CreateExperienceRequestImpl) then,
  ) = __$$CreateExperienceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String description,
    List<String> tags,
    List<CreateMediaRequest> mediaFiles,
    ExperienceType type,
    String? rideId,
  });
}

/// @nodoc
class __$$CreateExperienceRequestImplCopyWithImpl<$Res>
    extends
        _$CreateExperienceRequestCopyWithImpl<
          $Res,
          _$CreateExperienceRequestImpl
        >
    implements _$$CreateExperienceRequestImplCopyWith<$Res> {
  __$$CreateExperienceRequestImplCopyWithImpl(
    _$CreateExperienceRequestImpl _value,
    $Res Function(_$CreateExperienceRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateExperienceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? tags = null,
    Object? mediaFiles = null,
    Object? type = null,
    Object? rideId = freezed,
  }) {
    return _then(
      _$CreateExperienceRequestImpl(
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
        mediaFiles:
            null == mediaFiles
                ? _value._mediaFiles
                : mediaFiles // ignore: cast_nullable_to_non_nullable
                    as List<CreateMediaRequest>,
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
      ),
    );
  }
}

/// @nodoc

class _$CreateExperienceRequestImpl implements _CreateExperienceRequest {
  const _$CreateExperienceRequestImpl({
    required this.description,
    required final List<String> tags,
    required final List<CreateMediaRequest> mediaFiles,
    required this.type,
    this.rideId,
  }) : _tags = tags,
       _mediaFiles = mediaFiles;

  @override
  final String description;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<CreateMediaRequest> _mediaFiles;
  @override
  List<CreateMediaRequest> get mediaFiles {
    if (_mediaFiles is EqualUnmodifiableListView) return _mediaFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaFiles);
  }

  @override
  final ExperienceType type;
  @override
  final String? rideId;

  @override
  String toString() {
    return 'CreateExperienceRequest(description: $description, tags: $tags, mediaFiles: $mediaFiles, type: $type, rideId: $rideId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateExperienceRequestImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._mediaFiles,
              _mediaFiles,
            ) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.rideId, rideId) || other.rideId == rideId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    description,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_mediaFiles),
    type,
    rideId,
  );

  /// Create a copy of CreateExperienceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateExperienceRequestImplCopyWith<_$CreateExperienceRequestImpl>
  get copyWith => __$$CreateExperienceRequestImplCopyWithImpl<
    _$CreateExperienceRequestImpl
  >(this, _$identity);
}

abstract class _CreateExperienceRequest implements CreateExperienceRequest {
  const factory _CreateExperienceRequest({
    required final String description,
    required final List<String> tags,
    required final List<CreateMediaRequest> mediaFiles,
    required final ExperienceType type,
    final String? rideId,
  }) = _$CreateExperienceRequestImpl;

  @override
  String get description;
  @override
  List<String> get tags;
  @override
  List<CreateMediaRequest> get mediaFiles;
  @override
  ExperienceType get type;
  @override
  String? get rideId;

  /// Create a copy of CreateExperienceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateExperienceRequestImplCopyWith<_$CreateExperienceRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreateMediaRequest {
  String get filePath => throw _privateConstructorUsedError;
  MediaType get mediaType => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  double? get aspectRatio => throw _privateConstructorUsedError;

  /// Create a copy of CreateMediaRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateMediaRequestCopyWith<CreateMediaRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateMediaRequestCopyWith<$Res> {
  factory $CreateMediaRequestCopyWith(
    CreateMediaRequest value,
    $Res Function(CreateMediaRequest) then,
  ) = _$CreateMediaRequestCopyWithImpl<$Res, CreateMediaRequest>;
  @useResult
  $Res call({
    String filePath,
    MediaType mediaType,
    int duration,
    double? aspectRatio,
  });
}

/// @nodoc
class _$CreateMediaRequestCopyWithImpl<$Res, $Val extends CreateMediaRequest>
    implements $CreateMediaRequestCopyWith<$Res> {
  _$CreateMediaRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateMediaRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? mediaType = null,
    Object? duration = null,
    Object? aspectRatio = freezed,
  }) {
    return _then(
      _value.copyWith(
            filePath:
                null == filePath
                    ? _value.filePath
                    : filePath // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateMediaRequestImplCopyWith<$Res>
    implements $CreateMediaRequestCopyWith<$Res> {
  factory _$$CreateMediaRequestImplCopyWith(
    _$CreateMediaRequestImpl value,
    $Res Function(_$CreateMediaRequestImpl) then,
  ) = __$$CreateMediaRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String filePath,
    MediaType mediaType,
    int duration,
    double? aspectRatio,
  });
}

/// @nodoc
class __$$CreateMediaRequestImplCopyWithImpl<$Res>
    extends _$CreateMediaRequestCopyWithImpl<$Res, _$CreateMediaRequestImpl>
    implements _$$CreateMediaRequestImplCopyWith<$Res> {
  __$$CreateMediaRequestImplCopyWithImpl(
    _$CreateMediaRequestImpl _value,
    $Res Function(_$CreateMediaRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateMediaRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? mediaType = null,
    Object? duration = null,
    Object? aspectRatio = freezed,
  }) {
    return _then(
      _$CreateMediaRequestImpl(
        filePath:
            null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc

class _$CreateMediaRequestImpl implements _CreateMediaRequest {
  const _$CreateMediaRequestImpl({
    required this.filePath,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
  });

  @override
  final String filePath;
  @override
  final MediaType mediaType;
  @override
  final int duration;
  @override
  final double? aspectRatio;

  @override
  String toString() {
    return 'CreateMediaRequest(filePath: $filePath, mediaType: $mediaType, duration: $duration, aspectRatio: $aspectRatio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMediaRequestImpl &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, filePath, mediaType, duration, aspectRatio);

  /// Create a copy of CreateMediaRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMediaRequestImplCopyWith<_$CreateMediaRequestImpl> get copyWith =>
      __$$CreateMediaRequestImplCopyWithImpl<_$CreateMediaRequestImpl>(
        this,
        _$identity,
      );
}

abstract class _CreateMediaRequest implements CreateMediaRequest {
  const factory _CreateMediaRequest({
    required final String filePath,
    required final MediaType mediaType,
    required final int duration,
    final double? aspectRatio,
  }) = _$CreateMediaRequestImpl;

  @override
  String get filePath;
  @override
  MediaType get mediaType;
  @override
  int get duration;
  @override
  double? get aspectRatio;

  /// Create a copy of CreateMediaRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateMediaRequestImplCopyWith<_$CreateMediaRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
