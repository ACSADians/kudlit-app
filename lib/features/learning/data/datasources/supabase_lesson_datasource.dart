import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/features/learning/data/datasources/asset_lesson_data_source.dart';
import 'package:kudlit_ph/features/learning/data/models/lesson_model.dart';
import 'package:kudlit_ph/features/learning/data/models/lesson_step_model.dart';
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

    final List<LessonStepModel> steps = stepRows
        .map(_stepFromRow)
        .toList(growable: false);

    return LessonModel(
      id: lessonRow['id'] as String,
      title: lessonRow['title'] as String,
      subtitle: (lessonRow['subtitle'] as String?) ?? '',
      steps: steps,
    );
  }

  LessonStepModel _stepFromRow(Map<String, dynamic> row) {
    final List<dynamic> rawExpected =
        (row['expected'] as List<dynamic>?) ?? const <dynamic>[];
    return LessonStepModel(
      id: row['id'] as String,
      mode: LessonMode.fromJson(row['mode'] as String),
      label: (row['label'] as String?) ?? '',
      glyph: row['glyph'] as String,
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
