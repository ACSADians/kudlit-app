import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/sign_up_status.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/sign_up_with_email.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpWithEmail useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpWithEmail(mockRepository);
  });

  const SignUpWithEmailParams tParams = SignUpWithEmailParams(
    email: 'test@test.com',
    password: 'password123',
  );

  test(
    'should return confirmationPending when email confirmation is required',
    () async {
      when(
        () => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(SignUpStatus.confirmationPending));

      final Either<Failure, SignUpStatus> result = await useCase(tParams);

      expect(result, const Right(SignUpStatus.confirmationPending));
      verify(
        () => mockRepository.signUpWithEmail(
          email: tParams.email,
          password: tParams.password,
        ),
      ).called(1);
    },
  );

  test('should return autoConfirmed when signup creates a session', () async {
    when(
      () => mockRepository.signUpWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right(SignUpStatus.autoConfirmed));

    final Either<Failure, SignUpStatus> result = await useCase(tParams);

    expect(result, const Right(SignUpStatus.autoConfirmed));
  });

  test('should return failure when repository signup fails', () async {
    when(
      () => mockRepository.signUpWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Left(Failure.emailAlreadyInUse()));

    final Either<Failure, SignUpStatus> result = await useCase(tParams);

    expect(result, const Left(Failure.emailAlreadyInUse()));
  });
}
