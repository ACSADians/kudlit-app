import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/app/router/router_listenable.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/home_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/login_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:kudlit_ph/features/home/presentation/screens/settings_screen.dart';
import 'package:kudlit_ph/features/home/presentation/screens/splash_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final RouterListenable listenable = ref.watch(routerListenableProvider);

  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    refreshListenable: listenable,
    redirect: (BuildContext context, GoRouterState state) {
      final AsyncValue<AuthUser?> authState = listenable.authState;
      final bool isAuthenticated =
          authState.hasValue && authState.value != null;

      // Splash: hold while loading, then route to correct destination.
      if (state.matchedLocation == AppConstants.routeSplash) {
        if (authState.isLoading) return null;
        return isAuthenticated
            ? AppConstants.routeHome
            : AppConstants.routeLogin;
      }

      // Still loading auth on other routes — don't redirect.
      if (authState.isLoading) return null;

      final bool isOnAuthRoute =
          state.matchedLocation == AppConstants.routeLogin ||
          state.matchedLocation == AppConstants.routeSignUp ||
          state.matchedLocation == AppConstants.routeForgotPassword ||
          state.matchedLocation == AppConstants.routeAuthReset;

      if (!isAuthenticated &&
          !isOnAuthRoute &&
          state.matchedLocation != AppConstants.routeHome &&
          state.matchedLocation != AppConstants.routeSettings) {
        return AppConstants.routeLogin;
      }
      if (isAuthenticated && isOnAuthRoute) return AppConstants.routeHome;
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSignUp,
        builder: (BuildContext context, GoRouterState state) =>
            const SignUpScreen(),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.routeHome,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAuthReset,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
    ],
  );
}
