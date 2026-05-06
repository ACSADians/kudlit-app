import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';

void main() {
  Future<void> pumpNav(WidgetTester tester, {required Size surfaceSize}) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              PositionedDirectional(
                end: 14,
                bottom: 12,
                child: FloatingTabNav(
                  activeTab: AppTab.scan,
                  onTabSelected: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('collapsed floating nav stays within phone viewport', (
    WidgetTester tester,
  ) async {
    await pumpNav(tester, surfaceSize: const Size(320, 593));

    final Rect navRect = tester.getRect(find.byType(FloatingTabNav));

    expect(navRect.left, greaterThanOrEqualTo(0));
    expect(navRect.right, lessThanOrEqualTo(320));
    expect(navRect.bottom, lessThanOrEqualTo(593));
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded floating nav fits compact landscape width', (
    WidgetTester tester,
  ) async {
    await pumpNav(tester, surfaceSize: const Size(593, 360));

    await tester.tap(find.byType(FloatingTabNav));
    await tester.pumpAndSettle();

    final Rect navRect = tester.getRect(find.byType(FloatingTabNav));

    expect(navRect.left, greaterThanOrEqualTo(0));
    expect(navRect.right, lessThanOrEqualTo(593));
    expect(navRect.bottom, lessThanOrEqualTo(360));
    expect(tester.takeException(), isNull);
  });
}
