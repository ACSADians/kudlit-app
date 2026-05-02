import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';

class SendPhoneOtpParams {
  const SendPhoneOtpParams({required this.phoneNumber});

  final String phoneNumber;
}

class SendPhoneOtp implements UseCase<Unit, SendPhoneOtpParams> {
  const SendPhoneOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SendPhoneOtpParams params) {
    return _repository.sendPhoneOtp(phoneNumber: params.phoneNumber);
  }
}
