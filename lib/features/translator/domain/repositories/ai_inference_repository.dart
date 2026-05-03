import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/translator/domain/entities/baybayin_challenge.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';

/// Single contract that hides whether inference runs locally
/// (`flutter_gemma`) or in the cloud (Gemini via Genkit).
abstract interface class AiInferenceRepository {
  /// Fetches the catalog of available models from Supabase,
  /// ordered by `sort_order ASC`.
  Future<Either<Failure, List<GemmaModelInfo>>> getAvailableModels();

  /// Returns true if the local copy of [model] is already on disk.
  Future<Either<Failure, bool>> isLocalModelInstalled(GemmaModelInfo model);

  /// Downloads [model] for on-device inference.
  ///
  /// The download runs in the background (Android foreground service for
  /// >500 MB; iOS discretionary `NSURLSession`) and survives app
  /// backgrounding. [onProgress] receives values 0..100.
  Future<Either<Failure, Unit>> downloadLocalModel(
    GemmaModelInfo model, {
    void Function(int progress)? onProgress,
  });

  /// Cancels the in-flight model download, if any.
  void cancelDownload();

  // ─── 1. Scoped chat ───────────────────────────────────────────────────────

  /// Streams generated tokens for the given [history].
  ///
  /// Implementation chooses local vs. cloud based on the user's
  /// `AiPreference`. The stream completes when generation ends.
  Stream<String> generateResponse(
    List<ChatMessage> history, {
    String? systemInstruction,
  });

  // ─── 2. Image analysis ────────────────────────────────────────────────────

  /// Streams a description / translation of drawn or photographed
  /// Baybayin characters in [imageBytes].
  ///
  /// Always routes to the cloud datasource (requires network).
  /// [mimeType] defaults to `'image/png'`.
  Stream<String> analyzeImage(
    Uint8List imageBytes, {
    String mimeType,
    String? prompt,
  });

  // ─── 3. Challenge generation ──────────────────────────────────────────────

  /// Generates a single Baybayin learning challenge via the cloud AI.
  ///
  /// Optionally scope to a subset of [characters].
  Future<Either<Failure, BaybayinChallenge>> generateChallenge({
    List<String>? characters,
  });

  /// Releases native resources (closes model session).
  Future<void> dispose();
}
