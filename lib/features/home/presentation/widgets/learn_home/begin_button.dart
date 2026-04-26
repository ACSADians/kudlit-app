import 'package:flutter/material.dart';

class BeginButton extends StatelessWidget {
  const BeginButton({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: GestureDetector(
        onTap: onStart,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Begin Lesson',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
