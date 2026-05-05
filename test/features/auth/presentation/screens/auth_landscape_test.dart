import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/login_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/phone_sign_in_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/sign_up_screen.dart';

void main() {
  Future<void> pumpLandscape(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: screen)));
    await tester.pump();
  }

  testWidgets('welcome auth screen fits phone landscape', (tester) async {
    await pumpLandscape(tester, const LoginScreen());

    expect(find.text('Welcome, ka-Baybayin!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('email sign-in screen fits phone landscape', (tester) async {
    await pumpLandscape(tester, const SignInScreen());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-up screen fits phone landscape', (tester) async {
    await pumpLandscape(tester, const SignUpScreen());

    expect(find.text('Create account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone sign-in screen fits phone landscape', (tester) async {
    await pumpLandscape(tester, const PhoneSignInScreen());

    expect(find.text('Sign in with phone'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('forgot password screen fits phone landscape', (tester) async {
    await pumpLandscape(tester, const ForgotPasswordScreen());

    expect(find.text('Reset Password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset password screen fits phone landscape', (tester) async {
    await pumpLandscape(tester, const ResetPasswordScreen());

    expect(find.text('Reset password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
