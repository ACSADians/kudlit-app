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
}
