import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/sign_in_with_email.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithEmail useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmail(mockRepository);
  });

  const AuthUser tUser = AuthUser(id: '123', email: 'test@test.com');
  const SignInWithEmailParams tParams = SignInWithEmailParams(
    email: 'test@test.com',
    password: 'password123',
  );

  test('should return AuthUser when repository succeeds', () async {
    when(
      () => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right(tUser));

    final Either<Failure, AuthUser> result = await useCase(tParams);

    expect(result, const Right(tUser));
    verify(
      () => mockRepository.signInWithEmail(
        email: tParams.email,
        password: tParams.password,
      ),
    ).called(1);
  });

  test('should return InvalidCredentialsFailure on bad credentials', () async {
    when(
      () => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Left(Failure.invalidCredentials()));

    final Either<Failure, AuthUser> result = await useCase(tParams);

    expect(result, const Left(Failure.invalidCredentials()));
  });

  test('should return NetworkFailure on network error', () async {
    when(
      () => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const Left(Failure.network(message: 'No connection')),
    );

    final Either<Failure, AuthUser> result = await useCase(tParams);

    expect(result, const Left(Failure.network(message: 'No connection')));
  });
}
