import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({
    required String message,
  }) = NetworkFailure;

  const factory Failure.invalidCredentials() = InvalidCredentialsFailure;

  const factory Failure.userNotFound() = UserNotFoundFailure;

  const factory Failure.emailAlreadyInUse() = EmailAlreadyInUseFailure;

  const factory Failure.weakPassword() = WeakPasswordFailure;

  const factory Failure.tooManyRequests() = TooManyRequestsFailure;

  const factory Failure.sessionExpired() = SessionExpiredFailure;

  const factory Failure.passwordResetEmailSent() = PasswordResetEmailSentFailure;

  const factory Failure.unknown({
    required String message,
  }) = UnknownFailure;
}
