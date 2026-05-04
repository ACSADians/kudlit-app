import 'package:flutter/material.dart';

class QuizResultCard extends StatelessWidget {
  const QuizResultCard({
    super.key,
    required this.score,
    required this.total,
    required this.onRetry,
    required this.onDone,
  });

  final int score;
  final int total;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final bool perfect = score == total;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ScoreBadge(score: score, total: total, cs: cs),
            const SizedBox(height: 24),
            Text(
              perfect ? 'Perfect score!' : 'Quiz complete!',
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '$score out of $total correct',
              style: text.bodyLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onDone,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({
    required this.score,
    required this.total,
    required this.cs,
  });

  final int score;
  final int total;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final bool perfect = score == total;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: perfect ? cs.primaryContainer : cs.secondaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$score',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1,
              color: perfect ? cs.onPrimaryContainer : cs.onSecondaryContainer,
            ),
          ),
          Text(
            '/ $total',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: (perfect ? cs.onPrimaryContainer : cs.onSecondaryContainer)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
