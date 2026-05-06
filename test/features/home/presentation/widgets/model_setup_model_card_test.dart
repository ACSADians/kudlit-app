import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/model_setup_model_card.dart';

void main() {
  testWidgets('model setup card fits narrow landscape column', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: ModelSetupModelCard(modelName: 'Butty Small'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Works offline after download'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('model setup card keeps long model names within phone width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 288,
              child: ModelSetupModelCard(
                modelName: 'Butty Local AI Model Preview',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Butty Local AI Model Preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
