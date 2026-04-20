import 'package:flutter_test/flutter_test.dart';

import 'package:kudlit_ph/app/kudlit_app.dart';

void main() {
  testWidgets('Intro flow shows Kudlit details', (WidgetTester tester) async {
    await tester.pumpWidget(const KudlitApp());

    expect(find.text('What is Kudlit?'), findsOneWidget);
    expect(find.textContaining('small mark'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Scan Baybayin'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start scanning'));
    await tester.pumpAndSettle();

    expect(find.text('Camera detection will open here.'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

    expect(
      find.text('Character lessons and kudlit practice will open here.'),
      findsOneWidget,
    );
  });
}
