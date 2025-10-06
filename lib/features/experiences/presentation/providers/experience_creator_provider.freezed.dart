// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience_creator_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExperienceCreatorState {
  List<MediaItem> get mediaItems => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  ExperienceType? get experienceType => throw _privateConstructorUsedError;
  String? get rideId => throw _privateConstructorUsedError;
  bool get isUploading => throw _privateConstructorUsedError;
  double get uploadProgress => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isRecording => throw _privateConstructorUsedError;
  VideoPlayerController? get videoController =>
      throw _privateConstructorUsedError;

  /// Create a copy of ExperienceCreatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceCreatorStateCopyWith<ExperienceCreatorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceCreatorStateCopyWith<$Res> {
  factory $ExperienceCreatorStateCopyWith(
    ExperienceCreatorState value,
    $Res Function(ExperienceCreatorState) then,
  ) = _$ExperienceCreatorStateCopyWithImpl<$Res, ExperienceCreatorState>;
  @useResult
  $Res call({
    List<MediaItem> mediaItems,
    String description,
    List<String> tags,
    ExperienceType? experienceType,
    String? rideId,
    bool isUploading,
    double uploadProgress,
    String? error,
    bool isRecording,
    VideoPlayerController? videoController,
  });
}

/// @nodoc
class _$ExperienceCreatorStateCopyWithImpl<
  $Res,
  $Val extends ExperienceCreatorState
>
    implements $ExperienceCreatorStateCopyWith<$Res> {
  _$ExperienceCreatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceCreatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaItems = null,
    Object? description = null,
    Object? tags = null,
    Object? experienceType = freezed,
    Object? rideId = freezed,
    Object? isUploading = null,
    Object? uploadProgress = null,
    Object? error = freezed,
    Object? isRecording = null,
    Object? videoController = freezed,
  }) {
    return _then(
      _value.copyWith(
            mediaItems:
                null == mediaItems
                    ? _value.mediaItems
                    : mediaItems // ignore: cast_nullable_to_non_nullable
                        as List<MediaItem>,
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
            experienceType:
                freezed == experienceType
                    ? _value.experienceType
                    : experienceType // ignore: cast_nullable_to_non_nullable
                        as ExperienceType?,
            rideId:
                freezed == rideId
                    ? _value.rideId
                    : rideId // ignore: cast_nullable_to_non_nullable
                        as String?,
            isUploading:
                null == isUploading
                    ? _value.isUploading
                    : isUploading // ignore: cast_nullable_to_non_nullable
                        as bool,
            uploadProgress:
                null == uploadProgress
                    ? _value.uploadProgress
                    : uploadProgress // ignore: cast_nullable_to_non_nullable
                        as double,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            isRecording:
                null == isRecording
                    ? _value.isRecording
                    : isRecording // ignore: cast_nullable_to_non_nullable
                        as bool,
            videoController:
                freezed == videoController
                    ? _value.videoController
                    : videoController // ignore: cast_nullable_to_non_nullable
                        as VideoPlayerController?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExperienceCreatorStateImplCopyWith<$Res>
    implements $ExperienceCreatorStateCopyWith<$Res> {
  factory _$$ExperienceCreatorStateImplCopyWith(
    _$ExperienceCreatorStateImpl value,
    $Res Function(_$ExperienceCreatorStateImpl) then,
  ) = __$$ExperienceCreatorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MediaItem> mediaItems,
    String description,
    List<String> tags,
    ExperienceType? experienceType,
    String? rideId,
    bool isUploading,
    double uploadProgress,
    String? error,
    bool isRecording,
    VideoPlayerController? videoController,
  });
}

/// @nodoc
class __$$ExperienceCreatorStateImplCopyWithImpl<$Res>
    extends
        _$ExperienceCreatorStateCopyWithImpl<$Res, _$ExperienceCreatorStateImpl>
    implements _$$ExperienceCreatorStateImplCopyWith<$Res> {
  __$$ExperienceCreatorStateImplCopyWithImpl(
    _$ExperienceCreatorStateImpl _value,
    $Res Function(_$ExperienceCreatorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExperienceCreatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaItems = null,
    Object? description = null,
    Object? tags = null,
    Object? experienceType = freezed,
    Object? rideId = freezed,
    Object? isUploading = null,
    Object? uploadProgress = null,
    Object? error = freezed,
    Object? isRecording = null,
    Object? videoController = freezed,
  }) {
    return _then(
      _$ExperienceCreatorStateImpl(
        mediaItems:
            null == mediaItems
                ? _value._mediaItems
                : mediaItems // ignore: cast_nullable_to_non_nullable
                    as List<MediaItem>,
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
        experienceType:
            freezed == experienceType
                ? _value.experienceType
                : experienceType // ignore: cast_nullable_to_non_nullable
                    as ExperienceType?,
        rideId:
            freezed == rideId
                ? _value.rideId
                : rideId // ignore: cast_nullable_to_non_nullable
                    as String?,
        isUploading:
            null == isUploading
                ? _value.isUploading
                : isUploading // ignore: cast_nullable_to_non_nullable
                    as bool,
        uploadProgress:
            null == uploadProgress
                ? _value.uploadProgress
                : uploadProgress // ignore: cast_nullable_to_non_nullable
                    as double,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        isRecording:
            null == isRecording
                ? _value.isRecording
                : isRecording // ignore: cast_nullable_to_non_nullable
                    as bool,
        videoController:
            freezed == videoController
                ? _value.videoController
                : videoController // ignore: cast_nullable_to_non_nullable
                    as VideoPlayerController?,
      ),
    );
  }
}

/// @nodoc

class _$ExperienceCreatorStateImpl implements _ExperienceCreatorState {
  const _$ExperienceCreatorStateImpl({
    final List<MediaItem> mediaItems = const [],
    this.description = '',
    final List<String> tags = const [],
    this.experienceType,
    this.rideId,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.error,
    this.isRecording = false,
    this.videoController,
  }) : _mediaItems = mediaItems,
       _tags = tags;

  final List<MediaItem> _mediaItems;
  @override
  @JsonKey()
  List<MediaItem> get mediaItems {
    if (_mediaItems is EqualUnmodifiableListView) return _mediaItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaItems);
  }

  @override
  @JsonKey()
  final String description;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final ExperienceType? experienceType;
  @override
  final String? rideId;
  @override
  @JsonKey()
  final bool isUploading;
  @override
  @JsonKey()
  final double uploadProgress;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool isRecording;
  @override
  final VideoPlayerController? videoController;

  @override
  String toString() {
    return 'ExperienceCreatorState(mediaItems: $mediaItems, description: $description, tags: $tags, experienceType: $experienceType, rideId: $rideId, isUploading: $isUploading, uploadProgress: $uploadProgress, error: $error, isRecording: $isRecording, videoController: $videoController)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceCreatorStateImpl &&
            const DeepCollectionEquality().equals(
              other._mediaItems,
              _mediaItems,
            ) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.experienceType, experienceType) ||
                other.experienceType == experienceType) &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.isUploading, isUploading) ||
                other.isUploading == isUploading) &&
            (identical(other.uploadProgress, uploadProgress) ||
                other.uploadProgress == uploadProgress) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isRecording, isRecording) ||
                other.isRecording == isRecording) &&
            (identical(other.videoController, videoController) ||
                other.videoController == videoController));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_mediaItems),
    description,
    const DeepCollectionEquality().hash(_tags),
    experienceType,
    rideId,
    isUploading,
    uploadProgress,
    error,
    isRecording,
    videoController,
  );

  /// Create a copy of ExperienceCreatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceCreatorStateImplCopyWith<_$ExperienceCreatorStateImpl>
  get copyWith =>
      __$$ExperienceCreatorStateImplCopyWithImpl<_$ExperienceCreatorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ExperienceCreatorState implements ExperienceCreatorState {
  const factory _ExperienceCreatorState({
    final List<MediaItem> mediaItems,
    final String description,
    final List<String> tags,
    final ExperienceType? experienceType,
    final String? rideId,
    final bool isUploading,
    final double uploadProgress,
    final String? error,
    final bool isRecording,
    final VideoPlayerController? videoController,
  }) = _$ExperienceCreatorStateImpl;

  @override
  List<MediaItem> get mediaItems;
  @override
  String get description;
  @override
  List<String> get tags;
  @override
  ExperienceType? get experienceType;
  @override
  String? get rideId;
  @override
  bool get isUploading;
  @override
  double get uploadProgress;
  @override
  String? get error;
  @override
  bool get isRecording;
  @override
  VideoPlayerController? get videoController;

  /// Create a copy of ExperienceCreatorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceCreatorStateImplCopyWith<_$ExperienceCreatorStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MediaItem {
  String get filePath => throw _privateConstructorUsedError;
  MediaType get mediaType => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  double? get aspectRatio => throw _privateConstructorUsedError;
  String? get thumbnailPath => throw _privateConstructorUsedError;
  bool get isProcessing => throw _privateConstructorUsedError;

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaItemCopyWith<MediaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaItemCopyWith<$Res> {
  factory $MediaItemCopyWith(MediaItem value, $Res Function(MediaItem) then) =
      _$MediaItemCopyWithImpl<$Res, MediaItem>;
  @useResult
  $Res call({
    String filePath,
    MediaType mediaType,
    int duration,
    double? aspectRatio,
    String? thumbnailPath,
    bool isProcessing,
  });
}

/// @nodoc
class _$MediaItemCopyWithImpl<$Res, $Val extends MediaItem>
    implements $MediaItemCopyWith<$Res> {
  _$MediaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? mediaType = null,
    Object? duration = null,
    Object? aspectRatio = freezed,
    Object? thumbnailPath = freezed,
    Object? isProcessing = null,
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
            thumbnailPath:
                freezed == thumbnailPath
                    ? _value.thumbnailPath
                    : thumbnailPath // ignore: cast_nullable_to_non_nullable
                        as String?,
            isProcessing:
                null == isProcessing
                    ? _value.isProcessing
                    : isProcessing // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MediaItemImplCopyWith<$Res>
    implements $MediaItemCopyWith<$Res> {
  factory _$$MediaItemImplCopyWith(
    _$MediaItemImpl value,
    $Res Function(_$MediaItemImpl) then,
  ) = __$$MediaItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String filePath,
    MediaType mediaType,
    int duration,
    double? aspectRatio,
    String? thumbnailPath,
    bool isProcessing,
  });
}

/// @nodoc
class __$$MediaItemImplCopyWithImpl<$Res>
    extends _$MediaItemCopyWithImpl<$Res, _$MediaItemImpl>
    implements _$$MediaItemImplCopyWith<$Res> {
  __$$MediaItemImplCopyWithImpl(
    _$MediaItemImpl _value,
    $Res Function(_$MediaItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? mediaType = null,
    Object? duration = null,
    Object? aspectRatio = freezed,
    Object? thumbnailPath = freezed,
    Object? isProcessing = null,
  }) {
    return _then(
      _$MediaItemImpl(
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
        thumbnailPath:
            freezed == thumbnailPath
                ? _value.thumbnailPath
                : thumbnailPath // ignore: cast_nullable_to_non_nullable
                    as String?,
        isProcessing:
            null == isProcessing
                ? _value.isProcessing
                : isProcessing // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$MediaItemImpl extends _MediaItem {
  const _$MediaItemImpl({
    required this.filePath,
    required this.mediaType,
    required this.duration,
    this.aspectRatio,
    this.thumbnailPath,
    this.isProcessing = false,
  }) : super._();

  @override
  final String filePath;
  @override
  final MediaType mediaType;
  @override
  final int duration;
  @override
  final double? aspectRatio;
  @override
  final String? thumbnailPath;
  @override
  @JsonKey()
  final bool isProcessing;

  @override
  String toString() {
    return 'MediaItem(filePath: $filePath, mediaType: $mediaType, duration: $duration, aspectRatio: $aspectRatio, thumbnailPath: $thumbnailPath, isProcessing: $isProcessing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaItemImpl &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    filePath,
    mediaType,
    duration,
    aspectRatio,
    thumbnailPath,
    isProcessing,
  );

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaItemImplCopyWith<_$MediaItemImpl> get copyWith =>
      __$$MediaItemImplCopyWithImpl<_$MediaItemImpl>(this, _$identity);
}

abstract class _MediaItem extends MediaItem {
  const factory _MediaItem({
    required final String filePath,
    required final MediaType mediaType,
    required final int duration,
    final double? aspectRatio,
    final String? thumbnailPath,
    final bool isProcessing,
  }) = _$MediaItemImpl;
  const _MediaItem._() : super._();

  @override
  String get filePath;
  @override
  MediaType get mediaType;
  @override
  int get duration;
  @override
  double? get aspectRatio;
  @override
  String? get thumbnailPath;
  @override
  bool get isProcessing;

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaItemImplCopyWith<_$MediaItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
