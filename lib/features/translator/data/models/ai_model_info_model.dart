import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';

class AiModelInfoModel extends AiModelInfo {
  const AiModelInfoModel({
    required super.id,
    required super.name,
    required super.modelLink,
    required super.sortOrder,
    required super.version,
    required super.enabled,
    super.modelType = ModelKind.llm,
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
      version: (json['version'] as num?)?.toInt() ?? 1,
      enabled: json['enabled'] as bool? ?? true,
      modelType: _parseKind(json['model_type'] as String?),
      description: json['description'] as String?,
      androidModelLink: json['android_model_link'] as String?,
      iosModelLink: json['ios_model_link'] as String?,
    );
  }

  static ModelKind _parseKind(String? value) =>
      value == 'vision' ? ModelKind.vision : ModelKind.llm;
}
