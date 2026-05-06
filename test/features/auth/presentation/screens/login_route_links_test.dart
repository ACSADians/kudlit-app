import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/login_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/primary_auth_option_button.dart';

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
        GoRoute(
          path: AppConstants.routeHome,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Text('Home route')),
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

  testWidgets('login chooser uses guest as primary and removes phone option', (
    tester,
  ) async {
    final GoRouter router = await pumpLogin(tester);

    expect(
      find.widgetWithText(PrimaryAuthOptionButton, 'Continue as guest'),
      findsOneWidget,
    );
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Continue with Phone Number'), findsNothing);
    expect(find.text('Remember me'), findsNothing);
    expect(find.text(AppConstants.forgotPasswordAction), findsNothing);

    await tester.tap(
      find.widgetWithText(PrimaryAuthOptionButton, 'Continue as guest'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home route'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppConstants.routeHome,
    );
  });

  testWidgets('portrait login hides the decorative mascot and speech bubble', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pump();

    final Finder mascot = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/brand/ButtyWave.webp',
      description: 'Butty mascot image',
    );

    expect(mascot, findsNothing);
    expect(
      find.text('Kumusta! I\'m Butty. Let\'s learn Baybayin together!'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
