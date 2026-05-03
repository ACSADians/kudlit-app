import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:genkit/genkit.dart';
// ignore: implementation_imports
import 'package:genkit/src/ai/generate.dart' show GenerateResponse;
import 'package:genkit_google_genai/genkit_google_genai.dart';

import 'package:kudlit_ph/features/translator/data/datasources/ai_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/baybayin_challenge.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

/// The model used for all cloud Baybayin inference. (using Gemma)
const String _kModel = 'gemma-4-26b-a4b-it';

/// System prompt that scopes Butty to Baybayin / Filipino culture only.
const String _kChatSystemPrompt = '''
You are Butty, a friendly Baybayin learning companion inside the Kudlit app.
You ONLY discuss topics related to Baybayin script, the Filipino language,
Philippine history, and Filipino culture. Politely decline anything else.
Keep answers concise and encouraging. Use simple Tagalog/English mixed responses.
''';

/// System prompt for the challenge generator.
const String _kChallengeSystemPrompt = '''
You are a Baybayin quiz engine. Respond ONLY with valid JSON matching the
schema below and nothing else — no markdown fences, no extra keys.

Schema:
{
  "type": "writeCharacter" | "identifyCharacter" | "translateWord",
  "prompt": "<instruction for the learner>",
  "answer": "<correct answer>",
  "targetGlyph": "<Baybayin glyph, if applicable, else null>",
  "hint": "<one-sentence hint, or null>"
}
''';

/// Live cloud inference datasource powered by Genkit + Google AI (Gemini).
///
/// One instance is kept alive for the lifetime of the app via the
/// `cloudGemmaDatasourceProvider`.
class CloudGemmaDatasource implements AiDatasource {
  /// Production constructor — creates a real [Genkit] instance.
  CloudGemmaDatasource({required String apiKey})
    : _ai = Genkit(plugins: [googleAI(apiKey: apiKey)]);

  /// Test constructor — accepts an injected [Genkit] instance.
  CloudGemmaDatasource.withAi(Genkit ai) : _ai = ai;

  final Genkit _ai;

  ModelRef<GeminiOptions> get _model => googleAI.gemini(_kModel);

  // ─── 1. Scoped chat ────────────────────────────────────────────────────────

  /// Streams response tokens for a Baybayin-scoped conversation.
  ///
  /// [history] is the full message history (user + model turns).
  /// A hard-coded [systemInstruction] keeps Butty on topic unless
  /// the caller overrides it.
  @override
  Stream<String> generate(
    List<ChatMessage> history, {
    String? systemInstruction,
  }) {
    final StreamController<String> controller = StreamController<String>();
    final List<Message> messages = _buildMessages(
      history,
      systemInstruction: systemInstruction ?? _kChatSystemPrompt,
    );

    _ai
        .generate(
          model: _model,
          messages: messages,
          onChunk: (GenerateResponseChunk chunk) {
            final String token = chunk.content
                .whereType<TextPart>()
                .map((TextPart p) => p.text)
                .join();
            if (token.isNotEmpty && !controller.isClosed) {
              controller.add(token);
            }
          },
        )
        .then((_) => controller.close())
        .catchError((Object e, StackTrace s) {
          if (!controller.isClosed) {
            controller.addError(e, s);
            controller.close();
          }
        });

    return controller.stream;
  }

  // ─── 2. Image analysis ────────────────────────────────────────────────────

  /// Streams a description / translation of drawn or photographed
  /// Baybayin characters supplied as raw image bytes.
  ///
  /// [mimeType] defaults to `'image/png'`. Pass `'image/jpeg'` for photos.
  @override
  Stream<String> analyzeImage(
    Uint8List imageBytes, {
    String mimeType = 'image/png',
    String? prompt,
  }) {
    final StreamController<String> controller = StreamController<String>();
    final String base64Image = base64Encode(imageBytes);
    final String dataUrl = 'data:$mimeType;base64,$base64Image';

    final String instruction =
        prompt ??
        'Identify the Baybayin character(s) in this image. '
            'Give the romanized equivalent and a short explanation of each.';

    final List<Message> messages = <Message>[
      Message.from(
        role: Role.user,
        content: <Part>[
          MediaPart.from(
            media: Media.from(contentType: mimeType, url: dataUrl),
          ),
          TextPart.from(text: instruction),
        ],
      ),
    ];

    _ai
        .generate(
          model: _model,
          messages: messages,
          onChunk: (GenerateResponseChunk chunk) {
            final String token = chunk.content
                .whereType<TextPart>()
                .map((TextPart p) => p.text)
                .join();
            if (token.isNotEmpty && !controller.isClosed) {
              controller.add(token);
            }
          },
        )
        .then((_) => controller.close())
        .catchError((Object e, StackTrace s) {
          if (!controller.isClosed) {
            controller.addError(e, s);
            controller.close();
          }
        });

    return controller.stream;
  }

  // ─── 3. Challenge generation ──────────────────────────────────────────────

  /// Asks Gemini to produce one Baybayin challenge, returned as a typed
  /// [BaybayinChallenge].
  ///
  /// Optionally narrow the challenge to a subset of Baybayin [characters]
  /// (e.g. vowel kudlit only).
  @override
  Future<BaybayinChallenge> generateChallenge({
    List<String>? characters,
  }) async {
    final StringBuffer userPrompt = StringBuffer(
      'Generate one Baybayin learning challenge.',
    );
    if (characters != null && characters.isNotEmpty) {
      userPrompt.write(' Focus on these characters: ${characters.join(', ')}.');
    }

    final List<Message> messages = <Message>[
      Message.from(
        role: Role.system,
        content: <Part>[TextPart.from(text: _kChallengeSystemPrompt)],
      ),
      Message.from(
        role: Role.user,
        content: <Part>[TextPart.from(text: userPrompt.toString())],
      ),
    ];

    final StringBuffer raw = StringBuffer();
    final GenerateResponse response = await _ai.generate(
      model: _model,
      messages: messages,
      onChunk: (GenerateResponseChunk chunk) {
        final String token = chunk.content
            .whereType<TextPart>()
            .map((TextPart p) => p.text)
            .join();
        if (token.isNotEmpty) raw.write(token);
      },
    );

    // Prefer the complete response text; fall back to streamed buffer.
    final String json = response.text.isNotEmpty
        ? response.text
        : raw.toString();
    return _parseChallenge(json);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Converts domain [ChatMessage] list → Genkit [Message] list,
  /// prepending a system instruction message.
  List<Message> _buildMessages(
    List<ChatMessage> history, {
    required String systemInstruction,
  }) {
    final List<Message> result = <Message>[
      Message.from(
        role: Role.system,
        content: <Part>[TextPart.from(text: systemInstruction)],
      ),
    ];

    for (final ChatMessage msg in history) {
      result.add(
        Message.from(
          role: msg.isUser ? Role.user : Role.model,
          content: <Part>[TextPart.from(text: msg.text)],
        ),
      );
    }
    return result;
  }

  /// Parses raw JSON from the model into a [BaybayinChallenge].
  /// Falls back to a safe default if the JSON is malformed.
  BaybayinChallenge _parseChallenge(String raw) {
    try {
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return BaybayinChallenge(
        type: _parseChallengeType(json['type'] as String? ?? ''),
        prompt: json['prompt'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        targetGlyph: json['targetGlyph'] as String?,
        hint: json['hint'] as String?,
      );
    } catch (_) {
      return const BaybayinChallenge(
        type: ChallengeType.identifyCharacter,
        prompt: 'What romanized syllable does the character ᜀ represent?',
        answer: 'a',
        targetGlyph: 'ᜀ',
        hint: 'It is the first vowel in the Baybayin alphabet.',
      );
    }
  }

  ChallengeType _parseChallengeType(String raw) => switch (raw) {
    'writeCharacter' => ChallengeType.writeCharacter,
    'translateWord' => ChallengeType.translateWord,
    _ => ChallengeType.identifyCharacter,
  };

  @override
  Future<void> dispose() async {}
}
