import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/admin/data/datasources/supabase_stroke_pattern_datasource.dart';
import 'package:kudlit_ph/features/admin/domain/entities/stroke_pattern.dart';
import 'package:kudlit_ph/features/admin/domain/repositories/stroke_pattern_repository.dart';

class StrokePatternRepositoryImpl implements StrokePatternRepository {
  const StrokePatternRepositoryImpl({required SupabaseStrokePatternDatasource datasource})
      : _datasource = datasource;

  final SupabaseStrokePatternDatasource _datasource;

  @override
  Future<Either<Failure, StrokePattern>> save(StrokePattern pattern) async {
    try {
      final StrokePattern saved = await _datasource.save(pattern);
      return right(saved);
    } on ServerException catch (e) {
      return left(Failure.network(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<StrokePattern>>> fetchByGlyph(String glyph) async {
    try {
      final List<StrokePattern> patterns =
          await _datasource.fetchByGlyph(glyph);
      return right(patterns);
    } on ServerException catch (e) {
      return left(Failure.network(message: e.message));
    }
  }
}
