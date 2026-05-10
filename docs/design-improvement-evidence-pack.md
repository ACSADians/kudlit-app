# Design Improvement Evidence Pack

Date: 2026-05-10
Branch: `design-improvement`

## Scope

This pack summarizes the current design-improvement branch evidence for the
mobile-first UI pass. It covers Translate, Scan, Butty prompt clearance,
Settings AI model setup, and branch readiness against `origin/main`.

## Current UI Changes

- Settings AI models now use shorter local-setup copy, less technical status
  text, touch-safe progress/cancel controls, and clearer scanner/Butty model
  purposes. Model setup badges now use the app semantic color scheme instead
  of ad hoc red/green text colors.
- Translate text mode now renders cleanup previews as a higher-contrast helper
  pill and uses compact reverse-input layout after encoded examples produce
  actions.
- Butty suggested prompts reserve space for the floating tab control on narrow
  mobile screens.

## QA Evidence

Latest local visual evidence:

- `test-results/ui-verify/butty-carousel-clearance-390.png`
- `test-results/ui-verify/translate-header-translate-360.png`
- `test-results/ui-verify/translate-header-translate-390.png`
- `test-results/ui-verify/translate-header-translate-430.png`
- `test-results/ui-verify/translate-header-translate-844.png`
- `test-results/ui-verify/translate-header-scan-360.png`
- `test-results/ui-verify/translate-header-learn-360.png`
- `test-results/ui-verify/translate-header-butty-360.png`

Latest E2E visual evidence:

- `test-results/ui-verify-e2e/translate-header-translate-360.png`
- `test-results/ui-verify-e2e/translate-header-translate-390.png`
- `test-results/ui-verify-e2e/translate-header-translate-430.png`
- `test-results/ui-verify-e2e/translate-header-translate-844.png`
- `test-results/ui-verify-e2e/translate-header-scan-360.png`
- `test-results/ui-verify-e2e/translate-header-scan-390.png`
- `test-results/ui-verify-e2e/translate-header-scan-430.png`
- `test-results/ui-verify-e2e/translate-header-scan-844.png`
- `test-results/ui-verify-e2e/translate-header-learn-360.png`
- `test-results/ui-verify-e2e/translate-header-learn-390.png`
- `test-results/ui-verify-e2e/translate-header-learn-430.png`
- `test-results/ui-verify-e2e/translate-header-learn-844.png`
- `test-results/ui-verify-e2e/translate-header-butty-360.png`
- `test-results/ui-verify-e2e/translate-header-butty-390.png`
- `test-results/ui-verify-e2e/translate-header-butty-430.png`
- `test-results/ui-verify-e2e/translate-header-butty-844.png`

Latest scanner layout evidence:

- `qa-artifact/scan-layout-strict-overlap/report.json`
- `qa-artifact/scan-layout-strict-overlap/scan-layout-overlap-contact-sheet.html`
- Latest timestamp: `2026-05-10T18:08:55.7427350+08:00`
- Status: `pass`

Latest E2E scanner layout evidence:

- `qa-artifact/scan-layout-strict-overlap-e2e/report.json`
- `qa-artifact/scan-layout-strict-overlap-e2e/scan-layout-overlap-contact-sheet.html`
- Latest timestamp: `2026-05-10T18:57:58.7644946+08:00`
- Viewports covered: `360x740`, `390x844`, `430x932`, `844x390`,
  `1024x768`, `340x260`, `320x240`
- Status: `pass`

Latest smoke evidence:

- `qa-artifact/prod-smoke/report.json`
- Latest timestamp: `2026-05-10T18:09:44.6657712+08:00`
- Routes covered: `/#/login`, `/#/home`, `/#/settings`
- Status: `pass`

Latest design-cycle static build smoke:

- `qa-artifact/prod-smoke-design-cycle/report.json`
- Latest timestamp: `2026-05-10T18:41:44.2500076+08:00`
- Base URL: `http://127.0.0.1:5174`
- Viewport: `390,844`
- Routes covered: `/#/login`, `/#/home`, `/#/settings`
- Status: `pass`

Latest E2E static build smoke:

- `qa-artifact/prod-smoke-e2e/report.json`
- Latest timestamp: `2026-05-10T18:56:43.9550825+08:00`
- Base URL: `http://127.0.0.1:5174`
- Viewport: `390,844`
- Routes covered: `/#/login`, `/#/home`, `/#/settings`
- Status: `pass`

Latest command checks:

- `flutter analyze`: `pass`
- `flutter test`: `pass` (`167` tests)
- `flutter build web --release --base-href "/kudlit-app/"`: `pass`
- `flutter build web --release`: `pass`
- `pwsh scripts/verify-translate-header-ui.ps1 ... -Tabs "translate,scan,learn,butty" -SkipTests`: `pass`
- `pwsh scripts/prod-smoke.ps1 ...`: `pass`
- `pwsh scripts/scan-layout-overlap-pass.ps1 ...`: `pass`
- `git diff --check`: `pass` with CRLF normalization warnings only

## Branch Readiness

Checked without merging or switching branches:

- Fetched `origin/main` and `origin/design-improvement`.
- `git rev-list --left-right --count origin/main...HEAD`: `0 8`
- `design-improvement` is 8 commits ahead of `origin/main` and 0 commits
  behind.
- `git merge-tree $(git merge-base HEAD origin/main) origin/main HEAD` reported
  no conflict markers in the checked output.
- GitHub has no open PR for `design-improvement` at this snapshot.
- Recent PRs with `design-improvement` as the head branch are already merged;
  new local changes are not committed or pushed yet, so no remote CI run exists
  for this exact working tree.

Branch diff size against `origin/main`:

- 58 files changed.
- Includes app UI, scanner/translate model-readiness UX, tests, docs, web
  release assets, and deployment/docs updates.

## Remaining Gaps

- Real-device Android QA is still the main remaining confidence gap for native
  Settings model setup and scanner runtime behavior.
- Current checks prove layout, build, tests, and local web/static-preview
  behavior. They do not prove real model downloads from production data or
  physical camera latency.
- Merge/review is not performed here. This pack only reports readiness signals.
