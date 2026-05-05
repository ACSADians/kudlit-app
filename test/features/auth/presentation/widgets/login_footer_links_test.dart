import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_footer_links.dart';

void main() {
  testWidgets('login footer links expose comfortable touch targets', (
    WidgetTester tester,
  ) async {
    var forgotTaps = 0;
    var createTaps = 0;
    var guestTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginFooterLinks(
            onForgotPassword: () => forgotTaps++,
            onCreateAccount: () => createTaps++,
            onContinueAsGuest: () => guestTaps++,
          ),
        ),
      ),
    );

    final Finder forgotButton = find.widgetWithText(
      TextButton,
      'Forgot password?',
    );
    final Finder createButton = find.widgetWithText(
      TextButton,
      'Create an account',
    );
    final Finder guestButton = find.widgetWithText(
      TextButton,
      'Continue as guest',
    );

    expect(tester.getSize(forgotButton).height, greaterThanOrEqualTo(44));
    expect(tester.getSize(createButton).height, greaterThanOrEqualTo(44));
    expect(tester.getSize(guestButton).height, greaterThanOrEqualTo(44));

    await tester.tap(forgotButton);
    await tester.tap(createButton);
    await tester.tap(guestButton);

    expect(forgotTaps, 1);
    expect(createTaps, 1);
    expect(guestTaps, 1);
    expect(tester.takeException(), isNull);
  });
}
