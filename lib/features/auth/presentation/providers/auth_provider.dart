import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kudlit_ph/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:kudlit_ph/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kudlit_ph/features/auth/domain/repositories/auth_repository.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/reset_password.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:kudlit_ph/features/auth/domain/usecases/sign_out.dart';

part 'auth_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

@riverpod
SupabaseAuthDatasource supabaseAuthDatasource(Ref ref) {
  return SupabaseAuthDatasourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(supabaseAuthDatasourceProvider));
}

@riverpod
SignInWithEmail signInWithEmail(Ref ref) {
  return SignInWithEmail(ref.watch(authRepositoryProvider));
}

@riverpod
SignOut signOut(Ref ref) {
  return SignOut(ref.watch(authRepositoryProvider));
}

@riverpod
ResetPassword resetPassword(Ref ref) {
  return ResetPassword(ref.watch(authRepositoryProvider));
}
