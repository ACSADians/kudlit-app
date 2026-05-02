import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit/src/ai/generate.dart' show GenerateResponse;

import 'package:kudlit_ph/features/translator/data/datasources/cloud_gemma_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/baybayin_challenge.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

// ─── Fake Genkit ─────────────────────────────────────────────────────────────

/// A test double for [Genkit] that never touches the network.
///
/// Configure [chunksToEmit] before calling [generate] — each string becomes
/// a separate chunk callback. [responseText] is what `.text` on the returned
/// [GenerateResponse] will equal.
class FakeGenkit extends Fake implements Genkit {
  FakeGenkit({
    this.chunksToEmit = const <String>[],
    this.responseText = '',
    this.throwOnGenerate,
  });

  final List<String> chunksToEmit;
  final String responseText;
  final Object? throwOnGenerate;

  /// The message list from the last [generate] call.
  List<Message>? capturedMessages;

  @override
  Future<GenerateResponse<Object?>> generate<C>({
    String? prompt,
    List<Message>? messages,
    required ModelRef<C> model,
    C? config,
    List<String>? tools,
    String? toolChoice,
    bool? returnToolRequests,
    int? maxTurns,
    SchemanticType? outputSchema,
    String? outputFormat,
    bool? outputConstrained,
    String? outputInstructions,
    bool? outputNoInstructions,
    String? outputContentType,
    Map<String, dynamic>? context,
    StreamingCallback<GenerateResponseChunk>? onChunk,
  }) async {
    if (throwOnGenerate != null) throw throwOnGenerate!;

    capturedMessages = messages;

    for (final String text in chunksToEmit) {
      if (onChunk != null) {
        final ModelResponseChunk rawChunk = ModelResponseChunk.from(
          content: <Part>[TextPart.from(text: text)],
        );
        onChunk(GenerateResponseChunk<Object?>(rawChunk));
      }
    }

    final ModelResponse rawResponse = ModelResponse.from(
      message: Message.from(
        role: Role.model,
        content: <Part>[TextPart.from(text: responseText)],
      ),
      finishReason: FinishReason.stop,
    );
    return GenerateResponse<Object?>(rawResponse);
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

ChatMessage _userMsg(String text) =>
    ChatMessage(text: text, isUser: true, timestamp: DateTime(2026));

ChatMessage _modelMsg(String text) =>
    ChatMessage(text: text, isUser: false, timestamp: DateTime(2026));

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── generate (scoped chat) ─────────────────────────────────────────────────

  group('CloudGemmaDatasource.generate', () {
    test('streams tokens from each chunk callback', () async {
      final FakeGenkit fakeAi = FakeGenkit(
        chunksToEmit: <String>['Ba', 'y', 'bayin'],
        responseText: 'Baybayin',
      );
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(fakeAi);

      final List<String> tokens = await ds.generate(<ChatMessage>[
        _userMsg('What is Baybayin?'),
      ]).toList();

      expect(tokens, <String>['Ba', 'y', 'bayin']);
    });

    test('closes stream without error when model succeeds', () async {
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(
        FakeGenkit(chunksToEmit: <String>['ok']),
      );

      await expectLater(
        ds.generate(<ChatMessage>[_userMsg('hi')]),
        emitsInOrder(<dynamic>['ok', emitsDone]),
      );
    });

    test('adds error to stream when model throws', () async {
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(
        FakeGenkit(throwOnGenerate: Exception('network error')),
      );

      await expectLater(
        ds.generate(<ChatMessage>[_userMsg('hi')]),
        emitsError(isA<Exception>()),
      );
    });

    test('prepends system message before history', () async {
      final FakeGenkit fakeAi = FakeGenkit(chunksToEmit: <String>['ok']);
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(fakeAi);

      await ds.generate(<ChatMessage>[
        _userMsg('hello'),
        _modelMsg('hi'),
      ]).toList();

      final List<Message> msgs = fakeAi.capturedMessages!;
      // First message is system instruction.
      expect(msgs.first.role, equals(Role.system));
      // Then the two history messages.
      expect(msgs[1].role, equals(Role.user));
      expect(msgs[2].role, equals(Role.model));
    });

    test('uses custom systemInstruction when provided', () async {
      final FakeGenkit fakeAi = FakeGenkit(chunksToEmit: <String>['ok']);
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(fakeAi);
      const String customPrompt = 'Custom system prompt';

      await ds.generate(<ChatMessage>[
        _userMsg('hi'),
      ], systemInstruction: customPrompt).toList();

      final Message systemMsg = fakeAi.capturedMessages!.first;
      final String systemText = (systemMsg.content.first as TextPart).text;
      expect(systemText, customPrompt);
    });
  });

  // ── generateChallenge ──────────────────────────────────────────────────────

  group('CloudGemmaDatasource.generateChallenge', () {
    test('parses a valid identifyCharacter JSON response', () async {
      const String json =
          '{'
          '"type":"identifyCharacter",'
          '"prompt":"What syllable is ᜁ?",'
          '"answer":"i",'
          '"targetGlyph":"ᜁ",'
          '"hint":"It is the second vowel."'
          '}';

      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(
        FakeGenkit(responseText: json),
      );

      final BaybayinChallenge challenge = await ds.generateChallenge();

      expect(challenge.type, ChallengeType.identifyCharacter);
      expect(challenge.prompt, 'What syllable is ᜁ?');
      expect(challenge.answer, 'i');
      expect(challenge.targetGlyph, 'ᜁ');
      expect(challenge.hint, 'It is the second vowel.');
    });

    test('parses writeCharacter type correctly', () async {
      const String json =
          '{'
          '"type":"writeCharacter",'
          '"prompt":"Draw the character for ka.",'
          '"answer":"ᜃ",'
          '"targetGlyph":null,'
          '"hint":null'
          '}';

      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(
        FakeGenkit(responseText: json),
      );

      final BaybayinChallenge challenge = await ds.generateChallenge();

      expect(challenge.type, ChallengeType.writeCharacter);
      expect(challenge.answer, 'ᜃ');
      expect(challenge.targetGlyph, isNull);
      expect(challenge.hint, isNull);
    });

    test('parses translateWord type correctly', () async {
      const String json =
          '{'
          '"type":"translateWord",'
          '"prompt":"Translate ᜀᜃᜎ into Filipino.",'
          '"answer":"akal",'
          '"targetGlyph":null,'
          '"hint":null'
          '}';

      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(
        FakeGenkit(responseText: json),
      );

      final BaybayinChallenge challenge = await ds.generateChallenge();
      expect(challenge.type, ChallengeType.translateWord);
    });

    test('falls back to default challenge when JSON is malformed', () async {
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(
        FakeGenkit(responseText: 'this is not json {{{'),
      );

      final BaybayinChallenge challenge = await ds.generateChallenge();

      expect(challenge.type, ChallengeType.identifyCharacter);
      expect(challenge.answer, 'a');
      expect(challenge.targetGlyph, 'ᜀ');
    });

    test('falls back when response is empty', () async {
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(
        FakeGenkit(responseText: ''),
      );

      final BaybayinChallenge challenge = await ds.generateChallenge();
      expect(challenge.type, ChallengeType.identifyCharacter);
    });

    test('includes character list in user message when provided', () async {
      final FakeGenkit fakeAi = FakeGenkit(
        responseText:
            '{"type":"identifyCharacter","prompt":"?","answer":"ka",'
            '"targetGlyph":null,"hint":null}',
      );
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(fakeAi);

      await ds.generateChallenge(characters: <String>['ᜃ', 'ᜄ']);

      final Message userMsg = fakeAi.capturedMessages!.last;
      final String userText = (userMsg.content.first as TextPart).text;
      expect(userText, contains('ᜃ'));
      expect(userText, contains('ᜄ'));
    });

    test('omits character focus when characters list is empty', () async {
      final FakeGenkit fakeAi = FakeGenkit(
        responseText:
            '{"type":"identifyCharacter","prompt":"?","answer":"a",'
            '"targetGlyph":null,"hint":null}',
      );
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(fakeAi);

      await ds.generateChallenge(characters: <String>[]);

      final Message userMsg = fakeAi.capturedMessages!.last;
      final String userText = (userMsg.content.first as TextPart).text;
      expect(userText, isNot(contains('Focus on these characters')));
    });

    test('prefers response.text over streamed buffer', () async {
      // Chunks emit partial text, but responseText is the authoritative value.
      final FakeGenkit fakeAi = FakeGenkit(
        chunksToEmit: <String>['partial'],
        responseText:
            '{"type":"translateWord","prompt":"Translate.",'
            '"answer":"baybayin","targetGlyph":null,"hint":null}',
      );
      final CloudGemmaDatasource ds = CloudGemmaDatasource.withAi(fakeAi);

      final BaybayinChallenge challenge = await ds.generateChallenge();
      expect(challenge.type, ChallengeType.translateWord);
      expect(challenge.answer, 'baybayin');
    });
  });
}
