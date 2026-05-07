// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure()';
}


}

/// @nodoc
class $FailureCopyWith<$Res>  {
$FailureCopyWith(Failure _, $Res Function(Failure) __);
}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkFailure value)?  network,TResult Function( InvalidCredentialsFailure value)?  invalidCredentials,TResult Function( UserNotFoundFailure value)?  userNotFound,TResult Function( EmailAlreadyInUseFailure value)?  emailAlreadyInUse,TResult Function( WeakPasswordFailure value)?  weakPassword,TResult Function( TooManyRequestsFailure value)?  tooManyRequests,TResult Function( SessionExpiredFailure value)?  sessionExpired,TResult Function( PasswordResetEmailSentFailure value)?  passwordResetEmailSent,TResult Function( UnknownFailure value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case InvalidCredentialsFailure() when invalidCredentials != null:
return invalidCredentials(_that);case UserNotFoundFailure() when userNotFound != null:
return userNotFound(_that);case EmailAlreadyInUseFailure() when emailAlreadyInUse != null:
return emailAlreadyInUse(_that);case WeakPasswordFailure() when weakPassword != null:
return weakPassword(_that);case TooManyRequestsFailure() when tooManyRequests != null:
return tooManyRequests(_that);case SessionExpiredFailure() when sessionExpired != null:
return sessionExpired(_that);case PasswordResetEmailSentFailure() when passwordResetEmailSent != null:
return passwordResetEmailSent(_that);case UnknownFailure() when unknown != null:
return unknown(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkFailure value)  network,required TResult Function( InvalidCredentialsFailure value)  invalidCredentials,required TResult Function( UserNotFoundFailure value)  userNotFound,required TResult Function( EmailAlreadyInUseFailure value)  emailAlreadyInUse,required TResult Function( WeakPasswordFailure value)  weakPassword,required TResult Function( TooManyRequestsFailure value)  tooManyRequests,required TResult Function( SessionExpiredFailure value)  sessionExpired,required TResult Function( PasswordResetEmailSentFailure value)  passwordResetEmailSent,required TResult Function( UnknownFailure value)  unknown,}){
final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that);case InvalidCredentialsFailure():
return invalidCredentials(_that);case UserNotFoundFailure():
return userNotFound(_that);case EmailAlreadyInUseFailure():
return emailAlreadyInUse(_that);case WeakPasswordFailure():
return weakPassword(_that);case TooManyRequestsFailure():
return tooManyRequests(_that);case SessionExpiredFailure():
return sessionExpired(_that);case PasswordResetEmailSentFailure():
return passwordResetEmailSent(_that);case UnknownFailure():
return unknown(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkFailure value)?  network,TResult? Function( InvalidCredentialsFailure value)?  invalidCredentials,TResult? Function( UserNotFoundFailure value)?  userNotFound,TResult? Function( EmailAlreadyInUseFailure value)?  emailAlreadyInUse,TResult? Function( WeakPasswordFailure value)?  weakPassword,TResult? Function( TooManyRequestsFailure value)?  tooManyRequests,TResult? Function( SessionExpiredFailure value)?  sessionExpired,TResult? Function( PasswordResetEmailSentFailure value)?  passwordResetEmailSent,TResult? Function( UnknownFailure value)?  unknown,}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case InvalidCredentialsFailure() when invalidCredentials != null:
return invalidCredentials(_that);case UserNotFoundFailure() when userNotFound != null:
return userNotFound(_that);case EmailAlreadyInUseFailure() when emailAlreadyInUse != null:
return emailAlreadyInUse(_that);case WeakPasswordFailure() when weakPassword != null:
return weakPassword(_that);case TooManyRequestsFailure() when tooManyRequests != null:
return tooManyRequests(_that);case SessionExpiredFailure() when sessionExpired != null:
return sessionExpired(_that);case PasswordResetEmailSentFailure() when passwordResetEmailSent != null:
return passwordResetEmailSent(_that);case UnknownFailure() when unknown != null:
return unknown(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message)?  network,TResult Function()?  invalidCredentials,TResult Function()?  userNotFound,TResult Function()?  emailAlreadyInUse,TResult Function()?  weakPassword,TResult Function()?  tooManyRequests,TResult Function()?  sessionExpired,TResult Function()?  passwordResetEmailSent,TResult Function( String message)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.message);case InvalidCredentialsFailure() when invalidCredentials != null:
return invalidCredentials();case UserNotFoundFailure() when userNotFound != null:
return userNotFound();case EmailAlreadyInUseFailure() when emailAlreadyInUse != null:
return emailAlreadyInUse();case WeakPasswordFailure() when weakPassword != null:
return weakPassword();case TooManyRequestsFailure() when tooManyRequests != null:
return tooManyRequests();case SessionExpiredFailure() when sessionExpired != null:
return sessionExpired();case PasswordResetEmailSentFailure() when passwordResetEmailSent != null:
return passwordResetEmailSent();case UnknownFailure() when unknown != null:
return unknown(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message)  network,required TResult Function()  invalidCredentials,required TResult Function()  userNotFound,required TResult Function()  emailAlreadyInUse,required TResult Function()  weakPassword,required TResult Function()  tooManyRequests,required TResult Function()  sessionExpired,required TResult Function()  passwordResetEmailSent,required TResult Function( String message)  unknown,}) {final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that.message);case InvalidCredentialsFailure():
return invalidCredentials();case UserNotFoundFailure():
return userNotFound();case EmailAlreadyInUseFailure():
return emailAlreadyInUse();case WeakPasswordFailure():
return weakPassword();case TooManyRequestsFailure():
return tooManyRequests();case SessionExpiredFailure():
return sessionExpired();case PasswordResetEmailSentFailure():
return passwordResetEmailSent();case UnknownFailure():
return unknown(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message)?  network,TResult? Function()?  invalidCredentials,TResult? Function()?  userNotFound,TResult? Function()?  emailAlreadyInUse,TResult? Function()?  weakPassword,TResult? Function()?  tooManyRequests,TResult? Function()?  sessionExpired,TResult? Function()?  passwordResetEmailSent,TResult? Function( String message)?  unknown,}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.message);case InvalidCredentialsFailure() when invalidCredentials != null:
return invalidCredentials();case UserNotFoundFailure() when userNotFound != null:
return userNotFound();case EmailAlreadyInUseFailure() when emailAlreadyInUse != null:
return emailAlreadyInUse();case WeakPasswordFailure() when weakPassword != null:
return weakPassword();case TooManyRequestsFailure() when tooManyRequests != null:
return tooManyRequests();case SessionExpiredFailure() when sessionExpired != null:
return sessionExpired();case PasswordResetEmailSentFailure() when passwordResetEmailSent != null:
return passwordResetEmailSent();case UnknownFailure() when unknown != null:
return unknown(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class NetworkFailure implements Failure {
  const NetworkFailure({required this.message});
  

 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkFailureCopyWith<NetworkFailure> get copyWith => _$NetworkFailureCopyWithImpl<NetworkFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.network(message: $message)';
}


}

/// @nodoc
abstract mixin class $NetworkFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NetworkFailureCopyWith(NetworkFailure value, $Res Function(NetworkFailure) _then) = _$NetworkFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$NetworkFailureCopyWithImpl<$Res>
    implements $NetworkFailureCopyWith<$Res> {
  _$NetworkFailureCopyWithImpl(this._self, this._then);

  final NetworkFailure _self;
  final $Res Function(NetworkFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NetworkFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class InvalidCredentialsFailure implements Failure {
  const InvalidCredentialsFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidCredentialsFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.invalidCredentials()';
}


}




/// @nodoc


class UserNotFoundFailure implements Failure {
  const UserNotFoundFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserNotFoundFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.userNotFound()';
}


}




/// @nodoc


class EmailAlreadyInUseFailure implements Failure {
  const EmailAlreadyInUseFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailAlreadyInUseFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.emailAlreadyInUse()';
}


}




/// @nodoc


class WeakPasswordFailure implements Failure {
  const WeakPasswordFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeakPasswordFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.weakPassword()';
}


}




/// @nodoc


class TooManyRequestsFailure implements Failure {
  const TooManyRequestsFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TooManyRequestsFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.tooManyRequests()';
}


}




/// @nodoc


class SessionExpiredFailure implements Failure {
  const SessionExpiredFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionExpiredFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.sessionExpired()';
}


}




/// @nodoc


class PasswordResetEmailSentFailure implements Failure {
  const PasswordResetEmailSentFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetEmailSentFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.passwordResetEmailSent()';
}


}




/// @nodoc


class UnknownFailure implements Failure {
  const UnknownFailure({required this.message});
  

 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownFailureCopyWith<UnknownFailure> get copyWith => _$UnknownFailureCopyWithImpl<UnknownFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.unknown(message: $message)';
}


}

/// @nodoc
abstract mixin class $UnknownFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnknownFailureCopyWith(UnknownFailure value, $Res Function(UnknownFailure) _then) = _$UnknownFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$UnknownFailureCopyWithImpl<$Res>
    implements $UnknownFailureCopyWith<$Res> {
  _$UnknownFailureCopyWithImpl(this._self, this._then);

  final UnknownFailure _self;
  final $Res Function(UnknownFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(UnknownFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
