import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_environment.dart';

class SupabaseClients {
  const SupabaseClients._();

  static SupabaseClient? get maybeClient {
    if (!AppEnvironment.hasSupabaseConfig) {
      return null;
    }

    return Supabase.instance.client;
  }
}
