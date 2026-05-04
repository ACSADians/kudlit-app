import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/features/admin/data/datasources/supabase_stroke_pattern_datasource.dart';
import 'package:kudlit_ph/features/admin/data/repositories/stroke_pattern_repository_impl.dart';
import 'package:kudlit_ph/features/admin/domain/repositories/stroke_pattern_repository.dart';

final Provider<SupabaseStrokePatternDatasource>
supabaseStrokePatternDatasourceProvider =
    Provider<SupabaseStrokePatternDatasource>(
      (Ref ref) =>
          SupabaseStrokePatternDatasource(client: Supabase.instance.client),
    );

final Provider<StrokePatternRepository> strokePatternRepositoryProvider =
    Provider<StrokePatternRepository>(
      (Ref ref) => StrokePatternRepositoryImpl(
        datasource: ref.watch(supabaseStrokePatternDatasourceProvider),
      ),
    );
