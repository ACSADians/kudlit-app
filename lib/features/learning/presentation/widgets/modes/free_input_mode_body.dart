import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_controller.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/reference_glyph_card.dart';

/// Free input mode: reference glyph + prompt + a single text field.
/// Submitting the field (or pressing OK on the coach panel) validates.
class FreeInputModeBody extends ConsumerStatefulWidget {
  const FreeInputModeBody({
    super.key,
    required this.step,
    required this.attemptStatus,
  });

  final LessonStep step;
  final AttemptStatus attemptStatus;

  @override
  ConsumerState<FreeInputModeBody> createState() => FreeInputModeBodyState();
}

class FreeInputModeBodyState extends ConsumerState<FreeInputModeBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_resetRetryIfNeeded);
  }

  @override
  void didUpdateWidget(covariant FreeInputModeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) _controller.clear();
  }

  @override
  void dispose() {
    _controller.removeListener(_resetRetryIfNeeded);
    _controller.dispose();
    super.dispose();
  }

  void _resetRetryIfNeeded() {
    if (widget.attemptStatus == AttemptStatus.retry) {
      ref.read(lessonControllerProvider.notifier).resetAttempt();
    }
  }

  /// Called by parent (coach OK button). Returns false if empty.
  bool submitToController() {
    final String value = _controller.text;
    if (value.trim().isEmpty) return false;
    ref.read(lessonControllerProvider.notifier).submitText(value);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool locked = widget.attemptStatus == AttemptStatus.correct;
    final Color fieldFill;
    final Color fieldBorder;
    switch (widget.attemptStatus) {
      case AttemptStatus.correct:
        fieldFill = cs.primaryContainer.withValues(alpha: 0.5);
        fieldBorder = cs.primary;
      case AttemptStatus.retry:
        fieldFill = cs.errorContainer.withValues(alpha: 0.5);
        fieldBorder = cs.error;
      case AttemptStatus.checking:
      case AttemptStatus.idle:
        fieldFill = cs.surfaceContainerHigh;
        fieldBorder = Colors.transparent;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact =
            constraints.maxHeight < 360 ||
            constraints.maxWidth > constraints.maxHeight;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, compact ? 8 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: compact ? 8 : 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: ReferenceGlyphCard(
                          glyph: widget.step.glyph,
                          glyphImage: widget.step.glyphImage,
                          label: widget.step.label,
                          hideGlyph: widget.step.hideGlyph,
                          compact: compact,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      Text(
                        widget.step.prompt ?? 'Type the romanization.',
                        maxLines: compact ? 2 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              TextField(
                controller: _controller,
                enabled: !locked,
                autofocus: false,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.none,
                onSubmitted: (_) => submitToController(),
                decoration: InputDecoration(
                  hintText: 'Your answer',
                  filled: true,
                  fillColor: fieldFill,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: compact ? 12 : 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: fieldBorder, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: fieldBorder == Colors.transparent
                          ? cs.primary
                          : fieldBorder,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: fieldBorder, width: 2),
                  ),
                ),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed:
                    locked || widget.attemptStatus == AttemptStatus.checking
                    ? null
                    : submitToController,
                icon: widget.attemptStatus == AttemptStatus.checking
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  widget.attemptStatus == AttemptStatus.checking
                      ? 'Checking'
                      : 'Check answer',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
