import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_input_bar.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/suggested_questions_row.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/output_action_pill.dart';

void main() {
  testWidgets('Butty suggestion chips keep 44px tap targets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SuggestedQuestionsRow(onTap: (_) {})),
      ),
    );

    final Rect firstChip = tester.getRect(find.byType(InkWell).first);

    expect(firstChip.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Butty chat send action keeps 44px tap target', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final TextEditingController controller = TextEditingController(text: 'hi');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              controller: controller,
              responding: false,
              enabled: true,
              onSend: () {},
            ),
          ),
        ),
      ),
    );

    final Rect sendAction = tester.getRect(find.byType(InkWell).last);

    expect(sendAction.width, greaterThanOrEqualTo(44));
    expect(sendAction.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });

  testWidgets('translate output action pill keeps 44px tap target', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: OutputActionPill(
              icon: Icons.copy_rounded,
              label: 'Copy',
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    final Rect pill = tester.getRect(find.byType(OutputActionPill));

    expect(pill.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });
}
