import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/export_sheet.dart';

void main() {
  testWidgets('export sheet keeps controls reachable on narrow portrait', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BaybayinExportSheet(
            baybayin: 'ᜃᜓᜇ᜔ᜎᜒᜆ᜔ ᜋᜑᜊᜅ᜔ ᜑᜎᜒᜋ᜔ᜊᜏ',
            latin: 'Kudlit long export preview',
          ),
        ),
      ),
    );

    final Rect button = tester.getRect(find.byType(FilledButton));

    expect(button.height, greaterThanOrEqualTo(44));
    expect(button.bottom, lessThanOrEqualTo(593));
    expect(tester.takeException(), isNull);
  });

  testWidgets('export sheet fits compact landscape without clipping CTA', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(593, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BaybayinExportSheet(baybayin: 'ᜊᜌ᜔ᜊᜌᜒᜈ᜔', latin: 'Baybayin'),
        ),
      ),
    );

    expect(find.text('Export as image'), findsOneWidget);
    expect(find.text('Export image'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('export background choices expose selected semantics', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BaybayinExportSheet(baybayin: 'ᜊᜌ᜔', latin: 'Bay'),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Space background, selected'), findsOneWidget);

    final Rect firstSwatch = tester.getRect(find.byType(InkWell).first);
    expect(firstSwatch.width, greaterThanOrEqualTo(44));
    expect(firstSwatch.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
