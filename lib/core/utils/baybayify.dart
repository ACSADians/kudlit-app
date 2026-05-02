// Baybayin transliteration utilities.
//
// Ported from the TypeScript implementation in the design reference.
// All functions operate on plain strings — no Flutter dependencies.

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

/// Builds every romanised permutation of an ordered list of detected
/// Baybayin character labels.
///
/// Some characters are ambiguous because the kudlit diacritic that selects
/// the vowel (`i`/`e` vs `o`/`u`) is missing or unclear in the source image.
/// The detector emits these as a pair joined with `_`, e.g. `bi_be` means
/// "either `bi` or `be`".
///
/// Given `['pa', 'bi_be', 'da_do']` this returns
/// `['pabida', 'pabido', 'pabeda', 'pabedo']`.
///
/// Empty / whitespace-only segments are dropped. The product is capped at
/// [maxResults] (default 64) so the cycler UI stays usable even when many
/// ambiguous glyphs appear in one phrase.
List<String> permuteBaybayin(List<String> tokens, {int maxResults = 64}) {
  final List<List<String>> options = <List<String>>[];
  for (final String t in tokens) {
    final List<String> opts = t
        .split('_')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    if (opts.isNotEmpty) options.add(opts);
  }
  if (options.isEmpty) return const <String>[];

  List<String> acc = <String>[''];
  for (final List<String> opts in options) {
    final List<String> next = <String>[];
    for (final String prefix in acc) {
      for (final String o in opts) {
        next.add(prefix + o);
        if (next.length >= maxResults) return next;
      }
    }
    acc = next;
  }
  return acc;
}
