import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_text_controller.dart';
import 'package:kudlit_ph/features/home/presentation/screens/translate_screen.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/app_header/app_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/filled_output.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/output_actions.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_text_mode_panel.dart';

void main() {
  testWidgets('translate header fits narrow phone without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TranslateHeader(
            aiMode: AiPreference.cloud,
            workspaceMode: TranslateWorkspaceMode.text,
            onAiModeChanged: (_) {},
            onWorkspaceModeChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Translate'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long translate output stays inside a narrow viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 288,
                  child: FilledOutput(
                    baybayin: 'ᜃᜓᜇ᜔ᜎᜒᜆ᜔ ᜋᜑᜊᜅ᜔ ᜑᜎᜒᜋ᜔ᜊᜏ ᜉᜇᜒᜈ᜔ ᜉᜇᜒᜈ᜔',
                    latin:
                        'Kudlit long translation preview that should wrap cleanly.',
                    copyLabel: 'Copy',
                    shareLabel: 'Share',
                    onCopy: () {},
                    onShare: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Kudlit long translation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('output actions wrap on compact mobile widths', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: SizedBox(width: 180, child: OutputActions())),
          ),
        ),
      ),
    );

    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('translate text mode keeps input actions usable in landscape', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(593, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TranslateTextModePanel(
              state: const TranslateTextState.initial().copyWith(
                inputText: 'kumusta',
                baybayinText: 'ᜃᜓᜋᜓᜐ᜔ᜆ',
                latinText: 'kumusta',
              ),
              inputEnabled: true,
              disabledReason: null,
              onDirectionChanged: (_) {},
              onInputChanged: (_) {},
              onClear: () {},
              onExplain: () {},
              onCheckInput: () {},
              onCopy: () {},
              onShare: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Explain'), findsOneWidget);
    expect(find.text('Check Input'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filipino input renders as a taller text area', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TranslateTextModePanel(
              state: const TranslateTextState.initial(),
              inputEnabled: true,
              disabledReason: null,
              onDirectionChanged: (_) {},
              onInputChanged: (_) {},
              onClear: () {},
              onExplain: () {},
              onCheckInput: () {},
              onCopy: () {},
              onShare: () {},
            ),
          ),
        ),
      ),
    );

    final Finder filipinoInput = find.byKey(
      const ValueKey<String>('translate-filipino-input'),
    );

    expect(filipinoInput, findsOneWidget);
    expect(tester.getSize(filipinoInput).height, greaterThanOrEqualTo(120));
    expect(tester.takeException(), isNull);
  });

  testWidgets('baybayin unicode reverse input renders as a taller text area', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TranslateTextModePanel(
              state: const TranslateTextState.initial().copyWith(
                latinToBaybayin: false,
              ),
              inputEnabled: true,
              disabledReason: null,
              onDirectionChanged: (_) {},
              onInputChanged: (_) {},
              onClear: () {},
              onExplain: () {},
              onCheckInput: () {},
              onCopy: () {},
              onShare: () {},
            ),
          ),
        ),
      ),
    );

    final Finder unicodeInput = find.byKey(
      const ValueKey<String>('translate-baybayin-unicode-input'),
    );

    expect(unicodeInput, findsOneWidget);
    expect(tester.getSize(unicodeInput).height, greaterThanOrEqualTo(120));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'translate screen keeps input visible in landscape route height',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(844, 390));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: TranslateScreen())),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('translate-filipino-input')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'translate screen does not overflow with portrait keyboard inset',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      tester.view.viewInsets = const FakeViewPadding(bottom: 420);
      addTearDown(() {
        tester.view.resetViewInsets();
        tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: TranslateScreen())),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('translate-filipino-input')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'translate screen does not overflow with landscape keyboard inset',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(844, 390));
      tester.view.viewInsets = const FakeViewPadding(bottom: 180);
      addTearDown(() {
        tester.view.resetViewInsets();
        tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: TranslateScreen())),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('translate-filipino-input')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'translate screen does not overflow when keyboard is open and actions appear',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      tester.view.viewInsets = const FakeViewPadding(bottom: 420);
      addTearDown(() {
        tester.view.resetViewInsets();
        tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: TranslateScreen())),
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('translate-filipino-input')),
        'kumusta',
      );
      await tester.pump();

      expect(find.text('Explain'), findsOneWidget);
      expect(find.text('Check Input'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'home translate layout does not overflow when keyboard opens actions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(() {
        tester.view.resetViewInsets();
        tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            builder: _largeTextBuilder,
            home: Scaffold(
              body: Column(
                children: <Widget>[
                  AppHeader(),
                  Expanded(child: TranslateScreen()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('translate-filipino-input')),
        'kumusta',
      );
      await tester.pump();

      expect(find.text('Explain'), findsOneWidget);
      expect(find.text('Check Input'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _largeTextBuilder(BuildContext context, Widget? child) {
  return MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: const TextScaler.linear(1.35)),
    child: child ?? const SizedBox.shrink(),
  );
}
