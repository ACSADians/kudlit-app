import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson.dart';

abstract interface class LessonRepository {
  Future<Either<Failure, Lesson>> loadLesson(String lessonId);
}
