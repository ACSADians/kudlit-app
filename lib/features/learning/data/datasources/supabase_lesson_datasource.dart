import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/features/learning/data/datasources/asset_lesson_data_source.dart';
import 'package:kudlit_ph/features/learning/data/models/lesson_model.dart';
import 'package:kudlit_ph/features/learning/data/models/lesson_step_model.dart';
import 'package:kudlit_ph/features/learning/domain/entities/glyph_stroke.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_mode.dart';

class SupabaseLessonDatasource implements LessonDataSource {
  const SupabaseLessonDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<LessonModel> loadLesson(String lessonId) async {
    final Map<String, dynamic> lessonRow = await _client
        .from('lessons')
        .select()
        .eq('id', lessonId)
        .eq('published', true)
        .single();

    final List<Map<String, dynamic>> stepRows = await _client
        .from('lesson_steps')
        .select()
        .eq('lesson_id', lessonId)
        .order('sort_order');

    // Build preliminary steps (no stroke order yet).
    final List<LessonStepModel> rawSteps = stepRows
        .map(_stepFromRow)
        .toList(growable: false);

    // Batch-fetch stroke patterns for all unique glyphs in one query.
    // We pick the most recently recorded pattern per glyph.
    final List<String> uniqueGlyphs =
        rawSteps.map((LessonStepModel s) => s.glyph).toSet().toList();

    final Map<String, StrokeOrderData> strokeOrderByGlyph =
        await _fetchStrokeOrderByGlyph(uniqueGlyphs);

    final List<LessonStepModel> steps = rawSteps
        .map(
          (LessonStepModel s) => strokeOrderByGlyph.containsKey(s.glyph)
              ? s.withStrokeOrder(strokeOrderByGlyph[s.glyph]!)
              : s,
        )
        .toList(growable: false);

    return LessonModel(
      id: lessonRow['id'] as String,
      title: lessonRow['title'] as String,
      subtitle: (lessonRow['subtitle'] as String?) ?? '',
      steps: steps,
    );
  }

  /// Queries [stroke_patterns] for all [glyphs] in a single request.
  /// Returns the most recently recorded [StrokeOrderData] per glyph.
  Future<Map<String, StrokeOrderData>> _fetchStrokeOrderByGlyph(
    List<String> glyphs,
  ) async {
    if (glyphs.isEmpty) return const <String, StrokeOrderData>{};
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from('stroke_patterns')
          .select('glyph, strokes, canvas_width, canvas_height')
          .inFilter('glyph', glyphs)
          .order('created_at', ascending: false);

      // Keep only the first (most recent) pattern per glyph.
      final Map<String, StrokeOrderData> result = <String, StrokeOrderData>{};
      for (final Map<String, dynamic> row in rows) {
        final String glyph = row['glyph'] as String;
        if (result.containsKey(glyph)) continue;
        final double w = (row['canvas_width'] as num?)?.toDouble() ?? 1.0;
        final double h = (row['canvas_height'] as num?)?.toDouble() ?? 1.0;
        final double aspect = (w > 0 && h > 0) ? w / h : 1.0;
        final List<dynamic> rawStrokes =
            (row['strokes'] as List<dynamic>?) ?? const <dynamic>[];
        final List<GlyphStroke> strokes = rawStrokes
            .cast<Map<String, dynamic>>()
            .map(GlyphStroke.fromJson)
            .toList(growable: false);
        result[glyph] = StrokeOrderData(strokes: strokes, aspectRatio: aspect);
      }
      return result;
    } catch (_) {
      // Non-fatal — lesson still loads, just without stroke order.
      return const <String, StrokeOrderData>{};
    }
  }

  LessonStepModel _stepFromRow(Map<String, dynamic> row) {
    final List<dynamic> rawExpected =
        (row['expected'] as List<dynamic>?) ?? const <dynamic>[];
    return LessonStepModel(
      id: row['id'] as String,
      mode: LessonMode.fromJson(row['mode'] as String),
      label: (row['label'] as String?) ?? '',
      glyph: row['glyph'] as String,
      glyphImage: row['glyph_image'] as String?,
      intro: row['intro'] as String?,
      prompt: row['prompt'] as String?,
      narration: row['narration'] as String?,
      hint: row['hint'] as String?,
      successFeedback: row['success_feedback'] as String?,
      buttyTip: row['butty_tip'] as String?,
      expected: rawExpected
          .map((dynamic e) => (e as String).trim().toLowerCase())
          .toList(growable: false),
      hideGlyph: (row['hide_glyph'] as bool?) ?? false,
    );
  }
}
