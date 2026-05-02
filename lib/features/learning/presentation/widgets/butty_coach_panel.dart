import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';

/// Bottom Butty coach bar.
///
/// Layout (matches the design sketch):
/// - Butty illustration sits on the left as a chunky character.
/// - Speech text ("Butty" name + message + Ask Butty link) flows to his right.
/// - A small circular "OK / Continue" button floats at the top-right corner
///   of the bar — only enabled when the current step is satisfied.
class ButtyCoachPanel extends StatelessWidget {
  const ButtyCoachPanel({
    super.key,
    required this.message,
    required this.attemptStatus,
    required this.completed,
    required this.onAvatarTap,
    required this.onContinue,
    required this.onAskHelp,
  });

  final String message;
  final AttemptStatus attemptStatus;
  final bool completed;
  final VoidCallback onAvatarTap;
  final VoidCallback onContinue;
  final VoidCallback onAskHelp;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 40, 12, 14),
          child: _BarStack(
            attemptStatus: attemptStatus,
            completed: completed,
            message: message,
            onAvatarTap: onAvatarTap,
            onAskHelp: onAskHelp,
            onContinue: onContinue,
          ),
        ),
      ),
    );
  }
}

class _BarStack extends StatelessWidget {
  const _BarStack({
    required this.attemptStatus,
    required this.completed,
    required this.message,
    required this.onAvatarTap,
    required this.onAskHelp,
    required this.onContinue,
  });

  final AttemptStatus attemptStatus;
  final bool completed;
  final String message;
  final VoidCallback onAvatarTap;
  final VoidCallback onAskHelp;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color barColor = _statusSurface(cs, attemptStatus);
    final Color barBorder = _statusBorder(cs, attemptStatus);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: double.infinity,
          // left padding reserves space for the Butty illustration
          padding: const EdgeInsets.fromLTRB(96, 14, 56, 14),
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: barBorder),
          ),
          child: _CoachText(message: message, onAskHelp: onAskHelp),
        ),
        // Butty sits at the bottom-left, overflowing above the card top
        Positioned(
          left: 4,
          bottom: 0,
          child: _ButtySticker(onTap: onAvatarTap),
        ),
        Positioned(
          top: -14,
          right: -2,
          child: _OkButton(
            completed: completed,
            attemptStatus: attemptStatus,
            onTap: onContinue,
          ),
        ),
      ],
    );
  }

  Color _statusSurface(ColorScheme cs, AttemptStatus status) {
    switch (status) {
      case AttemptStatus.correct:
        return cs.primaryContainer;
      case AttemptStatus.retry:
        return cs.errorContainer;
      case AttemptStatus.checking:
      case AttemptStatus.idle:
        return cs.surfaceContainerLow;
    }
  }

  Color _statusBorder(ColorScheme cs, AttemptStatus status) {
    switch (status) {
      case AttemptStatus.correct:
        return cs.primary.withValues(alpha: 0.4);
      case AttemptStatus.retry:
        return cs.error.withValues(alpha: 0.4);
      case AttemptStatus.checking:
      case AttemptStatus.idle:
        return cs.outlineVariant;
    }
  }
}

class _ButtySticker extends StatelessWidget {
  const _ButtySticker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tap Butty for help',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(48),
        child: SizedBox(
          width: 88,
          height: 112,
          child: Image.asset(
            'assets/brand/ButtyWave.webp',
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _CoachText extends StatelessWidget {
  const _CoachText({required this.message, required this.onAskHelp});

  final String message;
  final VoidCallback onAskHelp;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Butty',
          style: text.labelSmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onAskHelp,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.help_outline_rounded, size: 14, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  'Ask Butty',
                  style: text.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OkButton extends StatelessWidget {
  const _OkButton({
    required this.completed,
    required this.attemptStatus,
    required this.onTap,
  });

  final bool completed;
  final AttemptStatus attemptStatus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isChecking = attemptStatus == AttemptStatus.checking;
    return Material(
      color: isChecking ? cs.primary.withValues(alpha: 0.6) : cs.primary,
      shape: CircleBorder(side: BorderSide(color: cs.surface, width: 3)),
      elevation: 4,
      child: InkWell(
        onTap: isChecking ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: isChecking
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: cs.onPrimary,
                  ),
                )
              : Icon(
                  completed ? Icons.flag_rounded : Icons.play_arrow_rounded,
                  color: cs.onPrimary,
                ),
        ),
      ),
    );
  }
}
