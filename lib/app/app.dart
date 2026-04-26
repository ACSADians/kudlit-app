import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/app/router/app_router.dart';
import 'package:kudlit_ph/core/design_system/kudlit_theme.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';

class KudlitApp extends ConsumerWidget {
  const KudlitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeMode themeMode =
        ref.watch(appPreferencesNotifierProvider).valueOrNull?.themeMode ??
        ThemeMode.system;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: KudlitTheme.light,
      darkTheme: KudlitTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
