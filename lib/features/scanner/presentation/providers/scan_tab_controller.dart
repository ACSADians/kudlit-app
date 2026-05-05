import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

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
  });

  const ScanTabState.initial()
    : this(
        resultVisible: false,
        flashOn: false,
        selectedImageBytes: null,
        isLoadingImage: false,
        detectionsFrozen: false,
        snapshot: const <BaybayinDetection>[],
      );

  final bool resultVisible;
  final bool flashOn;
  final Uint8List? selectedImageBytes;
  final bool isLoadingImage;
  final bool detectionsFrozen;
  final List<BaybayinDetection> snapshot;

  ScanTabState copyWith({
    bool? resultVisible,
    bool? flashOn,
    Uint8List? selectedImageBytes,
    bool clearSelectedImage = false,
    bool? isLoadingImage,
    bool? detectionsFrozen,
    List<BaybayinDetection>? snapshot,
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
    );
  }
}

final NotifierProvider<ScanTabController, ScanTabState>
scanTabControllerProvider =
    NotifierProvider<ScanTabController, ScanTabState>(
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

    state = state.copyWith(isLoadingImage: true);
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
  }

  void dismissResult() {
    if (state.selectedImageBytes != null) {
      clearSelectedImage();
      return;
    }

    state = state.copyWith(
      resultVisible: false,
      snapshot: const <BaybayinDetection>[],
    );
  }

  void clearSelectedImage() {
    ref.read(scannerNotifierProvider.notifier).clear();
    state = state.copyWith(
      clearSelectedImage: true,
      resultVisible: false,
      snapshot: const <BaybayinDetection>[],
    );
  }

  void setDetectionsFrozen(bool value) {
    state = state.copyWith(detectionsFrozen: value);
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
