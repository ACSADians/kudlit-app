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
    final bool compact = MediaQuery.sizeOf(context).height < 520;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        compact ? 20 : 32,
        24,
        MediaQuery.paddingOf(context).bottom + (compact ? 20 : 32),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _ScoreBadge(score: score, total: total, cs: cs, compact: compact),
              SizedBox(height: compact ? 16 : 22),
              Text(
                perfect ? 'Perfect score!' : 'Quiz complete!',
                style: text.headlineSmall?.copyWith(
                  fontSize: compact ? 21 : null,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$score out of $total correct',
                style: text.bodyLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: compact ? 24 : 34),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onDone,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
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
    required this.compact,
  });

  final int score;
  final int total;
  final ColorScheme cs;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool perfect = score == total;
    final double size = compact ? 94 : 112;
    return Semantics(
      container: true,
      label: 'Quiz score $score out of $total',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
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
                  fontSize: compact ? 40 : 46,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: perfect
                      ? cs.onPrimaryContainer
                      : cs.onSecondaryContainer,
                ),
              ),
              Text(
                '/ $total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      (perfect
                              ? cs.onPrimaryContainer
                              : cs.onSecondaryContainer)
                          .withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
