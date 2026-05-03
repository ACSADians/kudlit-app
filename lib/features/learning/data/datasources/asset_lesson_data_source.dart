import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:kudlit_ph/features/learning/data/models/lesson_model.dart';

abstract interface class LessonDataSource {
  Future<LessonModel> loadLesson(String lessonId);
}

class AssetLessonDataSource implements LessonDataSource {
  const AssetLessonDataSource();

  static const String _basePath = 'assets/lessons';

  @override
  Future<LessonModel> loadLesson(String lessonId) async {
    final String fileName = lessonId.replaceAll('-', '_');
    final String path = '$_basePath/$fileName.json';
    final String raw = await rootBundle.loadString(path);
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return LessonModel.fromJson(json);
  }
}
