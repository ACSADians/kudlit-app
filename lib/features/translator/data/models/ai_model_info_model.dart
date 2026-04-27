import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';

class AiModelInfoModel extends AiModelInfo {
  const AiModelInfoModel({
    required super.id,
    required super.name,
    required super.modelLink,
    required super.sortOrder,
    super.description,
    super.androidModelLink,
    super.iosModelLink,
  });

  factory AiModelInfoModel.fromJson(Map<String, dynamic> json) {
    return AiModelInfoModel(
      id: json['id'] as String,
      name: json['name'] as String,
      modelLink: json['model_link'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      description: json['description'] as String?,
      androidModelLink: json['android_model_link'] as String?,
      iosModelLink: json['ios_model_link'] as String?,
    );
  }
}
