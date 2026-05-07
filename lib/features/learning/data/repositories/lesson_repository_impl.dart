import 'package:flutter/services.dart' show PlatformException;
import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/learning/data/datasources/asset_lesson_data_source.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson.dart';
import 'package:kudlit_ph/features/learning/domain/repositories/lesson_repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  const LessonRepositoryImpl(this._dataSource, {LessonDataSource? fallback})
    : _fallback = fallback;

  final LessonDataSource _dataSource;

  /// Optional secondary datasource tried when [_dataSource] throws.
  final LessonDataSource? _fallback;

  @override
  Future<Either<Failure, Lesson>> loadLesson(String lessonId) async {
    try {
      final Lesson lesson = await _dataSource.loadLesson(lessonId);
      return Right<Failure, Lesson>(lesson);
    } catch (_) {
      // Primary failed — try fallback if available.
      final LessonDataSource? fallback = _fallback;
      if (fallback != null) {
        try {
          final Lesson lesson = await fallback.loadLesson(lessonId);
          return Right<Failure, Lesson>(lesson);
        } on PlatformException catch (e) {
          return Left<Failure, Lesson>(
            Failure.unknown(message: 'Lesson not found: ${e.message}'),
          );
        } catch (e) {
          return Left<Failure, Lesson>(
            Failure.unknown(message: 'Failed to load lesson: $e'),
          );
        }
      }
      return Left<Failure, Lesson>(
        const Failure.unknown(
          message: 'Failed to load lesson from all sources.',
        ),
      );
    }
  }
}
