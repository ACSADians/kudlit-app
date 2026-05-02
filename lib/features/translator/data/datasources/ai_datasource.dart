import 'dart:typed_data';

import 'package:kudlit_ph/features/translator/domain/entities/baybayin_challenge.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

/// Shared contract for all AI inference datasources (local and cloud).
///
/// Both [LocalGemmaDatasource] and [CloudGemmaDatasource] implement this
/// interface. Methods not supported by a datasource throw [UnsupportedError].
abstract interface class AiDatasource {
  /// Streams generated tokens for the given [history].
  Stream<String> generate(
    List<ChatMessage> history, {
    String? systemInstruction,
  });

  /// Streams a description / translation of Baybayin characters in [imageBytes].
  ///
  /// [mimeType] defaults to `'image/png'`.
  Stream<String> analyzeImage(
    Uint8List imageBytes, {
    String mimeType,
    String? prompt,
  });

  /// Returns a single generated Baybayin learning challenge.
  Future<BaybayinChallenge> generateChallenge({List<String>? characters});

  Future<void> dispose();
}
