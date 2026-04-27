import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

/// Stub for cloud inference (Gemini API).
///
/// All methods throw [UnimplementedError] until an API key is wired
/// into `.env` and a real client is added.
class CloudGemmaDatasource {
  const CloudGemmaDatasource();

  Future<bool> isAvailable() async {
    // TODO: wire Gemini API — return true once API key is configured.
    return false;
  }

  Stream<String> generate(
    List<ChatMessage> history, {
    String? systemInstruction,
  }) {
    // TODO: wire Gemini API
    throw UnimplementedError(
      'Cloud inference not yet wired. Add GEMINI_API_KEY to .env first.',
    );
  }

  // ignore: avoid_unused_constructor_parameters
  Future<void> warmUp(AiModelInfo model) async {
    // No-op until cloud is wired.
  }

  Future<void> dispose() async {}
}
