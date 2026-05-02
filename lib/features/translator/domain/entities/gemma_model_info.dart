import 'package:meta/meta.dart';

/// Metadata for a Gemma on-device inference model.
///
/// Sourced from the `public.gemma_models` Supabase table.
@immutable
class GemmaModelInfo {
  const GemmaModelInfo({
    required this.id,
    required this.name,
    required this.modelLink,
  });

  final String id;
  final String name;

  /// Download URL for the model weights.
  final String modelLink;

  /// Filename derived from [modelLink], used by `flutter_gemma`
  /// to check whether the model is already installed locally.
  String get fileName {
    final Uri uri = Uri.parse(modelLink);
    final String last = uri.pathSegments.isEmpty
        ? modelLink
        : uri.pathSegments.last;
    return last.isEmpty ? modelLink : last;
  }
}
