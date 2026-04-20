import 'package:flutter/material.dart';

class PlaceholderFeatureContent extends StatelessWidget {
  const PlaceholderFeatureContent({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(icon, color: colorScheme.primary, size: 56),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(body, textAlign: TextAlign.center, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
