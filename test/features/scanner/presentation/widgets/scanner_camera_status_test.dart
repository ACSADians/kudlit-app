import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/scanner_camera.dart';

void main() {
  test('web camera secure context allows HTTPS and localhost only', () {
    expect(
      isWebCameraSecureContext(Uri.parse('https://kudlit.example.com/#/home')),
      isTrue,
    );
    expect(
      isWebCameraSecureContext(Uri.parse('http://localhost:5173/#/home')),
      isTrue,
    );
    expect(
      isWebCameraSecureContext(Uri.parse('http://127.0.0.1:5173/#/home')),
      isTrue,
    );
    expect(
      isWebCameraSecureContext(Uri.parse('http://192.168.68.115:5173/#/home')),
      isFalse,
    );
  });

  testWidgets('web camera status card fits narrow scanner viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 288,
              child: WebStatusMessage(
                cs: ThemeData.dark().colorScheme,
                status: WebScannerStatus.permissionNeeded,
                showCompact: false,
                message:
                    'Camera permission is blocked. Allow camera access in the browser, then reload.',
              ),
            ),
          ),
        ),
      ),
    );

    final Rect cardRect = tester.getRect(find.byType(WebStatusMessage));

    expect(cardRect.width, lessThanOrEqualTo(288));
    expect(tester.takeException(), isNull);
  });

  testWidgets('web camera status announces title and recovery message', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WebStatusMessage(
              cs: ThemeData.dark().colorScheme,
              status: WebScannerStatus.permissionNeeded,
              showCompact: false,
              message:
                  'Camera permission is blocked. Allow camera access in the browser, then reload.',
            ),
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        'Allow camera. Camera permission is blocked. Allow camera access in the browser, then reload.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
