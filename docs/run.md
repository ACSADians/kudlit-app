Fix 1 — add --no-dds flag (quickest fix):
  flutter run -d emulator-5554 --no-dds

Fix 2 — if that still fails, also disable auth
  codes:
  flutter run -d emulator-5554 --no-dds
  --disable-service-auth-codes

Camera permission E2E check (scanner)

Use this when validating camera status transitions in web scanner.

- Start app on http://127.0.0.1:5173.
- From repo root:
- cd tmp-playwright
- npm install
- npm run test:camera-permission-state
- npm run test:camera-permission-state:mobile-390x844
- npm run test:camera-permission-state:playwright
- npm run qa:clean-camera-permission-artifacts

- Manual scripted mobile capture (including blocked/prompt/granted with artifacts):
  - `node camera-permission-manual-flow-390x844.cjs`
  - `node camera-permission-manual-flow-390x844.cjs --headed`

The script covers:
- denied/prompt state capture
- denied (prompt blocked) transition
- granted state after permission grant

The focused Playwright spec (`test:camera-permission-state:playwright`) adds:
- explicit permission API checks for denied/prompt -> granted transitions
- deterministic 390x844 screenshot-name coverage

Artifacts are written under:
- tmp-playwright/qa-artifact/camera-permission-state/
  - camera-permission-denied-camera-state.png
  - camera-permission-denied.json
  - camera-permission-granted-camera-state.png
  - camera-permission-granted.json
  - camera-permission-transition-before-grant.png
  - camera-permission-transition-after-grant.png
  - camera-permission-transition.json
  - camera-permission-transition-summary.json

Expected pass criteria:
- script exits with `[PASS] camera-permission regression test completed`
- blocked/supported states are emitted in JSON artifacts
