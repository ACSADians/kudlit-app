import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/scanner_camera.dart';

void main() {
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
}
