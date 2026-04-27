import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/translator/data/models/ai_model_info_model.dart';

abstract interface class SupabaseAiModelsDatasource {
  Future<List<AiModelInfoModel>> fetchModels();
}

class SupabaseAiModelsDatasourceImpl implements SupabaseAiModelsDatasource {
  const SupabaseAiModelsDatasourceImpl(this._client);

  final SupabaseClient _client;

  static const String _table = 'baybayin_models';

  @override
  Future<List<AiModelInfoModel>> fetchModels() async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from(_table)
          .select()
          .order('sort_order', ascending: true);
      return rows.map(AiModelInfoModel.fromJson).toList(growable: false);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: 500);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
