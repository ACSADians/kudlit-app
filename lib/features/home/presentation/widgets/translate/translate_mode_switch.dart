import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';

class TranslateModeSwitch extends StatelessWidget {
  const TranslateModeSwitch({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final TranslateWorkspaceMode mode;
  final ValueChanged<TranslateWorkspaceMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ModePill(
            label: 'Text',
            active: mode == TranslateWorkspaceMode.text,
            onTap: () => onChanged(TranslateWorkspaceMode.text),
          ),
          _ModePill(
            label: 'Sketchpad',
            active: mode == TranslateWorkspaceMode.sketchpad,
            onTap: () => onChanged(TranslateWorkspaceMode.sketchpad),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? cs.onPrimary : cs.onSurface.withAlpha(170),
          ),
        ),
      ),
    );
  }
}
