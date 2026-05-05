import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_evaluation_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';

@immutable
class ScanNotice {
  const ScanNotice({
    required this.title,
    required this.message,
    required this.kind,
  });

  final String title;
  final String message;
  final ScanNoticeKind kind;
}

enum ScanNoticeKind { info, warning, error }

class ScanCaptureException implements Exception {
  const ScanCaptureException(this.notice);

  final ScanNotice notice;

  @override
  String toString() => '${notice.title}: ${notice.message}';
}

@immutable
class ScanTabState {
  const ScanTabState({
    required this.resultVisible,
    required this.flashOn,
    required this.selectedImageBytes,
    required this.isLoadingImage,
    required this.detectionsFrozen,
    required this.snapshot,
    this.scanNotice,
  });

  const ScanTabState.initial()
    : this(
        resultVisible: false,
        flashOn: false,
        selectedImageBytes: null,
        isLoadingImage: false,
        detectionsFrozen: false,
        snapshot: const <BaybayinDetection>[],
        scanNotice: null,
      );

  final bool resultVisible;
  final bool flashOn;
  final Uint8List? selectedImageBytes;
  final bool isLoadingImage;
  final bool detectionsFrozen;
  final List<BaybayinDetection> snapshot;
  final ScanNotice? scanNotice;

  ScanTabState copyWith({
    bool? resultVisible,
    bool? flashOn,
    Uint8List? selectedImageBytes,
    bool clearSelectedImage = false,
    bool? isLoadingImage,
    bool? detectionsFrozen,
    List<BaybayinDetection>? snapshot,
    ScanNotice? scanNotice,
    bool clearScanNotice = false,
  }) {
    return ScanTabState(
      resultVisible: resultVisible ?? this.resultVisible,
      flashOn: flashOn ?? this.flashOn,
      selectedImageBytes: clearSelectedImage
          ? null
          : (selectedImageBytes ?? this.selectedImageBytes),
      isLoadingImage: isLoadingImage ?? this.isLoadingImage,
      detectionsFrozen: detectionsFrozen ?? this.detectionsFrozen,
      snapshot: snapshot ?? this.snapshot,
      scanNotice: clearScanNotice ? null : (scanNotice ?? this.scanNotice),
    );
  }
}

final NotifierProvider<ScanTabController, ScanTabState>
scanTabControllerProvider = NotifierProvider<ScanTabController, ScanTabState>(
  ScanTabController.new,
);

class ScanTabController extends Notifier<ScanTabState> {
  @override
  ScanTabState build() => const ScanTabState.initial();

  Future<void> toggleFlash() async {
    final bool next = !state.flashOn;
    state = state.copyWith(flashOn: next);
    await ref.read(baybayinDetectorProvider).toggleTorch(enabled: next);
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    state = state.copyWith(isLoadingImage: true, clearScanNotice: true);
    final Uint8List bytes = await image.readAsBytes();
    state = state.copyWith(
      selectedImageBytes: bytes,
      isLoadingImage: false,
      resultVisible: true,
      clearScanNotice: true,
    );

    final List<BaybayinDetection> results = await ref
        .read(baybayinDetectorProvider)
        .detectImage(bytes);

    ref.read(scannerNotifierProvider.notifier).update(results);
    _evaluateSafely(results, bytes);
    state = state.copyWith(snapshot: List<BaybayinDetection>.of(results));
  }

  Future<void> captureWebFrame(
    Future<List<BaybayinDetection>> Function() capture,
  ) async {
    state = state.copyWith(
      isLoadingImage: true,
      resultVisible: false,
      clearSelectedImage: true,
      snapshot: const <BaybayinDetection>[],
      clearScanNotice: true,
    );

    try {
      final List<BaybayinDetection> results = await capture();
      ref.read(scannerNotifierProvider.notifier).update(results);
      if (results.isNotEmpty) {
        _evaluateSafely(results, null);
      }
      state = state.copyWith(
        isLoadingImage: false,
        resultVisible: results.isNotEmpty,
        snapshot: List<BaybayinDetection>.of(results),
        scanNotice: results.isEmpty
            ? const ScanNotice(
                title: 'No glyphs detected',
                message:
                    'Keep the Baybayin text centered and well lit, then capture again.',
                kind: ScanNoticeKind.warning,
              )
            : null,
        clearScanNotice: results.isNotEmpty,
      );
    } on ScanCaptureException catch (e) {
      ref.read(scannerNotifierProvider.notifier).clear();
      state = state.copyWith(
        isLoadingImage: false,
        resultVisible: false,
        snapshot: const <BaybayinDetection>[],
        scanNotice: e.notice,
      );
    } catch (_) {
      ref.read(scannerNotifierProvider.notifier).clear();
      state = state.copyWith(
        isLoadingImage: false,
        resultVisible: false,
        snapshot: const <BaybayinDetection>[],
        scanNotice: const ScanNotice(
          title: 'Capture failed',
          message: 'Try again or use Gallery to test an image.',
          kind: ScanNoticeKind.error,
        ),
      );
    }
  }

  void onShutterTapped() {
    final List<BaybayinDetection> detections = ref.read(
      scannerNotifierProvider,
    );
    if (state.resultVisible) {
      state = state.copyWith(
        resultVisible: false,
        snapshot: const <BaybayinDetection>[],
        clearScanNotice: true,
      );
      return;
    }

    if (detections.isEmpty) {
      state = state.copyWith(
        resultVisible: false,
        snapshot: const <BaybayinDetection>[],
        scanNotice: const ScanNotice(
          title: 'No glyphs detected',
          message: 'Frame one or more Baybayin glyphs before capturing.',
          kind: ScanNoticeKind.warning,
        ),
      );
      return;
    }

    state = state.copyWith(
      resultVisible: true,
      snapshot: List<BaybayinDetection>.of(detections),
      clearScanNotice: true,
    );
    _evaluateSafely(detections, state.selectedImageBytes);
  }

  void applyLiveDetections(List<BaybayinDetection> detections) {
    if (state.selectedImageBytes != null || state.detectionsFrozen) {
      return;
    }
    ref.read(scannerNotifierProvider.notifier).update(detections);
  }

  void dismissResult() {
    if (state.selectedImageBytes != null) {
      clearSelectedImage();
      return;
    }

    state = state.copyWith(
      resultVisible: false,
      snapshot: const <BaybayinDetection>[],
      clearScanNotice: true,
    );
  }

  void clearSelectedImage() {
    ref.read(scannerNotifierProvider.notifier).clear();
    state = state.copyWith(
      clearSelectedImage: true,
      resultVisible: false,
      snapshot: const <BaybayinDetection>[],
      clearScanNotice: true,
    );
  }

  void showNotice(ScanNotice notice) {
    state = state.copyWith(scanNotice: notice, resultVisible: false);
  }

  void clearNotice() {
    state = state.copyWith(clearScanNotice: true);
  }

  void _evaluateSafely(
    List<BaybayinDetection> detections,
    Uint8List? imageBytes,
  ) {
    try {
      ref
          .read(scannerEvaluationProvider.notifier)
          .evaluate(detections, imageBytes);
    } catch (_) {
      // The OCR result should remain usable even when the optional AI
      // explanation path is unavailable in tests, offline, or unauthenticated
      // web sessions.
    }
  }

  void setDetectionsFrozen(bool value) {
    state = state.copyWith(detectionsFrozen: value);
  }
}
