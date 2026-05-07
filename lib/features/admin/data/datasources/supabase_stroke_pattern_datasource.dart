import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/admin/domain/entities/stroke_pattern.dart';

/// Remote data source for [StrokePattern] backed by Supabase.
class SupabaseStrokePatternDatasource {
  const SupabaseStrokePatternDatasource({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  Future<StrokePattern> save(StrokePattern pattern) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'user_id': pattern.userId,
        'glyph': pattern.glyph,
        'label': pattern.label,
        'strokes': pattern.strokes.map((StrokeData s) => s.toJson()).toList(),
        'canvas_width': pattern.canvasWidth,
        'canvas_height': pattern.canvasHeight,
        'device_info': pattern.deviceInfo,
      };

      final Map<String, dynamic> row = await _client
          .from('stroke_patterns')
          .insert(payload)
          .select()
          .single();

      return _fromRow(row);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<List<StrokePattern>> fetchByGlyph(String glyph) async {
    try {
      final List<dynamic> rows = await _client
          .from('stroke_patterns')
          .select()
          .eq('glyph', glyph)
          .order('created_at', ascending: false);

      return rows.cast<Map<String, dynamic>>().map(_fromRow).toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  StrokePattern _fromRow(Map<String, dynamic> row) {
    final List<dynamic> rawStrokes =
        (row['strokes'] as List<dynamic>?) ?? <dynamic>[];

    final List<StrokeData> strokes = rawStrokes
        .cast<Map<String, dynamic>>()
        .map(StrokeData.fromJson)
        .toList();

    return StrokePattern(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      glyph: row['glyph'] as String,
      label: row['label'] as String,
      strokes: strokes,
      canvasWidth: (row['canvas_width'] as num).toDouble(),
      canvasHeight: (row['canvas_height'] as num).toDouble(),
      deviceInfo:
          (row['device_info'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// Builds the [deviceInfo] map for the current device/platform.
Map<String, dynamic> buildDeviceInfo({
  required double canvasWidth,
  required double canvasHeight,
}) {
  return <String, dynamic>{
    'platform': defaultTargetPlatform.name,
    'canvas_width': canvasWidth,
    'canvas_height': canvasHeight,
  };
}
