import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/translator/data/datasources/ai_datasource.dart';
import 'package:kudlit_ph/features/translator/data/datasources/local_gemma_datasource.dart';
import 'package:kudlit_ph/features/translator/data/datasources/supabase_gemma_models_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/baybayin_challenge.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';

class AiInferenceRepositoryImpl implements AiInferenceRepository {
  AiInferenceRepositoryImpl({
    required this.modelsDatasource,
    required this.localDatasource,
    required this.cloudDatasource,
    required this.preferenceResolver,
  });

  final SupabaseGemmaModelsDatasource modelsDatasource;
  final LocalGemmaDatasource localDatasource;
  final AiDatasource cloudDatasource;

  /// Resolves the current [AiPreference] at call time.
  /// Allows the repo to react to preference changes without holding
  /// a stale snapshot.
  final AiPreference Function() preferenceResolver;

  bool get _useCloud => kIsWeb || preferenceResolver() == AiPreference.cloud;

  @override
  Future<Either<Failure, List<GemmaModelInfo>>> getAvailableModels() async {
    try {
      final List<GemmaModelInfo> models = await modelsDatasource.fetchModels();
      return right(models);
    } on ServerException catch (e) {
      return left(Failure.network(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLocalModelInstalled(
    GemmaModelInfo model,
  ) async {
    if (kIsWeb) {
      return right(false);
    }
    try {
      final bool installed = await localDatasource.isInstalled(model);
      return right(installed);
    } on ServerException catch (e) {
      return left(Failure.unknown(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> downloadLocalModel(
    GemmaModelInfo model, {
    void Function(int progress)? onProgress,
  }) async {
    if (kIsWeb) {
      return left(
        const Failure.unknown(
          message: 'Local model download is unsupported on web.',
        ),
      );
    }
    try {
      await localDatasource.download(model, onProgress: onProgress);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure.network(message: e.message));
    }
  }

  @override
  void cancelDownload() {
    if (!kIsWeb) {
      localDatasource.cancelDownload();
    }
  }

  @override
  Stream<String> generateResponse(
    List<ChatMessage> history, {
    String? systemInstruction,
  }) {
    if (_useCloud) {
      return cloudDatasource.generate(
        history,
        systemInstruction: systemInstruction,
      );
    }
    return localDatasource.generate(
      history,
      systemInstruction: systemInstruction,
    );
  }

  // ─── 2. Image analysis ────────────────────────────────────────────────────

  @override
  Stream<String> analyzeImage(
    Uint8List imageBytes, {
    String mimeType = 'image/png',
    String? prompt,
  }) {
    // Always cloud — local model does not support vision input.
    return cloudDatasource.analyzeImage(
      imageBytes,
      mimeType: mimeType,
      prompt: prompt,
    );
  }

  // ─── 3. Challenge generation ──────────────────────────────────────────────

  @override
  Future<Either<Failure, BaybayinChallenge>> generateChallenge({
    List<String>? characters,
  }) async {
    try {
      final BaybayinChallenge challenge = await cloudDatasource
          .generateChallenge(characters: characters);
      return right(challenge);
    } on ServerException catch (e) {
      return left(Failure.network(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<void> dispose() async {
    await Future.wait(<Future<void>>[
      localDatasource.dispose(),
      cloudDatasource.dispose(),
    ]);
  }
}
