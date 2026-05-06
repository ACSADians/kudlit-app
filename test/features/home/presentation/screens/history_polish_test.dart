import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/domain/entities/translation_result.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translation_history_provider.dart';
import 'package:kudlit_ph/features/home/presentation/screens/translation_history_screen.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/scan_result.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scan_history_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/screens/scan_history_screen.dart';

class _FakeScanHistoryNotifier extends ScanHistoryNotifier {
  _FakeScanHistoryNotifier(this.results);

  final List<ScanResult> results;

  @override
  Future<List<ScanResult>> build() async => results;
}

class _FakeTranslationHistoryNotifier extends TranslationHistoryNotifier {
  _FakeTranslationHistoryNotifier(this.results);

  final List<TranslationResult> results;

  @override
  Future<List<TranslationResult>> build() async => results;
}

void main() {
  testWidgets('scan history empty state fits narrow phone viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanHistoryNotifierProvider.overrideWith(
            () => _FakeScanHistoryNotifier(const <ScanResult>[]),
          ),
        ],
        child: const MaterialApp(home: ScanHistoryScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No scans yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scan history card wraps long readings in landscape', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(593, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanHistoryNotifierProvider.overrideWith(
            () => _FakeScanHistoryNotifier(<ScanResult>[
              ScanResult(
                tokens: const <String>['ka', 'ma', 'ta', 'yo', 'li', 'ng'],
                translation:
                    'A long saved scanner interpretation that should wrap without pushing actions off screen.',
                timestamp: DateTime(2026, 5, 7),
              ),
            ]),
          ),
        ],
        child: const MaterialApp(home: ScanHistoryScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Scanner History'), findsOneWidget);
    expect(find.text('ka'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'translation history card keeps bookmark tap target comfortable',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 593));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            translationHistoryNotifierProvider.overrideWith(
              () => _FakeTranslationHistoryNotifier(<TranslationResult>[
                TranslationResult(
                  id: 1,
                  inputText:
                      'mahabang halimbawa para sa maliit na screen ng mobile',
                  baybayinText: 'ᜋᜑᜊᜅ᜔ ᜑᜎᜒᜋ᜔ᜊᜏ',
                  latinText: 'mahabang halimbawa',
                  direction: 'latin_to_baybayin',
                  aiResponse:
                      'Short AI note that should stay within the card bounds.',
                  isBookmarked: false,
                  timestamp: DateTime(2026, 5, 7),
                ),
              ]),
            ),
          ],
          child: const MaterialApp(home: TranslationHistoryScreen()),
        ),
      );
      await tester.pump();

      final Rect bookmark = tester.getRect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is IconButton && widget.tooltip == 'Bookmark',
        ),
      );

      expect(bookmark.width, greaterThanOrEqualTo(44));
      expect(bookmark.height, greaterThanOrEqualTo(44));
      expect(tester.takeException(), isNull);
    },
  );
}
