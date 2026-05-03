// ignore: unnecessary_import — flutter_riverpod is needed for Ref resolution
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/features/learning/data/datasources/asset_lesson_data_source.dart';
import 'package:kudlit_ph/features/learning/data/repositories/lesson_repository_impl.dart';
import 'package:kudlit_ph/features/learning/domain/repositories/lesson_repository.dart';
import 'package:kudlit_ph/features/learning/domain/usecases/load_lesson.dart';

part 'lesson_repository_provider.g.dart';

@Riverpod(keepAlive: true)
LessonDataSource lessonDataSource(Ref ref) {
  return const AssetLessonDataSource();
}

@Riverpod(keepAlive: true)
LessonRepository lessonRepository(Ref ref) {
  final LessonDataSource ds = ref.watch(lessonDataSourceProvider);
  return LessonRepositoryImpl(ds);
}

@Riverpod(keepAlive: true)
LoadLesson loadLessonUseCase(Ref ref) {
  final LessonRepository repo = ref.watch(lessonRepositoryProvider);
  return LoadLesson(repo);
}
