import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/send_phone_otp.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SendPhoneOtp useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SendPhoneOtp(mockRepository);
  });

  const SendPhoneOtpParams tParams = SendPhoneOtpParams(
    phoneNumber: '+639171234567',
  );

  test('should return Unit when OTP is sent successfully', () async {
    when(
      () => mockRepository.sendPhoneOtp(phoneNumber: any(named: 'phoneNumber')),
    ).thenAnswer((_) async => right(unit));

    final Either<Failure, Unit> result = await useCase(tParams);

    expect(result, right(unit));
    verify(
      () => mockRepository.sendPhoneOtp(phoneNumber: tParams.phoneNumber),
    ).called(1);
  });

  test('should return failure when OTP send fails', () async {
    when(
      () => mockRepository.sendPhoneOtp(phoneNumber: any(named: 'phoneNumber')),
    ).thenAnswer((_) async => const Left(Failure.tooManyRequests()));

    final Either<Failure, Unit> result = await useCase(tParams);

    expect(result, const Left(Failure.tooManyRequests()));
  });
}
