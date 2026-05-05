import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/core/utils/baybayify.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_evaluation_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';

@immutable
class ScanTabState {
  const ScanTabState({
    required this.resultVisible,
    required this.flashOn,
    required this.selectedImageBytes,
    required this.isLoadingImage,
    required this.detectionsFrozen,
    required this.snapshot,
    required this.aggregatedWinner,
  });

  const ScanTabState.initial()
    : this(
        resultVisible: false,
        flashOn: false,
        selectedImageBytes: null,
        isLoadingImage: false,
        detectionsFrozen: false,
        snapshot: const <BaybayinDetection>[],
        aggregatedWinner: null,
      );

  final bool resultVisible;
  final bool flashOn;
  final Uint8List? selectedImageBytes;
  final bool isLoadingImage;
  final bool detectionsFrozen;
  final List<BaybayinDetection> snapshot;

  /// Most-frequent reading from the recent live-scan rolling window.
  /// Persists past idle so the user keeps seeing the last stable read
  /// after pulling the camera away.
  final String? aggregatedWinner;

  ScanTabState copyWith({
    bool? resultVisible,
    bool? flashOn,
    Uint8List? selectedImageBytes,
    bool clearSelectedImage = false,
    bool? isLoadingImage,
    bool? detectionsFrozen,
    List<BaybayinDetection>? snapshot,
    String? aggregatedWinner,
    bool clearAggregatedWinner = false,
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
      aggregatedWinner: clearAggregatedWinner
          ? null
          : (aggregatedWinner ?? this.aggregatedWinner),
    );
  }
}

final NotifierProvider<ScanTabController, ScanTabState>
scanTabControllerProvider =
    NotifierProvider<ScanTabController, ScanTabState>(
      ScanTabController.new,
    );

class ScanTabController extends Notifier<ScanTabState> {
  /// Sliding window of per-frame winning candidates.
  static const int _kAggMaxBuffer = 50;

  /// Idle period after which the rolling buffer is cleared (winner persists).
  static const Duration _kAggIdleTimeout = Duration(milliseconds: 1000);

  final Queue<String> _aggBuffer = Queue<String>();
  final Map<String, int> _aggFreq = <String, int>{};
  Timer? _aggIdleTimer;

  @override
  ScanTabState build() {
    ref.onDispose(_resetAggregator);
    return const ScanTabState.initial();
  }

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

    _resetAggregator();
    state = state.copyWith(
      isLoadingImage: true,
      clearAggregatedWinner: true,
    );
    final Uint8List bytes = await image.readAsBytes();
    state = state.copyWith(
      selectedImageBytes: bytes,
      isLoadingImage: false,
      resultVisible: true,
    );

    final List<BaybayinDetection> results = kIsWeb
        ? <BaybayinDetection>[]
        : await _detectImageWithYolo(bytes);

    ref.read(scannerNotifierProvider.notifier).update(results);
    ref.read(scannerEvaluationProvider.notifier).evaluate(results, bytes);
    state = state.copyWith(snapshot: List<BaybayinDetection>.of(results));
  }

  void onShutterTapped() {
    final List<BaybayinDetection> detections = ref.read(scannerNotifierProvider);
    if (state.resultVisible) {
      state = state.copyWith(
        resultVisible: false,
        snapshot: const <BaybayinDetection>[],
      );
      return;
    }

    state = state.copyWith(
      resultVisible: true,
      snapshot: List<BaybayinDetection>.of(detections),
    );
    ref
        .read(scannerEvaluationProvider.notifier)
        .evaluate(detections, state.selectedImageBytes);
  }

  void applyLiveDetections(List<BaybayinDetection> detections) {
    if (state.selectedImageBytes != null || state.detectionsFrozen) {
      return;
    }
    ref.read(scannerNotifierProvider.notifier).update(detections);
    _pushAggregatedScan(detections);
  }

  void dismissResult() {
    if (state.selectedImageBytes != null) {
      clearSelectedImage();
      return;
    }

    _resetAggregator();
    state = state.copyWith(
      resultVisible: false,
      snapshot: const <BaybayinDetection>[],
      clearAggregatedWinner: true,
    );
  }

  void clearSelectedImage() {
    ref.read(scannerNotifierProvider.notifier).clear();
    _resetAggregator();
    state = state.copyWith(
      clearSelectedImage: true,
      resultVisible: false,
      snapshot: const <BaybayinDetection>[],
      clearAggregatedWinner: true,
    );
  }

  void setDetectionsFrozen(bool value) {
    state = state.copyWith(detectionsFrozen: value);
  }

  void _resetAggregator() {
    _aggIdleTimer?.cancel();
    _aggIdleTimer = null;
    _aggBuffer.clear();
    _aggFreq.clear();
  }

  void _pushAggregatedScan(List<BaybayinDetection> detections) {
    if (detections.isEmpty) return;

    final List<BaybayinDetection> ordered =
        List<BaybayinDetection>.of(detections)..sort(
          (BaybayinDetection a, BaybayinDetection b) =>
              a.left.compareTo(b.left),
        );
    final List<String> tokens = ordered
        .map((BaybayinDetection d) => d.label.trim().toLowerCase())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    final List<String> perms = permuteBaybayin(tokens);
    if (perms.isEmpty) return;
    final String candidate = perms.first;

    if (_aggBuffer.length >= _kAggMaxBuffer) {
      final String evicted = _aggBuffer.removeFirst();
      final int prev = _aggFreq[evicted] ?? 0;
      if (prev <= 1) {
        _aggFreq.remove(evicted);
      } else {
        _aggFreq[evicted] = prev - 1;
      }
    }
    _aggBuffer.addLast(candidate);
    _aggFreq.update(candidate, (int v) => v + 1, ifAbsent: () => 1);

    String top = '';
    int max = 0;
    _aggFreq.forEach((String k, int v) {
      if (v > max) {
        max = v;
        top = k;
      }
    });

    if (top.isNotEmpty && top != state.aggregatedWinner) {
      state = state.copyWith(aggregatedWinner: top);
    }

    _aggIdleTimer?.cancel();
    _aggIdleTimer = Timer(_kAggIdleTimeout, () {
      _aggBuffer.clear();
      _aggFreq.clear();
    });
  }

  Future<List<BaybayinDetection>> _detectImageWithYolo(
    Uint8List bytes,
  ) async {
    try {
      final YOLO yolo = await ref.read(yoloCameraModelProvider.future);
      final Map<String, dynamic> raw = await yolo.predict(bytes);
      final List<dynamic> detectionMaps =
          raw['detections'] as List<dynamic>? ?? <dynamic>[];
      return detectionMaps.map((dynamic d) {
        final YOLOResult r =
            YOLOResult.fromMap(d as Map<dynamic, dynamic>);
        return BaybayinDetection(
          label: r.className,
          confidence: r.confidence,
          left: r.normalizedBox.left,
          top: r.normalizedBox.top,
          width: r.normalizedBox.width,
          height: r.normalizedBox.height,
        );
      }).toList(growable: false);
    } catch (e) {
      debugPrint('[ScanTab] gallery detection failed: $e');
      return <BaybayinDetection>[];
    }
  }
}
