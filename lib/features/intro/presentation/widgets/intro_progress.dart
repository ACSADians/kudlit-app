import 'package:flutter/material.dart';

class IntroProgress extends StatelessWidget {
  const IntroProgress({
    required this.currentPage,
    required this.totalPages,
    super.key,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Intro page ${currentPage + 1} of $totalPages',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (int index = 0; index < totalPages; index += 1)
            IntroProgressDot(isActive: index == currentPage),
        ],
      ),
    );
  }
}

class IntroProgressDot extends StatelessWidget {
  const IntroProgressDot({required this.isActive, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
