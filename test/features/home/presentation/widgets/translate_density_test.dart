import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_text_controller.dart';
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
}
