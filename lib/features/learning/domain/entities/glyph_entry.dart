import 'package:meta/meta.dart';

import 'package:kudlit_ph/features/learning/domain/entities/glyph_stroke.dart';

@immutable
class GlyphEntry {
  const GlyphEntry({
    required this.glyph,
    required this.label,
    required this.group,
    this.strokeOrder,
  });

  final String glyph;
  final String label;
  final String group;
  final StrokeOrderData? strokeOrder;
}
