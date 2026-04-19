# Kudlit

A vision-based [Baybayin](https://en.wikipedia.org/wiki/Baybayin) translator and learning app. Point your camera at handwritten or printed Baybayin script — Kudlit detects characters on-device with a YOLO TFLite model and translates them to romanized/Filipino text via Gemma 4.

Targets Android, iOS, and Web. Mobile-first.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod (`riverpod_annotation` code gen) |
| Character detection | YOLO → TFLite (`ultralytics_yolo`) |
| Language understanding | Gemma 4 |
| Error handling | `Either<Failure, T>` (fpdart/dartz) |

---

## Prerequisites

- Flutter SDK `^3.11.5` — install via [flutter.dev](https://flutter.dev/docs/get-started/install)
- Dart SDK (bundled with Flutter)
- Android Studio or Xcode for device targets
- Chrome for web development

Verify your setup:

```bash
flutter doctor
```

---

## Getting Started

```bash
git clone <repo-url>
cd kudlit_ph
flutter pub get
flutter run -d chrome   # web (primary dev target)
```

For device targets:

```bash
flutter run -d android
flutter run -d ios
```

---

## Commands

```bash
# Install / update dependencies
flutter pub get

# Run (web — primary design target)
flutter run -d chrome

# Run on connected Android device
flutter run -d android

# Build
flutter build web
flutter build apk --release

# Lint
flutter analyze

# Test
flutter test                                          # all tests
flutter test test/path/to/file_test.dart             # single file
flutter test --name "should return translation"      # by name pattern

# Format
dart format lib/ test/
```

---

## Architecture

Feature-first Clean Architecture. Features are the top-level unit; inside each feature, layers follow Clean Architecture with a strict inward dependency rule.

```
lib/
├── main.dart
├── app/                        # App-wide setup: routing, theming, ProviderScope
├── core/                       # Shared utilities, base classes, errors
│   ├── error/                  # Failure types, exceptions
│   ├── usecases/               # Base UseCase abstract class
│   └── utils/
└── features/
    └── <feature_name>/
        ├── domain/             # Pure Dart — entities, repository interfaces, use cases
        │   ├── entities/
        │   ├── repositories/   # Abstract interfaces only
        │   └── usecases/
        ├── data/               # Implementations — repos, data sources, models
        │   ├── datasources/    # Local (TFLite, Hive) and remote (Gemma API)
        │   ├── models/         # DTOs extending domain entities
        │   └── repositories/   # Concrete implementations
        └── presentation/       # Flutter — widgets, screens, Riverpod providers
            ├── providers/
            ├── screens/
            └── widgets/
```

**Dependency rule:** `presentation` → `domain` ← `data`. The `domain` layer is pure Dart — zero Flutter dependencies. Use cases depend on repository interfaces, never concrete implementations.

### Planned Features

| Feature | Description |
|---|---|
| `scanner` | Camera feed → YOLO TFLite inference → Baybayin character detection |
| `translator` | Detected glyphs → romanized/Filipino text via Gemma 4 |
| `learn` | Interactive lessons and character reference |

---

## State Management

All providers use `@riverpod` code generation.

- `AsyncNotifierProvider` — async state (e.g., inference results, translations)
- `NotifierProvider` — sync state
- Providers live in `presentation/providers/` within their feature
- Repository and data source instances are exposed via providers in `data/` or `core/`

---

## Platform Notes

- **Web** is the primary target during UI development — test layout in Chrome first
- Camera and TFLite are unavailable on web; use `kIsWeb` guards and provide fallback UI (e.g., image upload instead of live camera)
- ML models are bundled as assets (`flutter.assets` in `pubspec.yaml`)

---

## Coding Conventions

### Types and Variables

```dart
// Always explicit types — no var
final String label = 'ᜊ';
late final BaybayinRepository _repository;

// dynamic only at interop boundaries (raw JSON before casting)
final dynamic raw = json.decode(response.body);
final TranslationModel model = TranslationModel.fromJson(raw as Map<String, dynamic>);
```

### Strings

Single quotes everywhere.

### Widgets

- `build()` must not exceed 40 lines — extract if it does
- Any subtree with 3+ nesting levels → extract into its own widget class in its own file
- No private builder methods (`_buildSomething()`) — extract a real widget class
- Prefer `const` constructors; prefer `StatelessWidget`; reach for Riverpod before `StatefulWidget`
- Widgets are display only — no business logic or derived state in `build()`

### Error Handling

Domain use cases return `Either<Failure, T>`. Define typed `Failure` subclasses in `core/error/`. Presentation maps failures to user-facing messages.

### Naming

| Entity | Convention |
|---|---|
| Files | `snake_case.dart` |
| Classes / enums | `PascalCase` |
| Variables / functions | `camelCase` |
| Private members | `_camelCase` |
| Constants | `camelCase` (not `SCREAMING_SNAKE`) |

### Imports

Order: `dart:` → `flutter:` → packages → local; blank line between groups. Use relative imports within the same feature; `package:kudlit_ph/...` across features.
