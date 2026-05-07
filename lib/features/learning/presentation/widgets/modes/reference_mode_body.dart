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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact =
            constraints.maxHeight < 360 ||
            constraints.maxWidth > constraints.maxHeight;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, compact ? 8 : 12, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: ReferenceGlyphCard(
                      glyph: step.glyph,
                      glyphImage: step.glyphImage,
                      label: step.label,
                      hideGlyph: step.hideGlyph,
                      compact: compact,
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 16),
                  if (step.narration != null)
                    Text(
                      step.narration!,
                      textAlign: TextAlign.center,
                      maxLines: compact ? 3 : 5,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                    ),
                  SizedBox(height: compact ? 12 : 18),
                  OutlinedButton.icon(
                    onPressed:
                        (step.strokeOrder == null || step.strokeOrder!.isEmpty)
                        ? null
                        : () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => StrokeOrderSheet(
                              glyph: step.glyph,
                              label: step.label,
                              data: step.strokeOrder!,
                            ),
                          ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      (step.strokeOrder == null || step.strokeOrder!.isEmpty)
                          ? 'Stroke order not recorded'
                          : 'Show stroke order',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
