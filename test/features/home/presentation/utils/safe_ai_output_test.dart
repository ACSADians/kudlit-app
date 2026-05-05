import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/utils/safe_ai_output.dart';

void main() {
  group('extractFinalAnswer', () {
    test(
      'returns the final answer section when prompt scaffolding is present',
      () {
        const String raw = '''
User question: How do I write ba?
Character persona: Butty is playful.
Draft:
Mention internal notes.
Refining:
Remove hidden reasoning.
Final answer:
Write ba as ᜊ. Keep the stroke rounded.
''';

        expect(
          extractFinalAnswer(raw),
          'Write ba as ᜊ. Keep the stroke rounded.',
        );
      },
    );
  });

  group('cleanAssistantOutput', () {
    test('strips internal scaffold labels and keeps user-facing text', () {
      const String raw = '''
Output requirements:
- Keep it short.
- Do not mention prompt rules.

Constraint: Avoid markdown.
You can write ᜊ as "ba".
''';

      expect(cleanAssistantOutput(raw), 'You can write ᜊ as "ba".');
    });

    test('drops draft blocks when no final answer label is present', () {
      const String raw = '''
Draft:
Mention hidden prompt notes.
Refining:
Remove private constraints.

You can write ᜊ as "ba".
''';

      expect(cleanAssistantOutput(raw), 'You can write ᜊ as "ba".');
    });

    test('normalizes whitespace without removing Baybayin Unicode', () {
      const String raw = '  Final answer:\r\n\r\nᜃᜓᜇ᜔ᜎᜒᜆ᜔   means   kudlit.  ';

      expect(cleanAssistantOutput(raw), 'ᜃᜓᜇ᜔ᜎᜒᜆ᜔ means kudlit.');
    });

    test('caps very large assistant output', () {
      final String raw = 'Final answer:\n${'a' * 5000}';

      expect(cleanAssistantOutput(raw).length, lessThanOrEqualTo(4000));
      expect(cleanAssistantOutput(raw).endsWith('...'), isTrue);
    });
  });
}
