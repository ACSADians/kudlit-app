/// Baybayin transliteration utilities.
///
/// Ported from the TypeScript implementation in the design reference.
/// All functions operate on plain strings — no Flutter dependencies.

const List<String> _vowels = <String>['a', 'e', 'i', 'o', 'u'];
final RegExp _consonantRe = RegExp(r'^[bcdfghjklmnpqrstvwxyz]$');

bool _isVowel(String c) => _vowels.contains(c);
bool _isConsonant(String c) => _consonantRe.hasMatch(c);

/// Normalise text: NFC, lowercase, strip non-alpha.
String _normalize(String text) {
  return text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '');
}

/// Convert a Latin string to a Baybayin-encoded string where:
/// - bare consonant (final / before another consonant) → `c+`
/// - consonant + 'a' (implied vowel) → `c`
/// - consonant + other vowel → `cv`
/// - standalone vowel → `v`
/// - spaces are preserved
///
/// The resulting string is intended to be rendered with the
/// *Baybayin Simple TAWBID* font.
String baybayifyWord(String input) {
  final StringBuffer output = StringBuffer();
  final String normalized = _normalize(input);
  final List<String> chars = normalized.split('');

  int i = 0;
  while (i < chars.length) {
    final String c = chars[i];
    final String? next = i + 1 < chars.length ? chars[i + 1] : null;

    if (c == ' ') {
      output.write(' ');
      i++;
      continue;
    }

    if (_isConsonant(c) && next == 'a') {
      output.write(c);
      i += 2;
      continue;
    }

    if (_isConsonant(c) && next != null && _isVowel(next)) {
      output.write('$c$next');
      i += 2;
      continue;
    }

    if (_isConsonant(c)) {
      output.write('$c+');
      i++;
      continue;
    }

    if (_isVowel(c)) {
      output.write(c);
      i++;
      continue;
    }

    // skip unsupported characters
    i++;
  }

  return output.toString();
}

/// Reverse: Baybayin-encoded string → Latin.
/// `c+` → final consonant (no vowel appended).
/// bare `c` → consonant + implied 'a'.
/// `cv` → consonant + vowel.
String baybayinToLatin(String input) {
  final StringBuffer output = StringBuffer();
  final String normalized = input.toLowerCase().replaceAll(
    RegExp(r'[^a-z+\s]'),
    '',
  );
  final List<String> chars = normalized.split('');

  int i = 0;
  while (i < chars.length) {
    final String c = chars[i];
    final String? next = i + 1 < chars.length ? chars[i + 1] : null;

    if (c == ' ') {
      output.write(' ');
      i++;
      continue;
    }

    if (_isConsonant(c) && next == '+') {
      output.write(c);
      i += 2;
      continue;
    }

    if (_isConsonant(c) && next != null && _isVowel(next)) {
      output.write('$c$next');
      i += 2;
      continue;
    }

    if (_isConsonant(c)) {
      output.write('${c}a');
      i++;
      continue;
    }

    if (_isVowel(c)) {
      output.write(c);
      i++;
      continue;
    }

    i++;
  }

  return output.toString();
}
