// ignore: unnecessary_import — flutter_riverpod is needed for Ref resolution
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/features/auth/presentation/providers/auth_provider.dart';
import 'package:kudlit_ph/features/learning/data/datasources/asset_lesson_data_source.dart';
import 'package:kudlit_ph/features/learning/data/datasources/supabase_lesson_datasource.dart';
import 'package:kudlit_ph/features/learning/data/repositories/lesson_repository_impl.dart';
import 'package:kudlit_ph/features/learning/domain/repositories/lesson_repository.dart';
import 'package:kudlit_ph/features/learning/domain/usecases/load_lesson.dart';

part 'lesson_repository_provider.g.dart';

/// Supabase-backed datasource. Falls back transparently to [AssetLessonDataSource]
/// in [LessonRepositoryImpl] if the network call fails.
@Riverpod(keepAlive: true)
LessonDataSource lessonDataSource(Ref ref) {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  return SupabaseLessonDatasource(client);
}

@Riverpod(keepAlive: true)
LessonDataSource assetLessonDataSource(Ref ref) {
  return const AssetLessonDataSource();
}

@Riverpod(keepAlive: true)
LessonRepository lessonRepository(Ref ref) {
  final LessonDataSource primary = ref.watch(lessonDataSourceProvider);
  final LessonDataSource fallback = ref.watch(assetLessonDataSourceProvider);
  return LessonRepositoryImpl(primary, fallback: fallback);
}

@Riverpod(keepAlive: true)
LoadLesson loadLessonUseCase(Ref ref) {
  final LessonRepository repo = ref.watch(lessonRepositoryProvider);
  return LoadLesson(repo);
}
