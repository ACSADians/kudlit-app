import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kudlit_ph/app/router/router_listenable.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/home_screen.dart';
import 'package:kudlit_ph/features/auth/presentation/screens/login_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final RouterListenable listenable = ref.watch(routerListenableProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: listenable,
    redirect: (BuildContext context, GoRouterState state) {
      final AsyncValue<AuthUser?> authState = listenable.authState;

      // Still loading — don't redirect
      if (authState.isLoading) return null;

      final bool isAuthenticated =
          authState.hasValue && authState.value != null;
      final bool isOnAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/auth/reset';

      if (!isAuthenticated && !isOnAuthRoute) return '/login';
      if (isAuthenticated && isOnAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: '/auth/reset',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
    ],
  );
}
