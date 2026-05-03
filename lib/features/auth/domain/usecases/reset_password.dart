import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams {
  const ResetPasswordParams({required this.email});

  final String email;
}

class ResetPassword implements UseCase<Unit, ResetPasswordParams> {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) {
    return _repository.resetPassword(email: params.email);
  }
}
