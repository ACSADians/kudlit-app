import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

/// Single contract that hides whether inference runs locally
/// (`flutter_gemma`) or in the cloud (Gemini API, future).
abstract interface class AiInferenceRepository {
  /// Fetches the catalog of available models from Supabase,
  /// ordered by `sort_order ASC`.
  Future<Either<Failure, List<AiModelInfo>>> getAvailableModels();

  /// Returns true if the local copy of [model] is already on disk.
  Future<Either<Failure, bool>> isLocalModelInstalled(AiModelInfo model);

  /// Downloads [model] for on-device inference.
  ///
  /// The download runs in the background (Android foreground service for
  /// >500 MB; iOS discretionary `NSURLSession`) and survives app
  /// backgrounding. [onProgress] receives values 0..100.
  Future<Either<Failure, Unit>> downloadLocalModel(
    AiModelInfo model, {
    void Function(int progress)? onProgress,
  });

  /// Cancels the in-flight model download, if any.
  void cancelDownload();

  /// Streams generated tokens for the given [history].
  ///
  /// Implementation chooses local vs. cloud based on the user's
  /// `AiPreference`. The stream completes when generation ends.
  Stream<String> generateResponse(
    List<ChatMessage> history, {
    String? systemInstruction,
  });

  /// Releases native resources (closes model session).
  Future<void> dispose();
}
