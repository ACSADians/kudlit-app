# Kudlit

Kudlit is a vision-based Baybayin translator and learning app built in Flutter. This repository now treats the bundled [`Kudlit Design System`](<Kudlit Design System/README.md>) as the visual source of truth and mirrors it through a Flutter theme, shared assets, and branded placeholder screens.

## Current Setup

- App shell and auth flow use a shared Flutter design-system layer under `lib/core/design_system/`.
- The bundled Baybayin display font and reference assets are copied into `assets/fonts/` and `assets/brand/` for normal Flutter usage.
- The home shell, scanner, translator, and learning surfaces are active Flutter feature slices using the shared Kudlit visual system.
- The original design-system source remains in [`Kudlit Design System/`](<Kudlit Design System/>) for previews, reference JSX, and asset provenance.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod (`riverpod_annotation`) |
| Routing | `go_router` |
| Backend auth | Supabase |
| Character detection | YOLO → TFLite (`ultralytics_yolo`) |
| Language understanding | Gemma 4 |
| Error handling | `Either<Failure, T>` via `fpdart` |

## Getting Started

```bash
flutter doctor
flutter pub get
flutter run -d chrome
```

Useful commands:

```bash
flutter analyze
flutter test
flutter build web
dart format lib/ test/
```

## Deployment

The repository includes two web deployment paths:

- `build.sh` for Cloudflare Pages. Configure the build command as `bash build.sh` and the output directory as `build/web`.
- `.github/workflows/deploy-pages.yml` for GitHub Pages. It runs on pushes to `main` and can also be started manually from GitHub Actions.

Both deployment paths expect these repository or platform secrets:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `GEMINI_API_KEY`
- `HUGGINGFACE_TOKEN` is optional.

After a deployment is live, smoke-check the main web routes:

```bash
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/prod-smoke.ps1 -BaseUrl "https://acsadians.github.io/kudlit-app"
```

### Translate Header UI verification

From `kudlit-app/`, run:

```bash
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/verify-translate-header-ui.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/verify-translate-header-ui.ps1 -Tabs "scan,translate,learn,butty" -Widths "768,1024,1366,1920" -SkipTests
```

The script:

- runs `test/features/home/presentation/widgets/translate_density_test.dart` unless `-SkipTests` is set,
- captures screenshots under `test-results/ui-verify/` with names like `translate-header-<tab>-<width>.png`,
- starts a local static preview only if the target URL is not already reachable.

### Translate header UI hardening

```bash
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/verify-translate-header-ui.ps1
```

Capture-only pass (skip `translate_density_test.dart`):

```bash
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/verify-translate-header-ui.ps1 -SkipTests
```

Custom capture width set:

```bash
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/verify-translate-header-ui.ps1 -Widths "768,1024,1366,1920,1536"
```

## Folder Structure

```text
lib/
├── app/                        App bootstrapping, router, app constants
├── core/
│   ├── config/                 Environment and Supabase setup
│   ├── design_system/          Flutter theme, color tokens, shared UI shells
│   ├── error/                  Shared failures and exceptions
│   └── usecases/               Base use case abstractions
├── features/
│   └── auth/                   Current implemented feature slice
└── main.dart

assets/
├── brand/                      Copied Kudlit illustrations and reference art
└── fonts/                      Baybayin display font used in the UI

Kudlit Design System/           Reference docs, CSS tokens, previews, JSX UI kit
```

## Architecture

The app follows feature-first clean architecture:

- `presentation -> domain <- data`
- `domain` stays pure Dart
- repositories are defined in `domain` and implemented in `data`
- app-wide visual decisions live in `core/design_system/`, not inside feature widgets

Current feature intent:

- `auth`: implemented and now wrapped in the branded Kudlit auth shell
- `scanner`: native live YOLO scanning plus web webcam preview with capture-based TFLite detection from the active vision model URL
- `translator`: planned Baybayin transliteration and Gemma-assisted interpretation
- `learn`: planned lessons, quizzes, and reference content

## Design System Notes

- Token source: [`Kudlit Design System/colors_and_type.css`](<Kudlit Design System/colors_and_type.css>)
- Brand guidance: [`Kudlit Design System/README.md`](<Kudlit Design System/README.md>)
- Local repo workflow notes: [SKILL.md](SKILL.md)
- Gemini CLI entrypoint: [GEMINI.md](GEMINI.md)
- Repo-local Gemini frontend skill: [skills/flutter-frontend/SKILL.md](skills/flutter-frontend/SKILL.md)

Important limitation:

- The design docs specify Geist for the UI font, but this repository currently only bundles the Baybayin display font. The shared Flutter theme already applies the Kudlit color, radius, and spacing language, and Baybayin headings use the bundled font directly.

## Gemini CLI Setup

Install `obra/superpowers` in Gemini CLI:

```bash
gemini extensions install https://github.com/obra/superpowers
```

This repository also includes a local Gemini extension:

- [gemini-extension.json](gemini-extension.json)
- [GEMINI.md](GEMINI.md)
- [skills/flutter-frontend/SKILL.md](skills/flutter-frontend/SKILL.md)

Recommended usage:

- Use `obra/superpowers` for process skills such as brainstorming, planning, debugging, TDD, and review
- Use the local `flutter-frontend` skill for Kudlit-specific Flutter UI and design-system implementation

## Working Rules

- Keep UI mobile-first even when using Chrome as the design target.
- Do not bypass `core/design_system/` for shared colors, type, surfaces, or brand assets.
- Keep widgets focused on display; move business logic into Riverpod notifiers and use cases.
- Prefer relative imports within a feature and `package:kudlit_ph/...` across features.
- Use single quotes and explicit types.

For repo-level coding rules and architecture constraints, read [CLAUDE.md](CLAUDE.md).
