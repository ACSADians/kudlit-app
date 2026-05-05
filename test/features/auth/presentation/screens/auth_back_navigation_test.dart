import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/sign_up_screen.dart';

void main() {
  testWidgets('sign-up hero back returns direct route to login', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: AppConstants.routeSignUp,
      routes: <RouteBase>[
        GoRoute(
          path: AppConstants.routeLogin,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('Login route'))),
        ),
        GoRoute(
          path: AppConstants.routeSignUp,
          builder: (BuildContext context, GoRouterState state) =>
              const SignUpScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Login route'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppConstants.routeLogin,
    );
  });
}
