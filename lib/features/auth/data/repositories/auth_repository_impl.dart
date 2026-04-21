import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final SupabaseAuthDatasource _datasource;

  @override
  Stream<AuthUser?> get authStateChanges => _datasource.authStateChanges;

  @override
  AuthUser? get currentUser => _datasource.currentUser;

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthUser user = await _datasource.signInWithEmail(
        email: email,
        password: password,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(_mapServerExceptionToFailure(e));
    } on Exception {
      return left(const Failure.network(message: 'Unexpected network error.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _datasource.signOut();
      return right(unit);
    } on ServerException catch (e) {
      return left(_mapServerExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({required String email}) async {
    try {
      await _datasource.resetPassword(email: email);
      return right(unit);
    } on ServerException catch (e) {
      return left(_mapServerExceptionToFailure(e));
    }
  }

  Failure _mapServerExceptionToFailure(ServerException e) {
    final String msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid password')) {
      return const Failure.invalidCredentials();
    }
    if (msg.contains('user not found') || msg.contains('no user found')) {
      return const Failure.userNotFound();
    }
    if (msg.contains('email already') || msg.contains('already registered')) {
      return const Failure.emailAlreadyInUse();
    }
    if (msg.contains('too many requests') || e.statusCode == 429) {
      return const Failure.tooManyRequests();
    }
    if (msg.contains('weak password') || msg.contains('password should be')) {
      return const Failure.weakPassword();
    }
    return Failure.unknown(message: e.message);
  }
}
