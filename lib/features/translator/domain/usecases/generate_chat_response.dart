import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';

class GenerateChatResponseParams {
  const GenerateChatResponseParams({
    required this.history,
    this.systemInstruction,
  });

  final List<ChatMessage> history;
  final String? systemInstruction;
}

/// Streaming use case — does not implement [UseCase] because
/// the base class is `Future`-shaped, not `Stream`-shaped.
class GenerateChatResponse {
  const GenerateChatResponse(this._repository);

  final AiInferenceRepository _repository;

  Stream<String> call(GenerateChatResponseParams params) {
    return _repository.generateResponse(
      params.history,
      systemInstruction: params.systemInstruction,
    );
  }
}
