import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/login_screen.dart';

void main() {
  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: AppConstants.routeLogin,
      routes: <RouteBase>[
        GoRoute(
          path: AppConstants.routeLogin,
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
        GoRoute(
          path: AppConstants.routeTerms,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Text('Terms route')),
        ),
        GoRoute(
          path: AppConstants.routePrivacyPolicy,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Text('Privacy route')),
        ),
        GoRoute(
          path: AppConstants.routeForgotPassword,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Text('Forgot route')),
        ),
      ],
    );
  }

  Future<GoRouter> pumpLogin(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final GoRouter router = buildRouter();
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('login terms link updates the route location', (tester) async {
    final GoRouter router = await pumpLogin(tester);

    await tester.tap(find.text('Terms'));
    await tester.pumpAndSettle();

    expect(find.text('Terms route'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppConstants.routeTerms,
    );
  });

  testWidgets('login privacy link updates the route location', (tester) async {
    final GoRouter router = await pumpLogin(tester);

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy route'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppConstants.routePrivacyPolicy,
    );
  });

  testWidgets('login forgot password link updates the route location', (
    tester,
  ) async {
    final GoRouter router = await pumpLogin(tester);

    await tester.tap(find.text(AppConstants.forgotPasswordAction));
    await tester.pumpAndSettle();

    expect(find.text('Forgot route'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppConstants.routeForgotPassword,
    );
  });
}
