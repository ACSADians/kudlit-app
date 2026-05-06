import 'package:flutter/material.dart';

class BeginButton extends StatelessWidget {
  const BeginButton({
    super.key,
    required this.onStart,
    this.isLocked = false,
    this.label = 'Begin Lesson',
    this.lockedReason,
  });

  final VoidCallback onStart;
  final bool isLocked;
  final String label;
  final String? lockedReason;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FilledButton.icon(
            onPressed: isLocked ? null : onStart,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded,
              size: 18,
            ),
            label: Text(isLocked ? 'Locked' : label),
          ),
          if (isLocked && lockedReason != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              lockedReason!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.62),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
