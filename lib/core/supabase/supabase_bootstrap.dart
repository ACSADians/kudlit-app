import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_environment.dart';

class SupabaseBootstrap {
  const SupabaseBootstrap._();

  static Future<void> initialize() async {
    if (!AppEnvironment.hasSupabaseConfig) {
      return;
    }

    await Supabase.initialize(
      url: AppEnvironment.supabaseUrl,
      anonKey: AppEnvironment.supabaseAnonKey,
    );
  }
}
