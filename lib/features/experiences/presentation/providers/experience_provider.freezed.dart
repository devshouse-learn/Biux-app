// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExperienceState {
  List<ExperienceEntity> get experiences => throw _privateConstructorUsedError;
  List<ExperienceEntity> get userExperiences =>
      throw _privateConstructorUsedError;
  List<ExperienceEntity> get rideExperiences =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of ExperienceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceStateCopyWith<ExperienceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceStateCopyWith<$Res> {
  factory $ExperienceStateCopyWith(
    ExperienceState value,
    $Res Function(ExperienceState) then,
  ) = _$ExperienceStateCopyWithImpl<$Res, ExperienceState>;
  @useResult
  $Res call({
    List<ExperienceEntity> experiences,
    List<ExperienceEntity> userExperiences,
    List<ExperienceEntity> rideExperiences,
    bool isLoading,
    String? error,
  });
}

/// @nodoc
class _$ExperienceStateCopyWithImpl<$Res, $Val extends ExperienceState>
    implements $ExperienceStateCopyWith<$Res> {
  _$ExperienceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? experiences = null,
    Object? userExperiences = null,
    Object? rideExperiences = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            experiences:
                null == experiences
                    ? _value.experiences
                    : experiences // ignore: cast_nullable_to_non_nullable
                        as List<ExperienceEntity>,
            userExperiences:
                null == userExperiences
                    ? _value.userExperiences
                    : userExperiences // ignore: cast_nullable_to_non_nullable
                        as List<ExperienceEntity>,
            rideExperiences:
                null == rideExperiences
                    ? _value.rideExperiences
                    : rideExperiences // ignore: cast_nullable_to_non_nullable
                        as List<ExperienceEntity>,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExperienceStateImplCopyWith<$Res>
    implements $ExperienceStateCopyWith<$Res> {
  factory _$$ExperienceStateImplCopyWith(
    _$ExperienceStateImpl value,
    $Res Function(_$ExperienceStateImpl) then,
  ) = __$$ExperienceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ExperienceEntity> experiences,
    List<ExperienceEntity> userExperiences,
    List<ExperienceEntity> rideExperiences,
    bool isLoading,
    String? error,
  });
}

/// @nodoc
class __$$ExperienceStateImplCopyWithImpl<$Res>
    extends _$ExperienceStateCopyWithImpl<$Res, _$ExperienceStateImpl>
    implements _$$ExperienceStateImplCopyWith<$Res> {
  __$$ExperienceStateImplCopyWithImpl(
    _$ExperienceStateImpl _value,
    $Res Function(_$ExperienceStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExperienceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? experiences = null,
    Object? userExperiences = null,
    Object? rideExperiences = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$ExperienceStateImpl(
        experiences:
            null == experiences
                ? _value._experiences
                : experiences // ignore: cast_nullable_to_non_nullable
                    as List<ExperienceEntity>,
        userExperiences:
            null == userExperiences
                ? _value._userExperiences
                : userExperiences // ignore: cast_nullable_to_non_nullable
                    as List<ExperienceEntity>,
        rideExperiences:
            null == rideExperiences
                ? _value._rideExperiences
                : rideExperiences // ignore: cast_nullable_to_non_nullable
                    as List<ExperienceEntity>,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$ExperienceStateImpl implements _ExperienceState {
  const _$ExperienceStateImpl({
    final List<ExperienceEntity> experiences = const [],
    final List<ExperienceEntity> userExperiences = const [],
    final List<ExperienceEntity> rideExperiences = const [],
    this.isLoading = false,
    this.error,
  }) : _experiences = experiences,
       _userExperiences = userExperiences,
       _rideExperiences = rideExperiences;

  final List<ExperienceEntity> _experiences;
  @override
  @JsonKey()
  List<ExperienceEntity> get experiences {
    if (_experiences is EqualUnmodifiableListView) return _experiences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_experiences);
  }

  final List<ExperienceEntity> _userExperiences;
  @override
  @JsonKey()
  List<ExperienceEntity> get userExperiences {
    if (_userExperiences is EqualUnmodifiableListView) return _userExperiences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userExperiences);
  }

  final List<ExperienceEntity> _rideExperiences;
  @override
  @JsonKey()
  List<ExperienceEntity> get rideExperiences {
    if (_rideExperiences is EqualUnmodifiableListView) return _rideExperiences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rideExperiences);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'ExperienceState(experiences: $experiences, userExperiences: $userExperiences, rideExperiences: $rideExperiences, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceStateImpl &&
            const DeepCollectionEquality().equals(
              other._experiences,
              _experiences,
            ) &&
            const DeepCollectionEquality().equals(
              other._userExperiences,
              _userExperiences,
            ) &&
            const DeepCollectionEquality().equals(
              other._rideExperiences,
              _rideExperiences,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_experiences),
    const DeepCollectionEquality().hash(_userExperiences),
    const DeepCollectionEquality().hash(_rideExperiences),
    isLoading,
    error,
  );

  /// Create a copy of ExperienceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceStateImplCopyWith<_$ExperienceStateImpl> get copyWith =>
      __$$ExperienceStateImplCopyWithImpl<_$ExperienceStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ExperienceState implements ExperienceState {
  const factory _ExperienceState({
    final List<ExperienceEntity> experiences,
    final List<ExperienceEntity> userExperiences,
    final List<ExperienceEntity> rideExperiences,
    final bool isLoading,
    final String? error,
  }) = _$ExperienceStateImpl;

  @override
  List<ExperienceEntity> get experiences;
  @override
  List<ExperienceEntity> get userExperiences;
  @override
  List<ExperienceEntity> get rideExperiences;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of ExperienceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceStateImplCopyWith<_$ExperienceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
