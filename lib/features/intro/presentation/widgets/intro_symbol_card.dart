import 'package:flutter/material.dart';

class IntroSymbolCard extends StatelessWidget {
  const IntroSymbolCard({required this.icon, required this.example, super.key});

  final IconData icon;
  final String example;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: <Widget>[
            Icon(icon, color: colorScheme.onSecondaryContainer, size: 56),
            const SizedBox(height: 20),
            Text(
              example,
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
