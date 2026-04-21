import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailParams {
  const SignInWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignInWithEmail implements UseCase<AuthUser, SignInWithEmailParams> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUser>> call(SignInWithEmailParams params) {
    return _repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
