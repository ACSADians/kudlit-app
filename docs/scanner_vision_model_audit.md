# KudVis 1 Turbo — Scanner Vision Model Loading Audit

**Date:** 2026-05-04  
**Branch:** `feat/translate-update`  
**Scope:** YOLO TFLite / CoreML on-device inference — initialization, lifecycle, UX states, and performance across the camera and drawing-pad scopes

---

## TL;DR

The drawing-pad scope is well-optimized (pre-warmed, kept alive, graceful fallback to Gemma). The **camera scope has three compounding problems** that together make the scanner feel broken:

1. **`ModelNotReadyScreen` is shown for every state** — download-in-progress, error, and never-downloaded all render identical "Scanner Coming Soon" copy with no action and no progress. Users cannot tell what is happening.
2. **`yoloModelPathProvider(camera)` and `availableYoloModelsProvider` auto-dispose** — navigating away from the scan tab and back re-triggers the full download-check → loading sequence, showing `ModelNotReadyScreen` again even when the model is already on disk.
3. **No download progress on the scanner tab itself** — progress is only visible deep in Settings, so a user who goes straight to the scan tab after install has no feedback that anything is happening.

---

## 1. Current Architecture Snapshot

### Provider Chain (camera scope)

```
ScannerCamera.build()
  └─ yoloModelPathProvider(camera)           ← FutureProvider.family, NOT keepAlive
       └─ activeYoloModelProvider(camera)    ← Provider.family, sync
            └─ availableYoloModelsProvider   ← FutureProvider, NOT keepAlive → hits Supabase
            └─ yoloModelSelectionProvider    ← AsyncNotifier (SharedPrefs, fine)
       └─ YoloModelCache.isUpToDate()        ← file system check
       └─ YoloModelCache.download()          ← HTTP download if stale
       └─ returns: local file path
  └─ YOLOView(modelPath: path, ...)          ← native YOLO init happens here (lazy)
```

### Provider Chain (drawing-pad scope)

```
LessonStageScreen.build()
  └─ yoloDrawingPadModelProvider             ← FutureProvider + ref.keepAlive()
       └─ yoloModelPathProvider(drawingPad)  ← FutureProvider.family, same as camera
       └─ YOLO(modelPath).loadModel()        ← native init happens HERE, eagerly
       └─ returns: live YOLO instance
```

### What Each Loading State Renders in the Camera

| `yoloModelPathProvider` state | Rendered widget |
|---|---|
| `AsyncLoading` (catalog fetching / downloading) | `ModelNotReadyScreen` |
| `AsyncError` (any error, any reason) | `ModelNotReadyScreen` |
| `AsyncData(path)` (ready) | `YOLOView` |

All three non-happy states collapse to the same identical static screen.

---

## 2. Issues

### Issue 1 — `ModelNotReadyScreen` Conflates Three Different States

**Severity: Critical (UX)**

The screen text reads:
> *"Scanner Coming Soon — The Baybayin character recognition model is still being prepared. Check back in a future update!"*

This is shown for:
1. **Downloading** — model is 50% downloaded, user should wait
2. **Error** — network failed mid-download, user should retry
3. **Never installed** — first launch, user should start a download

All three get the exact same static copy with no indicator, no button, no progress. From the user's perspective:
- They cannot distinguish a temporary loading state from a permanent missing state.
- They cannot retry a failed download from the scan tab.
- They cannot see that progress is happening if they opened the scan tab before downloading.

---

### Issue 2 — `yoloModelPathProvider` and `availableYoloModelsProvider` Are Not `keepAlive`

**Severity: High (Performance + UX)**

Both providers are standard `FutureProvider` / `FutureProvider.family` without `ref.keepAlive()`. In Riverpod 2, `FutureProvider` created without codegen annotations IS keepAlive by default — UNLESS the bottom of the chain auto-disposes. Since both providers watch each other and are referenced only by `ScannerCamera` (which unmounts when the user leaves the scan tab), they can be garbage collected.

On tab return the sequence re-runs:
```
1. availableYoloModelsProvider → Supabase network call (200–800ms)
2. yoloModelPathProvider → cache check → (possibly re-downloads if version changed)
3. ScannerCamera renders ModelNotReadyScreen during all of the above
4. YOLOView re-initializes native model (not cached in Dart layer)
```

The user sees `ModelNotReadyScreen` on every visit to the scan tab even if the model was downloaded hours ago.

Compare to drawing-pad: `yoloDrawingPadModelProvider` explicitly calls `ref.keepAlive()` and survives lesson navigation. The camera scope needs the same treatment.

---

### Issue 3 — No Download Progress Exposed on the Scanner Page

**Severity: High (UX)**

`YoloModelCache.download()` accepts a `void Function(int progress)?` callback. This callback is used in `VisionDownloadTile` (the settings page) but NOT wired into `yoloModelPathProvider`. The provider has no way to report intermediate download progress — it either resolves or throws.

`ModelNotReadyScreen` therefore has no progress value to show even if it wanted to. The user who opens the scan tab on first install sees a static screen with no signal that anything is happening. They often think the app is broken.

---

### Issue 4 — No Camera-Scope Pre-Warming After Download

**Severity: Medium (Performance)**

When the user finishes the onboarding download (`ModelSetupController.download()`), the code invalidates `yoloModelPathProvider` but does NOT pre-warm the native model for the camera scope. Steps that still happen at first scan:

1. `availableYoloModelsProvider` re-fetches if disposed
2. `yoloModelPathProvider` re-resolves path (fast if cached)
3. `YOLOView` initializes native YOLO (the slow step — typically 500ms–2s)

All of this happens behind `ModelNotReadyScreen`.

The drawing-pad scope avoids this by eagerly calling `YOLO.loadModel()` inside `yoloDrawingPadModelProvider`. The camera scope relies on `YOLOView` to init the native model lazily.

---

### Issue 5 — Temporal Smoothing Adds ~1s Perception Latency

**Severity: Medium (UX)**

```dart
const int _kRequiredConsecutiveHits = 2;      // must appear in 2 windows
const Duration _kDetectionInterval = Duration(milliseconds: 500);
```

A glyph must be seen in 2 consecutive 500ms windows before being surfaced. This means a minimum of ~1 second passes between the YOLO model detecting a character and the user seeing the bounding box. For a real-time scanner this gap feels sluggish — the user often moves the camera before the box appears.

The intent (eliminating single-frame phantoms) is correct. The threshold is too conservative.

---

### Issue 6 — `_ScanningIndicator` Is a No-Op Widget

**Severity: Low (Dead Code)**

```dart
class _ScanningIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.only(top: 10), child: Center());
  }
}
```

This renders an invisible empty container at the top of the scan tab. It takes a Positioned slot in the Stack and contributes to the build tree for no visual output. Should be removed or given real content.

---

### Issue 7 — Confidence Threshold Comment Is Wrong

**Severity: Low (Code Clarity)**

```dart
/// Raised to 0.65 — the Baybayin model is domain-specific…
const double _kConfidenceThreshold = 0.8;
```

The comment says 0.65, the code is 0.8. If 0.8 is intentional (it likely is — Baybayin has high inter-class confusion), the comment must be updated. If it should be 0.65, there's a bug causing valid detections to be dropped.

---

### Issue 8 — Duplicate Confidence Filtering

**Severity: Low (Efficiency)**

The confidence threshold is applied twice:
1. Natively via `YOLOView(confidenceThreshold: _kConfidenceThreshold)` — YOLO drops results before they reach Dart
2. In Dart via `if (r.confidence < _kConfidenceThreshold) return false` inside `_onYoloResult`

The native filter already ensures no results below threshold reach the callback. The Dart check is redundant. It's cheap but worth documenting that it's a defensive belt-and-suspenders pattern, not a primary filter.

---

## 3. Call Graph (Current — Camera Scope Cold Start)

```
User opens Scan tab (first time or after navigation)
  └─ ScannerCamera.build()
       └─ ref.watch(yoloModelPathProvider(camera))
            │
            ├─ [AsyncLoading] availableYoloModelsProvider
            │     └─ Supabase.fetchModels(type: vision) — 200–800ms network
            │     → ScannerCamera renders ModelNotReadyScreen (no progress)
            │
            ├─ [AsyncLoading] YoloModelCache.isUpToDate()
            │     → ScannerCamera renders ModelNotReadyScreen (no progress)
            │
            ├─ [AsyncLoading] YoloModelCache.download() — if stale
            │     → ScannerCamera renders ModelNotReadyScreen (no progress!)
            │
            └─ [AsyncData(path)] resolved
                  └─ YOLOView renders
                       └─ Native YOLO.loadModel() — 500ms–2s, no indicator

User leaves Scan tab and comes back (providers auto-disposed)
  └─ SAME sequence repeats from scratch
```

---

## 4. Recommendations

### Rec 1 — Split `ModelNotReadyScreen` Into Three Meaningful States

**Priority: P0**

Replace the single generic screen with three distinct states surfaced from `yoloModelPathProvider`:

```
State A — Downloading (AsyncLoading with progress)
  → LinearProgressIndicator + "Downloading scanner model… X%"
  → No action needed, just wait

State B — Error (AsyncError)
  → Error icon + message + "Retry" button
  → Button calls ref.invalidate(yoloModelPathProvider(camera))

State C — Not installed (model null, catalog empty, or web)
  → Download icon + "Tap to download the scanner model"
  → Button navigates to settings/model setup
```

To expose download progress, `yoloModelPathProvider` needs a way to report intermediate state. Since `FutureProvider` can only resolve or reject, the cleanest approach is to add a separate `yoloDownloadProgressProvider` that `YoloModelCache` updates via a `StreamController`:

```dart
// New: stream of download progress (null = not downloading)
final StreamProvider<int?> yoloCameraDownloadProgressProvider = 
  StreamProvider<int?>((Ref ref) => YoloModelCache.instance.cameraProgressStream);
```

`ScannerCamera` watches both `yoloModelPathProvider` and `yoloCameraDownloadProgressProvider`. If path is loading AND progress is non-null, show the download progress screen.

---

### Rec 2 — Make Camera-Scope Providers `keepAlive`

**Priority: P0**

Add `ref.keepAlive()` inside `yoloModelPathProvider` when it returns a resolved path (same pattern used in `yoloDrawingPadModelProvider`):

```dart
final yoloModelPathProvider = FutureProvider.family<String, String>((
  Ref ref,
  String scope,
) async {
  // ... existing resolution logic ...
  final String? path = await cache.pathFor(model.id);
  if (path == null) throw StateError('...');
  ref.keepAlive();  // ← Keep the path alive once resolved
  return path;
});
```

And make `availableYoloModelsProvider` keepAlive too to avoid re-fetching the catalog on every visit:

```dart
final availableYoloModelsProvider = FutureProvider<List<AiModelInfo>>((Ref ref) async {
  // ... existing fetch ...
  ref.keepAlive();  // ← Catalog doesn't change at runtime
  return models;
});
```

Combined with the cache check (`isUpToDate`), this means the model is only re-downloaded when the catalog version is actually bumped — not on every tab visit.

---

### Rec 3 — Pre-Warm the Camera-Scope Native Model After Download

**Priority: P1**

After `ModelSetupController.download()` and `VisionDownloadTile` succeed, trigger path resolution for the camera scope to ensure the provider is loaded and cached before the user taps the scan tab:

```dart
// In model_setup_controller.dart, after YOLO download succeeds:
unawaited(
  ref.read(yoloModelPathProvider(YoloModelScope.camera).future)
      .catchError((_) {}), // ignore: first access may fail on non-mobile
);
```

This warms `yoloModelPathProvider` into `AsyncData` immediately after download. When the user opens the scan tab, the path is already resolved and `YOLOView` can start loading its native engine without waiting for any Dart-layer async work.

---

### Rec 4 — Reduce Temporal Smoothing Latency

**Priority: P1**

Reduce `_kRequiredConsecutiveHits` from 2 to 1, and compensate with a faster interval and a "pending" visual state:

```dart
const Duration _kDetectionInterval = Duration(milliseconds: 250);  // was 500
const int _kRequiredConsecutiveHits = 1;  // surface after first stable window
```

With 250ms interval and 1 hit required, valid glyphs surface in ~250ms. Single-frame phantoms (< 250ms) are still filtered. The overlay clearing on empty frames remains instant.

If phantom detections increase at 250ms, consider keeping 2 consecutive hits but showing a "dim" bounding box on the first hit (pending state) and a full-opacity box on the second. This gives instant visual feedback while the confirmation happens.

---

### Rec 5 — Remove `_ScanningIndicator`

**Priority: P2**

Either give it real content (e.g., a "Point at Baybayin text" guide chip that fades once the first detection appears) or delete it entirely. An empty `Center()` with padding silently eats layout space.

If real content is added, it's a good place to show the "downloading" status when `yoloModelPathProvider` is loading but the provider hasn't surfaced an error yet.

---

### Rec 6 — Fix Confidence Threshold Comment

**Priority: P3**

```dart
// Before:
/// Raised to 0.65 — the Baybayin model is domain-specific…
const double _kConfidenceThreshold = 0.8;

// After:
/// 0.8 — conservative threshold appropriate for Baybayin's high inter-class
/// confusion (e.g., 'ba' vs 'da' strokes). Lower only with model retraining.
const double _kConfidenceThreshold = 0.8;
```

---

## 5. Prioritized Fix Order

| Priority | Fix | Issue | Effort |
|---|---|---|---|
| P0 | `ref.keepAlive()` in `yoloModelPathProvider` + `availableYoloModelsProvider` | Re-download on every tab visit (Issue 2) | Small |
| P0 | Differentiated loading/error/not-installed states in `ModelNotReadyScreen` | Dead-end screen (Issue 1) | Medium |
| P1 | Expose download progress on scanner tab | No progress feedback (Issue 3) | Medium |
| P1 | Pre-warm camera-scope path after download | Cold start on first open (Issue 4) | Small |
| P1 | Reduce `_kDetectionInterval` + `_kRequiredConsecutiveHits` | 1s latency before glyphs surface (Issue 5) | Trivial |
| P2 | Remove or fill `_ScanningIndicator` | Dead code (Issue 6) | Trivial |
| P3 | Fix confidence threshold comment | Wrong docs (Issue 7) | Trivial |

---

## 6. What Is Already Well-Optimized (Do Not Change)

- **Drawing-pad pre-warming** — `yoloDrawingPadModelProvider` eagerly calls `YOLO.loadModel()` and uses `ref.keepAlive()`. This is the pattern the camera scope should copy, not replace.
- **Version-based cache freshness** — `YoloModelCache.isUpToDate(id, version)` only re-downloads when the catalog version bumps. Do not replace with a time-based TTL.
- **Platform-specific model URLs** — iOS vs Android URL resolution in `_platformUrl()` is correct and clean.
- **`baybayinDetectorProvider` is `keepAlive`** — The native `YOLOViewController` persists across tab switches. Do not remove this.
- **Double-sided confidence + edge filtering** — The Dart-side post-processing on top of native filtering is a good defensive pattern for this specific model. Leave it.
- **Cloud fallback in drawing-pad** — When YOLO inference fails during a lesson, the code falls back to Gemma image analysis. This is the right degradation path.

---

## 7. Files to Touch for the Fixes

| File | Change |
|---|---|
| `lib/features/scanner/presentation/providers/yolo_model_selection_provider.dart` | Add `ref.keepAlive()` in `yoloModelPathProvider` and `availableYoloModelsProvider` after successful resolution; add progress stream to `YoloModelCache` |
| `lib/features/scanner/data/datasources/yolo_model_cache.dart` | Expose `StreamController<int?>` per scope for download progress |
| `lib/features/scanner/presentation/widgets/model_not_ready_screen.dart` | Replace single static screen with `loading` / `error` / `notInstalled` variants |
| `lib/features/scanner/presentation/widgets/scanner_camera.dart` | Watch progress provider; render correct state; fix `_kDetectionInterval` and `_kRequiredConsecutiveHits`; fix comment |
| `lib/features/home/presentation/providers/model_setup_controller.dart` | Add pre-warm after YOLO download completes |
| `lib/features/home/presentation/widgets/settings/vision_download_tile.dart` | Add pre-warm after manual download completes |
| `lib/features/home/presentation/screens/scan_tab.dart` | Remove `_ScanningIndicator` or give it real content |

Total surface area: 7 files. No domain-layer changes required.
