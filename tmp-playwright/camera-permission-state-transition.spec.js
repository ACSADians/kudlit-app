const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');
const { expect, test } = require('@playwright/test');

const ORIGIN = 'http://127.0.0.1:5173';
const SCAN_PATH = '/#/home?tab=scan';
const VIEWPORT = { width: 390, height: 844 };
const VIEWPORT_TAG = `${VIEWPORT.width}x${VIEWPORT.height}`;
const ARTIFACT_ROOT = path.join(
  __dirname,
  'qa-artifact',
  'camera-permission-state',
  'transition-regression',
);

const SCREENSHOTS = {
  denied: `camera-permission-denied-camera-state-${VIEWPORT_TAG}.png`,
  transitionBefore: `camera-permission-transition-before-grant-${VIEWPORT_TAG}.png`,
  transitionAfter: `camera-permission-transition-after-grant-${VIEWPORT_TAG}.png`,
  granted: `camera-permission-granted-camera-state-${VIEWPORT_TAG}.png`,
};

function normalizePermissionState(permission) {
  if (!permission || !permission.supported) return null;
  return permission.state;
}

async function readPermissionState(page) {
  return page.evaluate(async () => {
    if (!('permissions' in navigator)) {
      return { supported: false, state: null, error: null };
    }

    try {
      const status = await navigator.permissions.query({ name: 'camera' });
      return { supported: true, state: status.state, error: null };
    } catch (error) {
      return {
        supported: true,
        state: null,
        error: error?.message ?? String(error),
      };
    }
  });
}

function assertStateValue(permission, expectedStates) {
  const state = normalizePermissionState(permission);
  expect(permission?.supported, 'Permission API should be supported').toBe(true);
  expect(expectedStates.includes(state), `Expected ${expectedStates.join(', ')} got ${state}`).toBe(true);
  return state;
}

function writeArtifact(name, data) {
  fs.mkdirSync(ARTIFACT_ROOT, { recursive: true });
  fs.writeFileSync(path.join(ARTIFACT_ROOT, `${name}.json`), JSON.stringify(data, null, 2));
}

function writeScreenshot(page, name) {
  const filePath = path.join(ARTIFACT_ROOT, name);
  return page.screenshot({ path: filePath, fullPage: true }).then(() => filePath);
}

test('camera denied and grant transition keeps deterministic permission API + screenshot names', async () => {
  fs.mkdirSync(ARTIFACT_ROOT, { recursive: true });

  const browser = await chromium.launch({
    headless: true,
    args: ['--deny-permission-prompts', '--use-fake-device-for-media-stream'],
  });
  const context = await browser.newContext({
    viewport: VIEWPORT,
  });
  const page = await context.newPage();
  const logs = [];
  const url = `${ORIGIN}${SCAN_PATH}&qa_camera_status=denied`;

  page.on('console', (msg) => {
    logs.push(`[${msg.type()}] ${msg.text()}`);
  });

  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2500);

  const denied = await readPermissionState(page);
  const deniedState = assertStateValue(denied, ['prompt', 'denied']);

  const deniedScreenshot = await writeScreenshot(page, SCREENSHOTS.denied);
  expect(fs.existsSync(deniedScreenshot), `Expected ${SCREENSHOTS.denied} to exist`).toBe(true);
  expect(fs.statSync(deniedScreenshot).size, 'Screenshot should not be empty').toBeGreaterThan(0);

  const transitionBefore = await writeScreenshot(page, SCREENSHOTS.transitionBefore);
  expect(fs.existsSync(transitionBefore), `Expected ${SCREENSHOTS.transitionBefore} to exist`).toBe(true);
  expect(fs.statSync(transitionBefore).size, 'Screenshot should not be empty').toBeGreaterThan(0);

  await context.grantPermissions(['camera'], { origin: ORIGIN });
  await page.reload({ waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2500);

  const granted = await readPermissionState(page);
  const grantedState = assertStateValue(granted, ['granted']);

  const transitionAfter = await writeScreenshot(page, SCREENSHOTS.transitionAfter);
  expect(fs.existsSync(transitionAfter), `Expected ${SCREENSHOTS.transitionAfter} to exist`).toBe(true);
  expect(fs.statSync(transitionAfter).size, 'Screenshot should not be empty').toBeGreaterThan(0);

  const grantedScenarioUrl = `${ORIGIN}${SCAN_PATH}&qa_camera_status=granted`;
  await page.goto(grantedScenarioUrl, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2500);
  const grantedDirect = await readPermissionState(page);
  const grantedDirectState = assertStateValue(grantedDirect, ['granted']);
  const grantedScenarioScreenshot = await writeScreenshot(page, SCREENSHOTS.granted);
  expect(fs.existsSync(grantedScenarioScreenshot), `Expected ${SCREENSHOTS.granted} to exist`).toBe(true);
  expect(fs.statSync(grantedScenarioScreenshot).size, 'Screenshot should not be empty').toBeGreaterThan(0);

  await page.close();
  await context.close();
  await browser.close();

  writeArtifact('camera-permission-transition-regression', {
    scenarioUrls: {
      denied: url,
      grantedScenario: grantedScenarioUrl,
    },
    permission: {
      denied: deniedState,
      beforeGrant: deniedState,
      afterGrant: grantedState,
      grantedDirect: grantedDirectState,
    },
    screenshots: SCREENSHOTS,
    logs,
    viewport: VIEWPORT_TAG,
    passedAt: new Date().toISOString(),
  });

});
