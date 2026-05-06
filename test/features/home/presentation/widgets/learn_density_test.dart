import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/home/presentation/screens/learn_home_body.dart';

void main() {
  testWidgets('learn quick actions use compact labels on narrow phones', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LearnHomeBody(
              onStartLesson: (_) {},
              onChatWithButty: () {},
              onOpenGallery: () {},
              onStartQuiz: () {},
              bottomPad: 112,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Glyphs'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
    expect(find.text('All Glyphs'), findsNothing);
    expect(find.text('Quick Quiz'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
