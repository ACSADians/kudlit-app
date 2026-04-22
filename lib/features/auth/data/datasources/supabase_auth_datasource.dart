import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/auth/data/models/auth_user_model.dart';

abstract interface class SupabaseAuthDatasource {
  Stream<AuthUserModel?> get authStateChanges;

  AuthUserModel? get currentUser;

  Future<AuthUserModel> signInWithEmail({
    required String email,
    required String password,
  });

  // Returns true when email confirmation is pending; false when auto-confirmed.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({required String email});
}

class SupabaseAuthDatasourceImpl implements SupabaseAuthDatasource {
  const SupabaseAuthDatasourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthUserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((AuthState event) {
      final User? user = event.session?.user;
      if (user == null) return null;
      return AuthUserModel.fromSupabaseUser(user);
    });
  }

  @override
  AuthUserModel? get currentUser {
    final User? user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthUserModel.fromSupabaseUser(user);
  }

  @override
  Future<AuthUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = response.user;
      if (user == null) {
        throw const ServerException(message: 'Sign in returned no user.');
      }
      return AuthUserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const ServerException(message: 'Sign up returned no user.');
      }
      return response.session == null;
    } on AuthException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'kudlit://auth/reset',
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
