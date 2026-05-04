import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/reference_glyph_card.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/stroke_order_sheet.dart';

class ReferenceModeBody extends StatelessWidget {
  const ReferenceModeBody({
    super.key,
    required this.step,
    required this.attemptStatus,
  });

  final LessonStep step;
  final AttemptStatus attemptStatus;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(),
          Center(
            child: ReferenceGlyphCard(
              glyph: step.glyph,
              glyphImage: step.glyphImage,
              label: step.label,
              hideGlyph: step.hideGlyph,
            ),
          ),
          const SizedBox(height: 24),
          if (step.narration != null)
            Text(
              step.narration!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.8),
                height: 1.45,
              ),
            ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: step.strokeOrder.isEmpty
                ? null
                : () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => StrokeOrderSheet(
                        glyph: step.glyph,
                        label: step.label,
                        strokes: step.strokeOrder,
                      ),
                    ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              step.strokeOrder.isEmpty
                  ? 'Stroke order (no recording yet)'
                  : 'Show stroke order',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: BorderSide(color: cs.outlineVariant),
            ),
          ),
        ],
      ),
    );
  }
}
