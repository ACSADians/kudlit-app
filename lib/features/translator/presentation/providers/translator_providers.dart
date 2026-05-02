// ignore: unnecessary_import — flutter_riverpod is needed for Ref resolution
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/features/auth/presentation/providers/auth_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/translator/data/datasources/cloud_gemma_datasource.dart';
import 'package:kudlit_ph/features/translator/data/datasources/local_gemma_datasource.dart';
import 'package:kudlit_ph/features/translator/data/datasources/sqlite_chat_datasource.dart';
import 'package:kudlit_ph/features/translator/data/datasources/supabase_ai_models_datasource.dart';
import 'package:kudlit_ph/features/translator/data/datasources/supabase_gemma_models_datasource.dart';
import 'package:kudlit_ph/features/translator/data/repositories/ai_inference_repository_impl.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';
import 'package:kudlit_ph/features/translator/domain/usecases/analyze_baybayin_image.dart';
import 'package:kudlit_ph/features/translator/domain/usecases/generate_baybayin_challenge.dart';

part 'translator_providers.g.dart';

@riverpod
Future<List<GemmaModelInfo>> availableGemmaModels(Ref ref) async {
  final SupabaseGemmaModelsDatasource ds = ref.watch(
    supabaseGemmaModelsDatasourceProvider,
  );
  return ds.fetchModels();
}

@Riverpod(keepAlive: true)
SupabaseAiModelsDatasource supabaseAiModelsDatasource(Ref ref) {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  return SupabaseAiModelsDatasourceImpl(client);
}

@Riverpod(keepAlive: true)
SupabaseGemmaModelsDatasource supabaseGemmaModelsDatasource(Ref ref) {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  return SupabaseGemmaModelsDatasourceImpl(client);
}

@Riverpod(keepAlive: true)
LocalGemmaDatasource localGemmaDatasource(Ref ref) {
  final LocalGemmaDatasource ds = LocalGemmaDatasource();
  ref.onDispose(ds.dispose);
  return ds;
}

@Riverpod(keepAlive: true)
CloudGemmaDatasource cloudGemmaDatasource(Ref ref) {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final CloudGemmaDatasource ds = CloudGemmaDatasource(apiKey: apiKey);
  ref.onDispose(ds.dispose);
  return ds;
}

@Riverpod(keepAlive: true)
SqliteChatDatasource sqliteChatDatasource(Ref ref) {
  final SqliteChatDatasource ds = SqliteChatDatasource();
  ref.onDispose(ds.dispose);
  return ds;
}

@Riverpod(keepAlive: true)
AiInferenceRepository aiInferenceRepository(Ref ref) {
  final AiInferenceRepositoryImpl repo = AiInferenceRepositoryImpl(
    modelsDatasource: ref.watch(supabaseGemmaModelsDatasourceProvider),
    localDatasource: ref.watch(localGemmaDatasourceProvider),
    cloudDatasource: ref.watch(cloudGemmaDatasourceProvider),
    preferenceResolver: () {
      final AsyncValue<AppPreferences> prefs = ref.read(
        appPreferencesNotifierProvider,
      );
      return prefs.value?.aiPreference ?? AiPreference.cloud;
    },
  );
  ref.onDispose(repo.dispose);
  return repo;
}

@Riverpod(keepAlive: true)
AnalyzeBaybayinImage analyzeBaybayinImage(Ref ref) {
  return AnalyzeBaybayinImage(ref.watch(aiInferenceRepositoryProvider));
}

@Riverpod(keepAlive: true)
GenerateBaybayinChallenge generateBaybayinChallenge(Ref ref) {
  return GenerateBaybayinChallenge(ref.watch(aiInferenceRepositoryProvider));
}
