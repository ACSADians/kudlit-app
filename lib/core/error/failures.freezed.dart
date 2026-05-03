// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Failure {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(
    _$NetworkFailureImpl value,
    $Res Function(_$NetworkFailureImpl) then,
  ) = __$$NetworkFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
    _$NetworkFailureImpl _value,
    $Res Function(_$NetworkFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$NetworkFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.network(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return network(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return network?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements Failure {
  const factory NetworkFailure({required final String message}) =
      _$NetworkFailureImpl;

  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InvalidCredentialsFailureImplCopyWith<$Res> {
  factory _$$InvalidCredentialsFailureImplCopyWith(
    _$InvalidCredentialsFailureImpl value,
    $Res Function(_$InvalidCredentialsFailureImpl) then,
  ) = __$$InvalidCredentialsFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InvalidCredentialsFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$InvalidCredentialsFailureImpl>
    implements _$$InvalidCredentialsFailureImplCopyWith<$Res> {
  __$$InvalidCredentialsFailureImplCopyWithImpl(
    _$InvalidCredentialsFailureImpl _value,
    $Res Function(_$InvalidCredentialsFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InvalidCredentialsFailureImpl implements InvalidCredentialsFailure {
  const _$InvalidCredentialsFailureImpl();

  @override
  String toString() {
    return 'Failure.invalidCredentials()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvalidCredentialsFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return invalidCredentials();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return invalidCredentials?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return invalidCredentials(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return invalidCredentials?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials(this);
    }
    return orElse();
  }
}

abstract class InvalidCredentialsFailure implements Failure {
  const factory InvalidCredentialsFailure() = _$InvalidCredentialsFailureImpl;
}

/// @nodoc
abstract class _$$UserNotFoundFailureImplCopyWith<$Res> {
  factory _$$UserNotFoundFailureImplCopyWith(
    _$UserNotFoundFailureImpl value,
    $Res Function(_$UserNotFoundFailureImpl) then,
  ) = __$$UserNotFoundFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UserNotFoundFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UserNotFoundFailureImpl>
    implements _$$UserNotFoundFailureImplCopyWith<$Res> {
  __$$UserNotFoundFailureImplCopyWithImpl(
    _$UserNotFoundFailureImpl _value,
    $Res Function(_$UserNotFoundFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UserNotFoundFailureImpl implements UserNotFoundFailure {
  const _$UserNotFoundFailureImpl();

  @override
  String toString() {
    return 'Failure.userNotFound()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserNotFoundFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return userNotFound();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return userNotFound?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (userNotFound != null) {
      return userNotFound();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return userNotFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return userNotFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (userNotFound != null) {
      return userNotFound(this);
    }
    return orElse();
  }
}

abstract class UserNotFoundFailure implements Failure {
  const factory UserNotFoundFailure() = _$UserNotFoundFailureImpl;
}

/// @nodoc
abstract class _$$EmailAlreadyInUseFailureImplCopyWith<$Res> {
  factory _$$EmailAlreadyInUseFailureImplCopyWith(
    _$EmailAlreadyInUseFailureImpl value,
    $Res Function(_$EmailAlreadyInUseFailureImpl) then,
  ) = __$$EmailAlreadyInUseFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailAlreadyInUseFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$EmailAlreadyInUseFailureImpl>
    implements _$$EmailAlreadyInUseFailureImplCopyWith<$Res> {
  __$$EmailAlreadyInUseFailureImplCopyWithImpl(
    _$EmailAlreadyInUseFailureImpl _value,
    $Res Function(_$EmailAlreadyInUseFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailAlreadyInUseFailureImpl implements EmailAlreadyInUseFailure {
  const _$EmailAlreadyInUseFailureImpl();

  @override
  String toString() {
    return 'Failure.emailAlreadyInUse()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailAlreadyInUseFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return emailAlreadyInUse();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return emailAlreadyInUse?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (emailAlreadyInUse != null) {
      return emailAlreadyInUse();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return emailAlreadyInUse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return emailAlreadyInUse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (emailAlreadyInUse != null) {
      return emailAlreadyInUse(this);
    }
    return orElse();
  }
}

abstract class EmailAlreadyInUseFailure implements Failure {
  const factory EmailAlreadyInUseFailure() = _$EmailAlreadyInUseFailureImpl;
}

/// @nodoc
abstract class _$$WeakPasswordFailureImplCopyWith<$Res> {
  factory _$$WeakPasswordFailureImplCopyWith(
    _$WeakPasswordFailureImpl value,
    $Res Function(_$WeakPasswordFailureImpl) then,
  ) = __$$WeakPasswordFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WeakPasswordFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$WeakPasswordFailureImpl>
    implements _$$WeakPasswordFailureImplCopyWith<$Res> {
  __$$WeakPasswordFailureImplCopyWithImpl(
    _$WeakPasswordFailureImpl _value,
    $Res Function(_$WeakPasswordFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$WeakPasswordFailureImpl implements WeakPasswordFailure {
  const _$WeakPasswordFailureImpl();

  @override
  String toString() {
    return 'Failure.weakPassword()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeakPasswordFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return weakPassword();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return weakPassword?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (weakPassword != null) {
      return weakPassword();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return weakPassword(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return weakPassword?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (weakPassword != null) {
      return weakPassword(this);
    }
    return orElse();
  }
}

abstract class WeakPasswordFailure implements Failure {
  const factory WeakPasswordFailure() = _$WeakPasswordFailureImpl;
}

/// @nodoc
abstract class _$$TooManyRequestsFailureImplCopyWith<$Res> {
  factory _$$TooManyRequestsFailureImplCopyWith(
    _$TooManyRequestsFailureImpl value,
    $Res Function(_$TooManyRequestsFailureImpl) then,
  ) = __$$TooManyRequestsFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TooManyRequestsFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$TooManyRequestsFailureImpl>
    implements _$$TooManyRequestsFailureImplCopyWith<$Res> {
  __$$TooManyRequestsFailureImplCopyWithImpl(
    _$TooManyRequestsFailureImpl _value,
    $Res Function(_$TooManyRequestsFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TooManyRequestsFailureImpl implements TooManyRequestsFailure {
  const _$TooManyRequestsFailureImpl();

  @override
  String toString() {
    return 'Failure.tooManyRequests()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TooManyRequestsFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return tooManyRequests();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return tooManyRequests?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (tooManyRequests != null) {
      return tooManyRequests();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return tooManyRequests(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return tooManyRequests?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (tooManyRequests != null) {
      return tooManyRequests(this);
    }
    return orElse();
  }
}

abstract class TooManyRequestsFailure implements Failure {
  const factory TooManyRequestsFailure() = _$TooManyRequestsFailureImpl;
}

/// @nodoc
abstract class _$$SessionExpiredFailureImplCopyWith<$Res> {
  factory _$$SessionExpiredFailureImplCopyWith(
    _$SessionExpiredFailureImpl value,
    $Res Function(_$SessionExpiredFailureImpl) then,
  ) = __$$SessionExpiredFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SessionExpiredFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$SessionExpiredFailureImpl>
    implements _$$SessionExpiredFailureImplCopyWith<$Res> {
  __$$SessionExpiredFailureImplCopyWithImpl(
    _$SessionExpiredFailureImpl _value,
    $Res Function(_$SessionExpiredFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SessionExpiredFailureImpl implements SessionExpiredFailure {
  const _$SessionExpiredFailureImpl();

  @override
  String toString() {
    return 'Failure.sessionExpired()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionExpiredFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return sessionExpired();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return sessionExpired?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (sessionExpired != null) {
      return sessionExpired();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return sessionExpired(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return sessionExpired?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (sessionExpired != null) {
      return sessionExpired(this);
    }
    return orElse();
  }
}

abstract class SessionExpiredFailure implements Failure {
  const factory SessionExpiredFailure() = _$SessionExpiredFailureImpl;
}

/// @nodoc
abstract class _$$PasswordResetEmailSentFailureImplCopyWith<$Res> {
  factory _$$PasswordResetEmailSentFailureImplCopyWith(
    _$PasswordResetEmailSentFailureImpl value,
    $Res Function(_$PasswordResetEmailSentFailureImpl) then,
  ) = __$$PasswordResetEmailSentFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PasswordResetEmailSentFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$PasswordResetEmailSentFailureImpl>
    implements _$$PasswordResetEmailSentFailureImplCopyWith<$Res> {
  __$$PasswordResetEmailSentFailureImplCopyWithImpl(
    _$PasswordResetEmailSentFailureImpl _value,
    $Res Function(_$PasswordResetEmailSentFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PasswordResetEmailSentFailureImpl
    implements PasswordResetEmailSentFailure {
  const _$PasswordResetEmailSentFailureImpl();

  @override
  String toString() {
    return 'Failure.passwordResetEmailSent()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetEmailSentFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return passwordResetEmailSent();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return passwordResetEmailSent?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (passwordResetEmailSent != null) {
      return passwordResetEmailSent();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return passwordResetEmailSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return passwordResetEmailSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (passwordResetEmailSent != null) {
      return passwordResetEmailSent(this);
    }
    return orElse();
  }
}

abstract class PasswordResetEmailSentFailure implements Failure {
  const factory PasswordResetEmailSentFailure() =
      _$PasswordResetEmailSentFailureImpl;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(
    _$UnknownFailureImpl value,
    $Res Function(_$UnknownFailureImpl) then,
  ) = __$$UnknownFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
    _$UnknownFailureImpl _value,
    $Res Function(_$UnknownFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$UnknownFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.unknown(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function() invalidCredentials,
    required TResult Function() userNotFound,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() tooManyRequests,
    required TResult Function() sessionExpired,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String message) unknown,
  }) {
    return unknown(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function()? invalidCredentials,
    TResult? Function()? userNotFound,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? tooManyRequests,
    TResult? Function()? sessionExpired,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String message)? unknown,
  }) {
    return unknown?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function()? invalidCredentials,
    TResult Function()? userNotFound,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? tooManyRequests,
    TResult Function()? sessionExpired,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(UserNotFoundFailure value) userNotFound,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(TooManyRequestsFailure value) tooManyRequests,
    required TResult Function(SessionExpiredFailure value) sessionExpired,
    required TResult Function(PasswordResetEmailSentFailure value)
    passwordResetEmailSent,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(UserNotFoundFailure value)? userNotFound,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult? Function(SessionExpiredFailure value)? sessionExpired,
    TResult? Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(UserNotFoundFailure value)? userNotFound,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(TooManyRequestsFailure value)? tooManyRequests,
    TResult Function(SessionExpiredFailure value)? sessionExpired,
    TResult Function(PasswordResetEmailSentFailure value)?
    passwordResetEmailSent,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements Failure {
  const factory UnknownFailure({required final String message}) =
      _$UnknownFailureImpl;

  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
