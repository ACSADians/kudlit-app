import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/app_bottom_nav.dart';
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

  testWidgets('floating nav exposes accessible tab labels', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pumpNav(tester, surfaceSize: const Size(320, 593));

    expect(
      find.bySemanticsLabel('Open home tab navigation, current tab Scan'),
      findsOneWidget,
    );

    await tester.tap(find.byType(FloatingTabNav));
    await tester.pumpAndSettle();

    for (final String label in <String>[
      'Scan tab',
      'Translate tab',
      'Learn tab',
      'Butty tab',
    ]) {
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Semantics && widget.properties.label == label,
        ),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);

    semantics.dispose();
  });

  testWidgets('expanded floating nav keeps comfortable tap targets', (
    WidgetTester tester,
  ) async {
    await pumpNav(tester, surfaceSize: const Size(320, 593));

    await tester.tap(find.byType(FloatingTabNav));
    await tester.pumpAndSettle();

    for (final String label in <String>[
      'Scan',
      'Translate',
      'Learn',
      'Butty',
    ]) {
      final Rect rect = tester.getRect(find.byTooltip(label));
      expect(rect.height, greaterThanOrEqualTo(44));
      expect(rect.width, greaterThanOrEqualTo(44));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy bottom nav keeps semantic labels and tap targets', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(currentIndex: 0, onTap: (_) {}),
        ),
      ),
    );

    for (final String label in <String>[
      'Home tab',
      'Scan tab',
      'Learn tab',
      'Profile tab',
    ]) {
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Semantics && widget.properties.label == label,
        ),
        findsOneWidget,
      );
    }

    for (final Element element in find.byType(InkWell).evaluate()) {
      final Rect rect = tester.getRect(find.byWidget(element.widget));
      expect(rect.height, greaterThanOrEqualTo(44));
    }

    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
