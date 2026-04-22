import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/reset_password.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/sign_out.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_provider.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  StreamSubscription<AuthUser?>? _subscription;

  @override
  AsyncValue<AuthUser?> build() {
    final AuthRepository repository = ref.watch(authRepositoryProvider);

    _subscription?.cancel();
    _subscription = repository.authStateChanges.listen(
      (AuthUser? user) => state = AsyncData(user),
      onError: (Object error) =>
          state = AsyncError(error, StackTrace.current),
    );

    ref.onDispose(() => _subscription?.cancel());

    // Return current user synchronously to avoid loading flash
    return AsyncData(repository.currentUser);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final SignInWithEmail useCase = ref.read(signInWithEmailProvider);
    final Either<Failure, AuthUser> result = await useCase(
      SignInWithEmailParams(email: email, password: password),
    );
    result.fold(
      (Failure failure) => state = AsyncError(failure, StackTrace.current),
      (AuthUser user) => state = AsyncData(user),
    );
  }

  Future<Either<Failure, bool>> signUp({
    required String email,
    required String password,
  }) async {
    final SignUpWithEmail useCase = ref.read(signUpWithEmailProvider);
    return useCase(SignUpWithEmailParams(email: email, password: password));
  }

  Future<void> signOut() async {
    final SignOut useCase = ref.read(signOutProvider);
    await useCase(const NoParams());
    // Auth stream emits null and updates state automatically
  }

  Future<Either<Failure, Unit>> resetPassword({required String email}) async {
    final ResetPassword useCase = ref.read(resetPasswordProvider);
    return useCase(ResetPasswordParams(email: email));
  }
}
