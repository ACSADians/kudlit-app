import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/learning/domain/entities/glyph_entry.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/baybayin_glyph_mark.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/stroke_order_sheet.dart';

class GlyphDetailSheet extends StatelessWidget {
  const GlyphDetailSheet({super.key, required this.entry});

  final GlyphEntry entry;

  @override
  Widget build(BuildContext context) {
    final strokeOrder = entry.strokeOrder;
    if (strokeOrder != null && !strokeOrder.isEmpty) {
      return StrokeOrderSheet(
        glyph: entry.glyph,
        label: entry.label,
        data: strokeOrder,
      );
    }
    return _GlyphInfoSheet(entry: entry);
  }
}

class _GlyphInfoSheet extends StatelessWidget {
  const _GlyphInfoSheet({required this.entry});

  final GlyphEntry entry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final EdgeInsets safeArea = MediaQuery.paddingOf(context);
    return Semantics(
      namesRoute: true,
      label: '${entry.label} glyph details. Stroke order not recorded.',
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 12, 20, safeArea.bottom + 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entry.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Close glyph details',
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Center(
                        child: ExcludeSemantics(
                          child: BaybayinGlyphMark(
                            glyph: entry.glyph,
                            size: 92,
                            color: cs.onSurface,
                            boxSize: 124,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.group == 'Kudlit' ? 'Kudlit marks' : entry.group,
                      textAlign: TextAlign.center,
                      style: text.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.64),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Stroke order not yet recorded.',
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
