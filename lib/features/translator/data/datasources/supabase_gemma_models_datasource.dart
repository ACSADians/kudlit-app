import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/translator/data/models/gemma_model_info_model.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';

abstract interface class SupabaseGemmaModelsDatasource {
  Future<List<GemmaModelInfo>> fetchModels();
}

class SupabaseGemmaModelsDatasourceImpl
    implements SupabaseGemmaModelsDatasource {
  const SupabaseGemmaModelsDatasourceImpl(this._client);

  final SupabaseClient _client;

  static const String _table = 'gemma_models';

  @override
  Future<List<GemmaModelInfo>> fetchModels() async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from(_table)
          .select();
      return rows.map(GemmaModelInfoModel.fromJson).toList(growable: false);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: 500);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
