import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet.dart';

void main() {
  testWidgets('auth shell uses side-by-side layout in landscape', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreenShell(
          hero: const ColoredBox(key: Key('hero'), color: Colors.blue),
          sheet: AuthSheet(
            child: KeyedSubtree(
              key: const Key('sheet-content'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List<Widget>.generate(
                  12,
                  (int index) => const SizedBox(height: 56),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Rect heroRect = tester.getRect(find.byKey(const Key('hero')));
    final Rect sheetRect = tester.getRect(find.byType(AuthSheet));

    expect(heroRect.left, 0);
    expect(heroRect.top, 0);
    expect(sheetRect.left, greaterThan(heroRect.right - 1));
    expect(sheetRect.top, 0);
    expect(sheetRect.bottom, 390);
  });

  testWidgets('auth shell collapses decorative hero under landscape keyboard', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(() {
      tester.view.resetViewInsets();
      tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreenShell(
          hero: const ColoredBox(key: Key('hero'), color: Colors.blue),
          sheet: AuthSheet(
            child: KeyedSubtree(
              key: const Key('sheet-content'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List<Widget>.generate(
                  12,
                  (int index) => const SizedBox(height: 56),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('hero')), findsNothing);
    expect(
      find.byKey(const Key('auth-keyboard-hero-fallback')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('sheet-content')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
