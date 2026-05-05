import 'package:flutter/material.dart';

class BeginButton extends StatelessWidget {
  const BeginButton({
    super.key,
    required this.onStart,
    this.isLocked = false,
    this.lockedReason,
  });

  final VoidCallback onStart;
  final bool isLocked;
  final String? lockedReason;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FilledButton.icon(
            onPressed: isLocked ? null : onStart,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            icon: Icon(
              isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(isLocked ? 'Locked' : 'Begin Lesson'),
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
