import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart' as app_chat;

/// Cloud inference using Google Gemini API.
class CloudGemmaDatasource {
  CloudGemmaDatasource();

  GenerativeModel? _model;
  ChatSession? _chatSession;

  Future<bool> isAvailable() async {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    return apiKey != null && apiKey.isNotEmpty;
  }

  Stream<String> generate(
    List<app_chat.ChatMessage> history, {
    String? systemInstruction,
  }) async* {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Cloud inference not available. Add GEMINI_API_KEY to .env.');
    }

    // Initialize model if needed
    if (_model == null) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: systemInstruction != null
            ? Content.system(systemInstruction)
            : null,
      );
      
      // Seed the chat history (excluding the very last message which is the current query)
      final List<Content> geminiHistory = <Content>[];
      for (int i = 0; i < history.length - 1; i++) {
        final app_chat.ChatMessage msg = history[i];
        final List<Part> parts = <Part>[TextPart(msg.text)];
        if (msg.imageBytes != null) {
          parts.add(DataPart('image/jpeg', msg.imageBytes!));
        }
        geminiHistory.add(
          Content(msg.isUser ? 'user' : 'model', parts),
        );
      }
      
      _chatSession = _model!.startChat(history: geminiHistory);
    }

    if (history.isEmpty) return;

    final app_chat.ChatMessage lastMsg = history.last;
    final List<Part> parts = <Part>[TextPart(lastMsg.text)];
    if (lastMsg.imageBytes != null) {
      parts.add(DataPart('image/jpeg', lastMsg.imageBytes!));
    }

    final Stream<GenerateContentResponse> responseStream = 
        _chatSession!.sendMessageStream(Content.multi(parts));

    await for (final GenerateContentResponse response in responseStream) {
      if (response.text != null) {
        yield response.text!;
      }
    }
  }

  // ignore: avoid_unused_constructor_parameters
  Future<void> warmUp(AiModelInfo model) async {
    // No-op for cloud
  }

  Future<void> dispose() async {
    _model = null;
    _chatSession = null;
  }
}
