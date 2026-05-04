import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/admin/domain/entities/stroke_pattern.dart';

abstract interface class StrokePatternRepository {
  /// Saves a stroke pattern to the remote store.
  Future<Either<Failure, StrokePattern>> save(StrokePattern pattern);

  /// Fetches all patterns for a given [glyph], ordered newest-first.
  Future<Either<Failure, List<StrokePattern>>> fetchByGlyph(String glyph);
}
