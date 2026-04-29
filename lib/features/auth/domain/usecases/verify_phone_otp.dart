import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';

class VerifyPhoneOtpParams {
  const VerifyPhoneOtpParams({required this.phoneNumber, required this.token});

  final String phoneNumber;
  final String token;
}

class VerifyPhoneOtp implements UseCase<Unit, VerifyPhoneOtpParams> {
  const VerifyPhoneOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(VerifyPhoneOtpParams params) {
    return _repository.verifyPhoneOtp(
      phoneNumber: params.phoneNumber,
      token: params.token,
    );
  }
}
