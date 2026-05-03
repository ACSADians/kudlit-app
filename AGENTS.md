# Kudlit — AI Agent Instructions

**Primary reference:** [CLAUDE.md](CLAUDE.md) — full coding standard, architecture guide, and commit rules.

## Quick Commands

```bash
flutter pub get          # Install/update deps
flutter run -d chrome    # Primary dev target
flutter analyze          # Lint — must pass before committing
flutter test             # All tests
dart format lib/ test/   # Format
```

## Project Layout

```
lib/
├── app/           # KudlitApp, go_router setup, AppConstants
├── core/          # Failures, UseCase base, SupabaseConfig, design system
└── features/
    ├── auth/      # Supabase auth — email, phone OTP, forgot/reset
    ├── home/      # All tabs: Scan, Translate, Learn, ButtyChatScreen, Settings
    └── scanner/   # YOLO TFLite pipeline — BaybayinDetection, overlays
```

Feature structure: `domain/` (pure Dart) → `data/` (implementations) → `presentation/` (widgets + providers).

## Known Gotchas

**`build_runner` is broken** (exit 69 — Xcode license issue on this machine). Hand-write `.g.dart` files instead. Notifier pattern:
```dart
// @riverpod class FooNotifier → AutoDisposeAsyncNotifier
typedef _$FooNotifier = AutoDisposeAsyncNotifier<FooState>;

// @Riverpod(keepAlive: true) class BarNotifier → AsyncNotifier
typedef _$BarNotifier = AsyncNotifier<BarState>;
```

**Domain `@immutable`**: Use `package:meta/meta.dart` — NOT `package:flutter/foundation.dart`. Domain layer must have zero Flutter deps.

**YOLO / Scanner**: `YOLOResult.className` is non-nullable; `normalizedBox` is a `Rect` in 0–1 coords. Model path `'yolo26n'` is a placeholder — real Baybayin TFLite not yet exported. Web uses `kIsWeb` guards throughout and shows a fallback UI.

**Supabase config**: Credentials come from `.env` (via `flutter_dotenv`) loaded in `core/config/supabase_config.dart`. Never hard-code keys.

**Domain returns `Either<Failure, T>`** (fpdart). Presentation maps `Left(Failure)` to user-facing messages.

## Skills

Load before working in these domains:
- `skills/flutter-frontend/SKILL.md` — Flutter widget patterns, design system
- `skills/supabase/SKILL.md` — Supabase integration patterns
- `skills/supabase-postgres-best-practices/SKILL.md` — DB schema / query optimisation
