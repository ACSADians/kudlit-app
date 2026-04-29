import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson.dart';
import 'package:kudlit_ph/features/learning/domain/repositories/lesson_repository.dart';

class LoadLesson implements UseCase<Lesson, String> {
  const LoadLesson(this._repository);

  final LessonRepository _repository;

  @override
  Future<Either<Failure, Lesson>> call(String params) =>
      _repository.loadLesson(params);
}
