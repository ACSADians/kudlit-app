import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/forgot_password_link.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/sign_in_form.dart';

void main() {
  testWidgets('shows local validation before submitting email sign in', (
    WidgetTester tester,
  ) async {
    int submitCount = 0;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    addTearDown(emailController.dispose);
    addTearDown(passwordController.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SignInForm(
              formKey: formKey,
              emailController: emailController,
              passwordController: passwordController,
              isLoading: false,
              errorMessage: null,
              onSubmit: () {
                if (formKey.currentState?.validate() ?? false) {
                  submitCount++;
                }
              },
              onForgotPassword: () {},
              onContinueWithPhone: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text(AppConstants.emailRequiredMessage), findsOneWidget);
    expect(find.text(AppConstants.passwordRequiredMessage), findsOneWidget);
    expect(submitCount, 0);
  });

  testWidgets('rejects malformed email before sign in submit', (
    WidgetTester tester,
  ) async {
    int submitCount = 0;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController(
      text: 'bad',
    );
    final TextEditingController passwordController = TextEditingController(
      text: '123456',
    );
    addTearDown(emailController.dispose);
    addTearDown(passwordController.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SignInForm(
              formKey: formKey,
              emailController: emailController,
              passwordController: passwordController,
              isLoading: false,
              errorMessage: null,
              onSubmit: () {
                if (formKey.currentState?.validate() ?? false) {
                  submitCount++;
                }
              },
              onForgotPassword: () {},
              onContinueWithPhone: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text(AppConstants.invalidEmailMessage), findsOneWidget);
    expect(submitCount, 0);
  });

  testWidgets('shows remember and recovery controls with tap targets', (
    WidgetTester tester,
  ) async {
    int phoneTaps = 0;
    int forgotTaps = 0;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    addTearDown(emailController.dispose);
    addTearDown(passwordController.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SignInForm(
              formKey: formKey,
              emailController: emailController,
              passwordController: passwordController,
              isLoading: false,
              errorMessage: null,
              onSubmit: () {},
              onForgotPassword: () => forgotTaps++,
              onContinueWithPhone: () => phoneTaps++,
            ),
          ),
        ),
      ),
    );

    final Finder phoneButton = find.widgetWithText(
      TextButton,
      'Continue with Phone Number',
    );
    final Finder forgotButton = find.descendant(
      of: find.byType(ForgotPasswordLink),
      matching: find.byType(TextButton),
    );
    final Finder rememberToggle = find.text('Remember me');

    expect(phoneButton, findsOneWidget);
    expect(forgotButton, findsOneWidget);
    expect(rememberToggle, findsOneWidget);
    expect(tester.getSize(phoneButton).height, greaterThanOrEqualTo(44));
    expect(tester.getSize(forgotButton).height, greaterThanOrEqualTo(44));
    expect(
      tester
          .getSize(
            find.ancestor(of: rememberToggle, matching: find.byType(InkWell)),
          )
          .height,
      greaterThanOrEqualTo(44),
    );

    final double rememberLeft = tester.getTopLeft(rememberToggle).dx;
    final double forgotLeft = tester.getTopLeft(forgotButton).dx;
    final double phoneTop = tester.getTopLeft(phoneButton).dy;
    final double forgotTop = tester.getTopLeft(forgotButton).dy;
    expect(rememberLeft, lessThan(forgotLeft));
    expect(phoneTop, greaterThan(forgotTop));

    await tester.tap(rememberToggle);
    await tester.tap(phoneButton);
    await tester.tap(forgotButton);
    await tester.pump();

    expect(phoneTaps, 1);
    expect(forgotTaps, 1);
    expect(tester.takeException(), isNull);
  });
}
