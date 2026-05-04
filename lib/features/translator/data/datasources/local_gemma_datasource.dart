import 'package:flutter/foundation.dart';
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

  Future<LocalGemmaReadiness> probeReadiness(GemmaModelInfo model) async {
    try {
      final bool installed = await FlutterGemma.isModelInstalled(
        model.fileName,
      );
      if (!installed) {
        return LocalGemmaReadiness(
          installed: false,
          usable: false,
          detail: '${model.name} is not installed on this device.',
        );
      }

      if (!FlutterGemma.hasActiveModel()) {
        debugPrint(
          '[Gemma][local] installed file found but no active model set; reactivating ${model.fileName}',
        );
        await _reactivateInstalledModel(model);
      }

      final InferenceModel probeModel = await FlutterGemma.getActiveModel();
      debugPrint('[Gemma][local] readiness probe acquired active model');
      await probeModel.close();
      return LocalGemmaReadiness(
        installed: true,
        usable: true,
        detail: 'Offline ready: ${model.name}',
      );
    } catch (e, s) {
      debugPrint('[Gemma][local] readiness probe failed: $e');
      debugPrintStack(stackTrace: s, label: '[Gemma][local] readiness stack');
      return LocalGemmaReadiness(
        installed: true,
        usable: false,
        detail: 'Model files exist, but offline Gemma is not usable yet: $e',
      );
    }
  }

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
          FlutterGemma.installModel(
                modelType: ModelType.gemma4,
                fileType: _modelFileTypeFor(model),
              )
              .fromNetwork(model.modelLink, token: hfToken)
              .withCancelToken(_cancelToken!);

      if (onProgress != null) {
        builder.withProgress(onProgress);
      }

      await builder.install();
      debugPrint(
        '[Gemma][local] download/install completed for ${model.fileName}',
      );
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
    try {
      debugPrint(
        '[Gemma][local] generate called | history=${history.length} | hasSystemInstruction=${systemInstruction != null}',
      );
      _activeModel ??= await FlutterGemma.getActiveModel();
      debugPrint('[Gemma][local] active model ready');
      _chat ??= await _activeModel!.createChat(
        systemInstruction: systemInstruction,
      );
      debugPrint('[Gemma][local] chat session ready');

      if (history.isEmpty) {
        debugPrint('[Gemma][local] history empty -> no output');
        return;
      }
      final ChatMessage last = history.last;
      await _chat!.addQueryChunk(
        Message.text(text: last.text, isUser: last.isUser),
      );
      debugPrint(
        '[Gemma][local] last message enqueued | isUser=${last.isUser} | chars=${last.text.length}',
      );

      await for (final ModelResponse response
          in _chat!.generateChatResponseAsync()) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
      debugPrint('[Gemma][local] token stream finished');
    } catch (e, s) {
      debugPrint('[Gemma][local] generate error: $e');
      debugPrintStack(stackTrace: s, label: '[Gemma][local] stack');
      rethrow;
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

  Future<void> _reactivateInstalledModel(GemmaModelInfo model) async {
    final String? hfToken = dotenv.env['HUGGINGFACE_TOKEN'];
    await FlutterGemma.installModel(
      modelType: ModelType.gemma4,
      fileType: _modelFileTypeFor(model),
    ).fromNetwork(model.modelLink, token: hfToken).install();
    debugPrint('[Gemma][local] active model restored for ${model.fileName}');
  }

  ModelFileType _modelFileTypeFor(GemmaModelInfo model) {
    final String lower = model.fileName.toLowerCase();
    if (lower.endsWith('.litertlm')) {
      return ModelFileType.litertlm;
    }
    return ModelFileType.task;
  }

  @override
  Future<void> dispose() async {
    await _activeModel?.close();
    _activeModel = null;
    _chat = null;
  }
}

class LocalGemmaReadiness {
  const LocalGemmaReadiness({
    required this.installed,
    required this.usable,
    required this.detail,
  });

  final bool installed;
  final bool usable;
  final String detail;
}
