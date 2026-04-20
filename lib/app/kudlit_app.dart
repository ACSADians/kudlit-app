import 'package:flutter/material.dart';

import '../features/intro/presentation/screens/intro_screen.dart';
import 'theme/app_theme.dart';

class KudlitApp extends StatelessWidget {
  const KudlitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kudlit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const IntroScreen(),
    );
  }
}
