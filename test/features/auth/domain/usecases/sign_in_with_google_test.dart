import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithGoogle useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithGoogle(mockRepository);
  });

  test(
    'should return Unit when google sign in is started successfully',
    () async {
      when(
        () => mockRepository.signInWithGoogle(),
      ).thenAnswer((_) async => right(unit));

      final Either<Failure, Unit> result = await useCase(const NoParams());

      expect(result, right(unit));
      verify(() => mockRepository.signInWithGoogle()).called(1);
    },
  );

  test('should return failure when google sign in fails', () async {
    when(
      () => mockRepository.signInWithGoogle(),
    ).thenAnswer((_) async => const Left(Failure.tooManyRequests()));

    final Either<Failure, Unit> result = await useCase(const NoParams());

    expect(result, const Left(Failure.tooManyRequests()));
  });
}
