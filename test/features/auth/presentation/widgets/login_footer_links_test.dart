import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_footer_links.dart';

void main() {
  testWidgets('login footer links expose comfortable touch targets', (
    WidgetTester tester,
  ) async {
    var createTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginFooterLinks(onCreateAccount: () => createTaps++),
        ),
      ),
    );

    final Finder createButton = find.widgetWithText(
      TextButton,
      'Create an account',
    );

    expect(tester.getSize(createButton).height, greaterThanOrEqualTo(44));
    expect(find.text('Remember me'), findsNothing);
    expect(find.text('Forgot password?'), findsNothing);
    expect(find.text('Continue as guest'), findsNothing);

    await tester.tap(createButton);

    expect(createTaps, 1);
    expect(tester.takeException(), isNull);
  });
}
