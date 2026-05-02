import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/verify_phone_otp.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late VerifyPhoneOtp useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyPhoneOtp(mockRepository);
  });

  const VerifyPhoneOtpParams tParams = VerifyPhoneOtpParams(
    phoneNumber: '+639171234567',
    token: '123456',
  );

  test('should return Unit when OTP is verified successfully', () async {
    when(
      () => mockRepository.verifyPhoneOtp(
        phoneNumber: any(named: 'phoneNumber'),
        token: any(named: 'token'),
      ),
    ).thenAnswer((_) async => right(unit));

    final Either<Failure, Unit> result = await useCase(tParams);

    expect(result, right(unit));
    verify(
      () => mockRepository.verifyPhoneOtp(
        phoneNumber: tParams.phoneNumber,
        token: tParams.token,
      ),
    ).called(1);
  });

  test('should return failure when OTP verification fails', () async {
    when(
      () => mockRepository.verifyPhoneOtp(
        phoneNumber: any(named: 'phoneNumber'),
        token: any(named: 'token'),
      ),
    ).thenAnswer((_) async => const Left(Failure.invalidCredentials()));

    final Either<Failure, Unit> result = await useCase(tParams);

    expect(result, const Left(Failure.invalidCredentials()));
  });
}
