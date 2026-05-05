import 'package:meta/meta.dart';

@immutable
class ScanResult {
  const ScanResult({
    this.id,
    required this.tokens,
    required this.translation,
    required this.timestamp,
  });

  final int? id;
  final List<String> tokens;
  final String translation;
  final DateTime timestamp;

  ScanResult copyWith({int? id}) {
    return ScanResult(
      id: id ?? this.id,
      tokens: tokens,
      translation: translation,
      timestamp: timestamp,
    );
  }
}
