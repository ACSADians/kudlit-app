import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';

class GemmaModelInfoModel extends GemmaModelInfo {
  const GemmaModelInfoModel({
    required super.id,
    required super.name,
    required super.modelLink,
  });

  factory GemmaModelInfoModel.fromJson(Map<String, dynamic> json) {
    return GemmaModelInfoModel(
      id: json['id'] as String,
      name: json['name'] as String,
      modelLink: json['model_link'] as String,
    );
  }
}
