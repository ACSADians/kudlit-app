import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/translator/data/models/ai_model_info_model.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';

abstract interface class SupabaseAiModelsDatasource {
  /// Fetches enabled models ordered by `sort_order ASC`.
  ///
  /// When [type] is provided only rows matching that `model_type` are returned.
  Future<List<AiModelInfoModel>> fetchModels({ModelKind? type});
}

class SupabaseAiModelsDatasourceImpl implements SupabaseAiModelsDatasource {
  const SupabaseAiModelsDatasourceImpl(this._client);

  final SupabaseClient _client;

  static const String _table = 'baybayin_models';

  @override
  Future<List<AiModelInfoModel>> fetchModels({ModelKind? type}) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _client
          .from(_table)
          .select()
          .eq('enabled', true);

      if (type != null) {
        query = query.eq('model_type', type.name);
      }

      final List<Map<String, dynamic>> rows = await query.order(
        'sort_order',
        ascending: true,
      );
      return rows.map(AiModelInfoModel.fromJson).toList(growable: false);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: 500);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
