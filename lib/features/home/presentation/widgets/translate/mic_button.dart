import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  const MicButton({super.key, required this.listening, required this.onTap});

  final bool listening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: listening ? cs.error : cs.surfaceContainer,
          border: Border.all(
            color: listening ? cs.error.withAlpha(128) : cs.outline,
          ),
          boxShadow: listening
              ? const <BoxShadow>[
                  BoxShadow(color: Color(0x66FF5040), blurRadius: 16),
                ]
              : null,
        ),
        child: Icon(
          Icons.mic_rounded,
          size: 18,
          color: listening ? cs.onError : cs.onSurface.withAlpha(180),
        ),
      ),
    );
  }
}
