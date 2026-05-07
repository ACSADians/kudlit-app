import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scan_tab_controller.dart';

void main() {
  test('captureWebFrame hides result panel when capture fails empty', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(scanTabControllerProvider.notifier)
        .captureWebFrame(() async => (const <BaybayinDetection>[], null));

    final ScanTabState state = container.read(scanTabControllerProvider);
    expect(state.isLoadingImage, isFalse);
    expect(state.resultVisible, isFalse);
    expect(state.snapshot, isEmpty);
    expect(state.scanNotice, isNotNull);
    expect(state.scanNotice!.title, 'No glyphs detected');
  });

  test('clearNotice returns no-glyph notice to camera state', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(scanTabControllerProvider.notifier)
        .captureWebFrame(() async => (const <BaybayinDetection>[], null));

    container.read(scanTabControllerProvider.notifier).clearNotice();

    final ScanTabState state = container.read(scanTabControllerProvider);
    expect(state.resultVisible, isFalse);
    expect(state.snapshot, isEmpty);
    expect(state.scanNotice, isNull);
  });

  test('captureWebFrame shows result panel when detections exist', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(scanTabControllerProvider.notifier)
        .captureWebFrame(
          () async => (
            const <BaybayinDetection>[
              BaybayinDetection(
                label: 'ba',
                confidence: 0.91,
                left: 0.2,
                top: 0.2,
                width: 0.3,
                height: 0.3,
              ),
            ],
            null,
          ),
        );

    final ScanTabState state = container.read(scanTabControllerProvider);
    expect(state.isLoadingImage, isFalse);
    expect(state.resultVisible, isTrue);
    expect(state.snapshot, hasLength(1));
    expect(state.scanNotice, isNull);
  });
}
