import 'package:flutter/material.dart';

import '../../../../app/navigation/main_nav_shell.dart';
import '../models/intro_slide_content.dart';
import '../widgets/intro_actions.dart';
import '../widgets/intro_pager.dart';
import '../widgets/intro_progress.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _handleNext() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleStart() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const MainNavShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == introSlides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: IntroPager(
                controller: _controller,
                onPageChanged: _handlePageChanged,
              ),
            ),
            IntroProgress(
              currentPage: _currentPage,
              totalPages: introSlides.length,
            ),
            IntroActions(
              isLastPage: isLastPage,
              onNext: _handleNext,
              onStart: _handleStart,
            ),
          ],
        ),
      ),
    );
  }
}
