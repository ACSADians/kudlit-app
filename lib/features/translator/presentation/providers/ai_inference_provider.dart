// ignore: unnecessary_import — flutter_riverpod is needed for AsyncNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

part 'ai_inference_provider.g.dart';

/// Global, lazy AI inference notifier.
///
/// Not instantiated until first read. Once read it stays alive
/// (`keepAlive: true`) and routes to the correct backend
/// (local `flutter_gemma` or cloud stub) based on `AiPreference`.
@Riverpod(keepAlive: true)
class AiInferenceNotifier extends _$AiInferenceNotifier {
  @override
  Future<AiInferenceState> build() async {
    // Don't interrupt an active download triggered from the setup screen.
    final AiInferenceState? prev = state.value;
    if (prev is AiDownloading) return prev;

    final AiInferenceRepository repo = ref.watch(aiInferenceRepositoryProvider);
    final AppPreferences prefs = await ref.watch(
      appPreferencesNotifierProvider.future,
    );

    final Either<Failure, List<GemmaModelInfo>> modelsResult = await repo
        .getAvailableModels();
    if (modelsResult.isLeft()) {
      final Failure f = modelsResult.getLeft().getOrElse(
        () => const Failure.unknown(message: 'unknown'),
      );
      return AiInferenceError(_failureMessage(f));
    }
    final List<GemmaModelInfo> models = modelsResult.getRight().getOrElse(
      () => <GemmaModelInfo>[],
    );
    return _resolveInitialState(repo: repo, models: models, prefs: prefs);
  }

  Future<AiInferenceState> _resolveInitialState({
    required AiInferenceRepository repo,
    required List<GemmaModelInfo> models,
    required AppPreferences prefs,
  }) async {
    if (models.isEmpty) {
      return const AiInferenceError('No AI models configured.');
    }

    final GemmaModelInfo active = _resolveActiveModel(
      models,
      preferredId: prefs.selectedModelId,
    );

    if (prefs.aiPreference == AiPreference.cloud) {
      return AiReady(mode: AiPreference.cloud, activeModel: active);
    }

    final Either<Failure, bool> installedResult = await repo
        .isLocalModelInstalled(active);
    if (installedResult.isLeft()) {
      final Failure f = installedResult.getLeft().getOrElse(
        () => const Failure.unknown(message: 'unknown'),
      );
      return AiInferenceError(_failureMessage(f));
    }
    final bool installed = installedResult.getRight().getOrElse(() => false);
    return installed
        ? AiReady(mode: AiPreference.local, activeModel: active)
        : AiLocalModelMissing(active);
  }

  /// Picks the median-ranked model unless [preferredId] is set
  /// and present in the catalog.
  GemmaModelInfo _resolveActiveModel(
    List<GemmaModelInfo> models, {
    String? preferredId,
  }) {
    if (preferredId != null) {
      for (final GemmaModelInfo m in models) {
        if (m.id == preferredId) return m;
      }
    }
    final List<GemmaModelInfo> sorted = <GemmaModelInfo>[...models]
      ..sort((GemmaModelInfo a, GemmaModelInfo b) => a.id.compareTo(b.id));
    return sorted[sorted.length ~/ 2];
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Starts/continues the local model download. Updates state with
  /// progress and ends in [AiReady] on success.
  Future<void> downloadLocalModel() async {
    final AiInferenceState? current = state.value;
    final GemmaModelInfo? model = switch (current) {
      AiLocalModelMissing(:final GemmaModelInfo model) => model,
      AiDownloading(:final GemmaModelInfo model) => model,
      _ => null,
    };
    if (model == null) return;

    state = AsyncData(AiDownloading(model: model, progress: 0));

    final AiInferenceRepository repo = ref.read(aiInferenceRepositoryProvider);
    final Either<Failure, Unit> result = await repo.downloadLocalModel(
      model,
      onProgress: (int progress) {
        state = AsyncData(AiDownloading(model: model, progress: progress));
      },
    );

    state = AsyncData(
      result.isRight()
          ? AiReady(mode: AiPreference.local, activeModel: model)
          : AiInferenceError(
              _failureMessage(
                result.getLeft().getOrElse(
                  () => const Failure.unknown(message: 'download failed'),
                ),
              ),
            ),
    );
  }

  void cancelDownload() {
    ref.read(aiInferenceRepositoryProvider).cancelDownload();
  }

  /// Starts a download for [model] unconditionally — used by the
  /// model setup screen where the inference state may still be `AiReady(cloud)`.
  ///
  /// Safe to call fire-and-forget; the `build()` guard preserves
  /// `AiDownloading` state even if prefs change mid-download.
  Future<void> triggerLocalDownload(GemmaModelInfo model) async {
    state = AsyncData(AiDownloading(model: model, progress: 0));

    final AiInferenceRepository repo = ref.read(aiInferenceRepositoryProvider);
    final Either<Failure, Unit> result = await repo.downloadLocalModel(
      model,
      onProgress: (int progress) {
        state = AsyncData(AiDownloading(model: model, progress: progress));
      },
    );

    state = AsyncData(
      result.isRight()
          ? AiReady(mode: AiPreference.local, activeModel: model)
          : AiInferenceError(
              _failureMessage(
                result.getLeft().getOrElse(
                  () => const Failure.unknown(message: 'download failed'),
                ),
              ),
            ),
    );
  }

  /// Persist a different active model and reload state.
  Future<void> setActiveModel(GemmaModelInfo model) async {
    await ref
        .read(appPreferencesNotifierProvider.notifier)
        .setSelectedModel(model.id);
    ref.invalidateSelf();
  }

  /// Streams model output. Caller is responsible for appending the
  /// user message to history first.
  Stream<String> generateResponse(
    List<ChatMessage> history, {
    String? systemInstruction,
  }) {
    return ref
        .read(aiInferenceRepositoryProvider)
        .generateResponse(history, systemInstruction: systemInstruction);
  }

  String _failureMessage(Failure f) => switch (f) {
    NetworkFailure(:final String message) => message,
    UnknownFailure(:final String message) => message,
    _ => 'Unexpected error',
  };
}
