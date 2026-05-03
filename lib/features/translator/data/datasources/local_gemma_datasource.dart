import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/translator/data/datasources/ai_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/baybayin_challenge.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';

/// Wraps `flutter_gemma` for on-device inference.
///
/// Background download notes:
/// - Android: files >500 MB auto-promote to a foreground service
///   (notification shown), bypassing the 9-minute background limit.
/// - iOS: `flutter_gemma` uses `NSURLSession` which schedules the
///   download discretionarily — iOS picks the timing, the app may
///   be backgrounded or terminated while download proceeds.
/// - Web: not supported by this datasource (`kIsWeb` guard upstream).
class LocalGemmaDatasource implements AiDatasource {
  LocalGemmaDatasource();

  CancelToken? _cancelToken;
  InferenceModel? _activeModel;
  InferenceChat? _chat;

  Future<bool> isInstalled(GemmaModelInfo model) async {
    try {
      return await FlutterGemma.isModelInstalled(model.fileName);
    } catch (e) {
      throw ServerException(message: 'Install check failed: $e');
    }
  }

  /// Enqueues a background download for [model]. Resolves when the
  /// underlying handler reports the file is fully written.
  Future<void> download(
    GemmaModelInfo model, {
    void Function(int progress)? onProgress,
  }) async {
    _assertLlmModel(model);
    _cancelToken = CancelToken();
    try {
      final String? hfToken = dotenv.env['HUGGINGFACE_TOKEN'];
      final InferenceInstallationBuilder builder =
          FlutterGemma.installModel(modelType: ModelType.gemma4)
              .fromNetwork(model.modelLink, token: hfToken)
              .withCancelToken(_cancelToken!);

      if (onProgress != null) {
        builder.withProgress(onProgress);
      }

      await builder.install();
    } on Exception catch (e) {
      if (CancelToken.isCancel(e)) {
        throw const ServerException(message: 'Download cancelled');
      }
      throw ServerException(message: 'Download failed: $e');
    } finally {
      _cancelToken = null;
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel('User cancelled download');
  }

  /// Lazily creates the active model + chat and streams text tokens.
  @override
  Stream<String> generate(
    List<ChatMessage> history, {
    String? systemInstruction,
  }) async* {
    _activeModel ??= await FlutterGemma.getActiveModel();
    _chat ??= await _activeModel!.createChat(
      systemInstruction: systemInstruction,
    );

    if (history.isEmpty) {
      return;
    }
    final ChatMessage last = history.last;
    await _chat!.addQueryChunk(
      Message.text(text: last.text, isUser: last.isUser),
    );

    await for (final ModelResponse response
        in _chat!.generateChatResponseAsync()) {
      if (response is TextResponse) {
        yield response.token;
      }
    }
  }

  @override
  Stream<String> analyzeImage(
    Uint8List imageBytes, {
    String mimeType = 'image/png',
    String? prompt,
  }) => throw UnsupportedError('analyzeImage is not supported on-device');

  @override
  Future<BaybayinChallenge> generateChallenge({List<String>? characters}) =>
      throw UnsupportedError('generateChallenge is not supported on-device');

  void _assertLlmModel(GemmaModelInfo model) {
    // GemmaModelInfo is always an LLM model by definition.
    // This guard exists for future AiModelInfo migration.
  }

  @override
  Future<void> dispose() async {
    await _activeModel?.close();
    _activeModel = null;
    _chat = null;
  }
}
