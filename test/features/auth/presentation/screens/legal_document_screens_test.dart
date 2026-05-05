import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/privacy_policy_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/terms_screen.dart';

void main() {
  GoRouter buildRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(
          path: AppConstants.routeLogin,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('Login route'))),
        ),
        GoRoute(
          path: AppConstants.routeTerms,
          builder: (BuildContext context, GoRouterState state) =>
              const TermsScreen(),
        ),
        GoRoute(
          path: AppConstants.routePrivacyPolicy,
          builder: (BuildContext context, GoRouterState state) =>
              const PrivacyPolicyScreen(),
        ),
      ],
    );
  }

  Future<void> pumpLegalRoute(WidgetTester tester, GoRouter router) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('terms screen is structured and direct back returns to login', (
    WidgetTester tester,
  ) async {
    final GoRouter router = buildRouter(AppConstants.routeTerms);

    await pumpLegalRoute(tester, router);

    expect(find.text('Terms of Service'), findsWidgets);
    expect(find.text('Quick read'), findsOneWidget);
    expect(find.text('Learning, scanner, and AI results'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Login route'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppConstants.routeLogin,
    );
  });

  testWidgets('privacy screen links to terms without overflowing', (
    WidgetTester tester,
  ) async {
    final GoRouter router = buildRouter(AppConstants.routePrivacyPolicy);

    await pumpLegalRoute(tester, router);

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('Privacy summary'), findsOneWidget);
    expect(
      find.text('AI, translation, and scanner processing'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Read Terms of Service'),
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Read Terms of Service'));
    await tester.pumpAndSettle();

    expect(find.text('Quick read'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppConstants.routeTerms,
    );
  });
}
