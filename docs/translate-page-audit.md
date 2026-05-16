# Translate Page Audit

Date: 2026-05-04

## Scope

This audit covers the current `Translate` tab implementation in:

- [lib/features/home/presentation/screens/translate_screen.dart](../lib/features/home/presentation/screens/translate_screen.dart)
- [lib/features/home/presentation/widgets/translate/](../lib/features/home/presentation/widgets/translate/)
- [lib/core/utils/baybayify.dart](../lib/core/utils/baybayify.dart)

It does not cover:

- scanner OCR translation flow
- Butty chat
- backend translation history tables beyond whether the page uses them

## Current Product Reality

The current page is a transliteration + assisted-helper experience:
typed conversion is local, with optional AI explanation/check support.

It now includes:

- two modes (`Text`, `Sketchpad`)
- explicit online/offline model state in the UI
- functional output actions (`Copy`, `Share`, `Save` in current flow)
- AI-assisted feedback helpers (`Explain`, `Check Input`)

What the page does today:

- accepts typed text via a `TextField`
- toggles between `Filipino -> Baybayin` and `Baybayin -> Filipino`
- converts input immediately on each change
- renders Baybayin output using the `Baybayin Simple TAWBID` font
- shows output action pills for `Copy`, `Share`, and `Save`
- shows a mic button with visual toggle state only
- surfaces inline helper messages when punctuation, numbers, unsupported
  characters, or reverse-mode input expectations affect the result
- previews the cleaned text used by the converter when input cleanup changes
  the effective transliteration value
- shows encoded reverse-mode examples (`ka`, `ki`, `ku`, `k+`) as tappable
  chips that fill the input

What the page does not do today:

- no real speech-to-text
- no full AI sentence translation
- no true Baybayin Unicode reverse parse
- limited contextual explanation beyond helper feedback
- no speech-to-text pipeline

## Working Well

### 1. Basic page structure works

The screen is simple and stable:

- output area at the top
- direction toggle in the middle
- input strip at the bottom

Relevant files:

- [translate_screen.dart](../lib/features/home/presentation/screens/translate_screen.dart)
- [output_stage.dart](../lib/features/home/presentation/widgets/translate/output_stage.dart)
- [input_strip.dart](../lib/features/home/presentation/widgets/translate/input_strip.dart)

### 2. Instant local conversion works

The page updates output immediately whenever text changes.

- `baybayifyWord(text)` is used for `Filipino -> Baybayin`
- `baybayinToLatin(text)` is used for `Baybayin -> Filipino`

Relevant files:

- [translate_screen.dart](../lib/features/home/presentation/screens/translate_screen.dart#L25)
- [baybayify.dart](../lib/core/utils/baybayify.dart#L26)

### 3. Empty state is clear enough

The empty state communicates the expected input flow:

- user should type or speak
- output area stays visually quiet until input exists

Relevant file:

- [empty_output.dart](../lib/features/home/presentation/widgets/translate/empty_output.dart)

### 4. Baybayin output presentation is readable

The main output uses:

- dedicated Baybayin font
- large type size
- centered layout
- a second line for Latin text

Relevant file:

- [filled_output.dart](../lib/features/home/presentation/widgets/translate/filled_output.dart)

## Partially Working

### 1. Direction toggle works, but labels oversell the feature

The toggle says:

- `Filipino -> Baybayin`
- `Baybayin -> Filipino`

But the implementation is transliteration-oriented, not language-aware translation. It does not understand grammar, spelling variants, context, or phrase meaning.

Relevant file:

- [direction_toggle.dart](../lib/features/home/presentation/widgets/translate/direction_toggle.dart)

### 2. Reverse mode is technically present, but intentionally encoded

`baybayinToLatin()` does not consume actual Baybayin glyphs. It only parses an internal ASCII-like encoding made of:

- Latin consonants
- vowels
- `+`
- spaces

That means a user pasting real Baybayin Unicode characters will not get the intended reverse conversion. The UI now labels the reverse input as encoded Baybayin and shows inline helper copy when pasted glyphs are detected.

Relevant file:

- [baybayify.dart](../lib/core/utils/baybayify.dart#L77)

### 3. Input sanitization is consistent, with visible helper feedback

`_normalize()` strips non-alpha content:

- punctuation removed
- numbers removed
- symbols removed
- unsupported characters removed by the converter

This keeps the algorithm simple. Current UI helper messages now tell users when punctuation, numbers, unsupported characters, or encoded reverse-mode expectations affect the result.
When cleanup changes the effective input, the input area also previews the exact
cleaned text used by the converter.

Relevant file:

- [baybayify.dart](../lib/core/utils/baybayify.dart#L13)

### 4. Mic button is interactive visually only

The mic button changes appearance and flips `_listening`, but it does not start speech recognition or produce text.

Relevant files:

- [translate_screen.dart](../lib/features/home/presentation/screens/translate_screen.dart#L19)
- [mic_button.dart](../lib/features/home/presentation/widgets/translate/mic_button.dart)

## Not Working Or Missing

### 1. Translation save/bookmark flow is partial

Copy, share, and save are wired to active output state, and the page interacts
with translation history state. However, bookmark/cloud sync behavior is not fully
closed in every edge-case path.

Relevant files:

- [output_actions.dart](../lib/features/home/presentation/widgets/translate/output_actions.dart)
- [translation_history_provider.dart](../lib/features/home/presentation/providers/translation_history_provider.dart)

### 2. Output explanation depth is still limited

The page has helper actions (`Explain`, `Check Input`) but does not consistently
surface complete transliteration rationale and spelling guidance.

Relevant files:

- [translate_text_controller.dart](../lib/features/home/presentation/providers/translate_text_controller.dart)
- [translate_feedback_card.dart](../lib/features/home/presentation/widgets/translate/translate_feedback_card.dart)

### 3. User feedback is improved but still algorithm-limited

Visible helper messages now cover:

- punctuation removed
- numbers removed
- unsupported Baybayin glyph input
- mixed-script input

The remaining limitation is that the underlying conversion still drops unsupported input instead of preserving or transforming it.

### 4. No actual Baybayin Unicode parsing in reverse mode

This is one of the biggest product gaps. The reverse path is named `Baybayin -> Filipino`, but the utility currently parses only the internal Latin-plus-`+` representation.

This will confuse real users unless the page either:

- accepts actual Baybayin glyphs, or
- clearly states that reverse mode expects encoded transliteration text

### 5. Tests are partial

There are focused widget and density checks, but there is still room for deeper
coverage around utility-level conversion and edge-case translation behavior.

- `translate_screen.dart` integration scenarios
- `baybayify.dart` edge-case matrices
- unsupported/invalid-input behavior
- history/bookmark sync edge cases

## UX Problems

### 1. The page promise is larger than the implementation

The product language says `Translate`, but the feature is closer to:

- transliterate text
- preview Baybayin rendering

That mismatch will create user disappointment.

### 2. The page is not yet interactive enough

Current interaction depth is low:

- type
- toggle
- see output

There are no assistive states like:

- examples
- suggestions
- teaching moments
- explanations
- corrections
- actions after conversion

### 3. Reverse mode lacks trust

Because there is no explicit explanation of input format and no validation hints, users cannot reliably tell whether reverse conversion is working correctly.

### 4. Placeholder actions reduce perceived completeness

Copy/share/save actions now execute when valid output exists; failure and empty-state
messaging is still minimal, so the controls can still feel unfinished in edge states.

## Technical Constraints In Current Logic

### 1. `baybayifyWord()` is rule-based and narrow

It currently models:

- consonant + `a`
- consonant + other vowel
- bare consonant -> `+`
- standalone vowel
- spaces

It does not model richer language or orthography behavior beyond that.

### 2. Output depends on font rendering convention

The transliteration result is an encoded string intended for the Baybayin font, not necessarily a true Unicode Baybayin text pipeline.

That is fine for visual rendering, but it makes interoperability weaker for:

- copy/share
- search
- reverse parsing
- persistence

### 3. Page state is provider-coordinated

`TranslateScreen` is a `ConsumerWidget` that delegates behavior to providers:

- translation text state and mode are in dedicated providers
- history state is shared through `translationHistoryNotifierProvider`
- async actions and offline readiness are exposed through provider state

Gaps remain around how much of the AI/history behavior is validated under
failure and empty states.

## Recommended Next Improvements

### Priority 1: Fix broken expectations

1. Clarify feature positioning (`Translate` vs transliteration helper).
2. Add visible helper text for reverse-mode input expectations.

### Priority 2: Make it trustworthy

1. Expand validation beyond helper copy into stronger input previews.
2. Show a before/after cleanup preview when input was normalized or stripped.
3. Add tests for `baybayifyWord()` and `baybayinToLatin()`.
4. Define whether reverse mode should support actual Baybayin Unicode.

### Priority 3: Make it useful

1. Add recent translations.
2. Add bookmark/save.
3. Add quick examples users can tap.
4. Add pronunciation or syllable breakdown.
5. Add explanation chips like `final consonant`, `implied a`, `vowel mark`.

### Priority 4: Make it interactive

1. Add speech-to-text if the mic remains visible.
2. Add paste detection and auto-cleanup messaging.
3. Add educational overlays for how the output was formed.
4. Add a bridge to Butty for explanation, not just raw conversion.

## Suggested Future Feature Shape

If you want the page to feel complete, the best product split is:

### Option A: Keep this as a transliterator

Position it as:

- `Baybayin Converter`
- fast, offline, instant

Then improve:

- accuracy
- copy/share/save
- breakdown/explanation
- Unicode support

### Option B: Make it a real translate experience

Keep the current instant converter, but add:

- AI explanation
- context-aware translation notes
- OCR handoff from scanner
- phrase meaning help
- history and saved outputs

## Audit Summary

### Working

- typed input
- instant local conversion
- direction toggle
- Baybayin font rendering
- clear empty state

### Partial

- reverse conversion
- mic interaction
- feature naming
- input normalization

### Broken or missing

- full sentence-level translation parity
- richer translation explanation
- real speech input
- full Baybayin Unicode reverse support
- complete edge-case test coverage
