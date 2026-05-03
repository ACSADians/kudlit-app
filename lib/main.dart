import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/app/app.dart';
import 'package:kudlit_ph/core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  if (!kIsWeb) {
    final String hfToken = dotenv.env['HUGGINGFACE_TOKEN'] ?? '';
    await FlutterGemma.initialize(
      huggingFaceToken: hfToken.isEmpty ? null : hfToken,
    );
  }
  runApp(const ProviderScope(child: KudlitApp()));
}
