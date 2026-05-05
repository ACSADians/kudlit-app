import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/app/constants.dart';
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
}
