import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';

class SignUpWithEmailParams {
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

// Returns true when email confirmation is pending; false when auto-confirmed.
class SignUpWithEmail implements UseCase<bool, SignUpWithEmailParams> {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, bool>> call(SignUpWithEmailParams params) {
    return _repository.signUpWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
