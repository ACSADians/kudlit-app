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

    test('strips markdown bullet scaffold labels from chat responses', () {
      const String raw = '''
* Question: "What is a kudlit?"
* Character: Butty (spirited, passionate).
* Subject: Baybayin script.

* A *kudlit* is a diacritic mark used in Baybayin.
* It changes the vowel sound of a consonant.
''';

      expect(
        cleanAssistantOutput(raw),
        '* A *kudlit* is a diacritic mark used in Baybayin.\n'
        '* It changes the vowel sound of a consonant.',
      );
    });

    test('strips alternate live Butty prompt labels', () {
      const String raw = '''
* User asks: "What is a kudlit?"
* Target persona: Butty (spirited, passionate).

* A *kudlit* is a diacritical mark used in Baybayin.
''';

      expect(
        cleanAssistantOutput(raw),
        '* A *kudlit* is a diacritical mark used in Baybayin.',
      );
    });

    test('truncates late markdown draft labels after visible answer text', () {
      const String raw = '''
* Definition: A small mark added to a Baybayin character.
* Mechanics: A dot above changes the vowel sound.

* **Draft 1:** A kudlit is a small mark you put on a character.
''';

      expect(
        cleanAssistantOutput(raw),
        '* Definition: A small mark added to a Baybayin character.\n'
        '* Mechanics: A dot above changes the vowel sound.',
      );
    });

    test('strips live goal and persona labels from Butty responses', () {
      const String raw = '''
* Goal: Explain what a kudlit is using the Butty persona.

* What is it? A small mark placed above or below a Baybayin character.
* Function: It changes the vowel sound of a consonant.

* *Spirited/Passionate:* "Ay nako, that's a foundational question!"
''';

      expect(
        cleanAssistantOutput(raw),
        '* What is it? A small mark placed above or below a Baybayin character.\n'
        '* Function: It changes the vowel sound of a consonant.',
      );
    });

    test('truncates late option labels after visible answer text', () {
      const String raw = '''
* Definition: A small mark used in Baybayin.
* Function: It changes the vowel sound.

* **Option 1 (Generic):** A kudlit is a mark added to a character.
''';

      expect(
        cleanAssistantOutput(raw),
        '* Definition: A small mark used in Baybayin.\n'
        '* Function: It changes the vowel sound.',
      );
    });

    test('strips leading question echoes and persona descriptors', () {
      const String raw = '''
"What is a kudlit?"
Butty (spirited, passionate, uses Tagalog/Filipino, punchy).

* A *kudlit* is a small mark used in Baybayin.
* A dot above changes the vowel sound.
''';

      expect(
        cleanAssistantOutput(raw),
        '* A *kudlit* is a small mark used in Baybayin.\n'
        '* A dot above changes the vowel sound.',
      );
    });

    test('strips topic labels and truncates late idea labels', () {
      const String raw = '''
* Topic: Baybayin linguistics (Kudlit).

* A kudlit is a small mark used in Baybayin.
* Dot/mark above changes the vowel sound.

* **Idea 1:** A kudlit is like a magic wand for vowels.
''';

      expect(
        cleanAssistantOutput(raw),
        '* A kudlit is a small mark used in Baybayin.\n'
        '* Dot/mark above changes the vowel sound.',
      );
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
