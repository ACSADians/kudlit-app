import 'package:kudlit_ph/features/learning/data/models/lesson_step_model.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson.dart';

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.steps,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSteps = json['steps'] as List<dynamic>;
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: (json['subtitle'] as String?) ?? '',
      steps: rawSteps
          .map(
            (dynamic step) =>
                LessonStepModel.fromJson(step as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}
