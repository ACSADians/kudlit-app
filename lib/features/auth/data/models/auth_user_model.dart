import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    super.displayName,
  });

  factory AuthUserModel.fromSupabaseUser(User user) {
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
    );
  }
}
