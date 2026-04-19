import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/features/splash/presentation/screens/splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
  ],
);
