import 'package:flutter/services.dart' show PlatformException;
import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/learning/data/datasources/asset_lesson_data_source.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson.dart';
import 'package:kudlit_ph/features/learning/domain/repositories/lesson_repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  const LessonRepositoryImpl(this._dataSource);

  final LessonDataSource _dataSource;

  @override
  Future<Either<Failure, Lesson>> loadLesson(String lessonId) async {
    try {
      final Lesson lesson = await _dataSource.loadLesson(lessonId);
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
}
