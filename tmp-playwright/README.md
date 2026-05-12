## Scanner camera permission checks

Quick QA entry points for camera permission coverage in web scanner.

### 1) Command-line regression (default)

- In this folder:
  - `npm install`
  - `npm run test:camera-permission-state`
- Artifacts:
  - `qa-artifact/camera-permission-state/camera-permission-denied.json`
  - `qa-artifact/camera-permission-state/camera-permission-granted.json`
  - `qa-artifact/camera-permission-state/camera-permission-transition-summary.json`
  - matching `*.png` screenshots in the same folder

### 2) Mobile strict variant (390x844) + naming checks

- Run a mobile-sized check with deterministic filenames from `tmp-playwright`:
  - `npm run test:camera-permission-state:mobile-390x844`
  - expected names (written by the script):
      - `camera-permission-denied-camera-state-390x844.png`
      - `camera-permission-granted-camera-state-390x844.png`
      - `camera-permission-transition-before-grant-390x844.png`
      - `camera-permission-transition-after-grant-390x844.png`
- Artifacts are written to:
  - `qa-artifact/camera-permission-state/mobile-390x844/`
- Pass check:
  - script prints `[PASS] camera-permission mobile viewport regression completed`
  - all 4 expected screenshot names exist

### 3) Manual capture flow (scanner states)

- Open each URL and capture a screenshot in the same folder:
  - `http://127.0.0.1:5173/#/home?tab=scan&scenario=denied&qa_camera_status=denied`
  - `http://127.0.0.1:5173/#/home?tab=scan&scenario=prompt&qa_camera_status=prompt`
  - `http://127.0.0.1:5173/#/home?tab=scan&scenario=granted&qa_camera_status=granted`
- Save expected screenshots:
  - `qa-artifact/manual-camera-flow/denied-camera-status.png`
  - `qa-artifact/manual-camera-flow/prompt-camera-status.png`
  - `qa-artifact/manual-camera-flow/granted-camera-status.png`
- Save console/state evidence in matching `*.json`.

### 4) Manual scripted capture (recommended)

- One command run (headless):
  - `node camera-permission-manual-flow-390x844.cjs`
- One command run (headed browser for visual review):
  - `node camera-permission-manual-flow-390x844.cjs --headed`

Artifacts:
- same filenames as above plus:
  - `qa-artifact/manual-camera-flow/denied-browser-blocked-camera-status.png`
  - `qa-artifact/manual-camera-flow/denied-browser-blocked-camera-status.json`
  - `qa-artifact/manual-camera-flow/camera-status-manual-summary.json`

### 5) Focused Playwright regression (denied transition + screenshot naming)

- Focused long-lived regression test for permission API state + transition flow:
  - `npm run test:camera-permission-state:playwright`
- The test:
  - verifies permission API state transitions from denied/prompt -> granted
  - captures `camera-permission-denied-camera-state-390x844.png`
  - captures `camera-permission-transition-before-grant-390x844.png`
  - captures `camera-permission-transition-after-grant-390x844.png`
  - captures `camera-permission-granted-camera-state-390x844.png`
- Test artifacts:
  - `qa-artifact/camera-permission-state/transition-regression/camera-permission-transition-regression.json`
  - screenshot artifacts in the same folder

### 6) Cleanup permission artifacts

- Run before another fresh permission sweep:
  - `npm run qa:clean-camera-permission-artifacts`
- This will reset:
  - `qa-artifact/camera-permission-state/`
  - `qa-artifact/camera-permission-state/mobile-390x844/`
  - `qa-artifact/camera-permission-state/transition-regression/`
  - `qa-artifact/manual-camera-flow/`
