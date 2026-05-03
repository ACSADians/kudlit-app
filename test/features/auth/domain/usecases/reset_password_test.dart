import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/reset_password.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ResetPassword useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResetPassword(mockRepository);
  });

  const ResetPasswordParams tParams = ResetPasswordParams(
    email: 'test@test.com',
  );

  test('should return Unit when reset email is sent successfully', () async {
    when(
      () => mockRepository.resetPassword(email: any(named: 'email')),
    ).thenAnswer((_) async => right(unit));

    final Either<Failure, Unit> result = await useCase(tParams);

    expect(result, right(unit));
    verify(() => mockRepository.resetPassword(email: tParams.email)).called(1);
  });

  test('should return UserNotFoundFailure when email not registered', () async {
    when(
      () => mockRepository.resetPassword(email: any(named: 'email')),
    ).thenAnswer((_) async => const Left(Failure.userNotFound()));

    final Either<Failure, Unit> result = await useCase(tParams);

    expect(result, const Left(Failure.userNotFound()));
  });
}
