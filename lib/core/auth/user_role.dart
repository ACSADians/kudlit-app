/// RBAC roles for the Kudlit app.
///
/// - [user] — default for all sign-ups; read-only access to public content.
/// - [admin] — manually assigned via Supabase dashboard; can record stroke
///   patterns and access admin-only tools.
enum UserRole {
  user,
  admin;

  static UserRole fromString(String? value) {
    if (value == 'admin') return UserRole.admin;
    return UserRole.user;
  }

  bool get isAdmin => this == UserRole.admin;
}
