import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

/// Wraps `flutter_gemma` for on-device inference.
///
/// Background download notes:
/// - Android: files >500 MB auto-promote to a foreground service
///   (notification shown), bypassing the 9-minute background limit.
/// - iOS: `flutter_gemma` uses `NSURLSession` which schedules the
///   download discretionarily — iOS picks the timing, the app may
///   be backgrounded or terminated while download proceeds.
/// - Web: not supported by this datasource (`kIsWeb` guard upstream).
class LocalGemmaDatasource {
  LocalGemmaDatasource();

  CancelToken? _cancelToken;
  InferenceModel? _activeModel;
  InferenceChat? _chat;

  Future<bool> isInstalled(AiModelInfo model) async {
    _assertLlmModel(model);
    try {
      return await FlutterGemma.isModelInstalled(model.fileName);
    } catch (e) {
      throw ServerException(message: 'Install check failed: $e');
    }
  }

  /// Enqueues a background download for [model]. Resolves when the
  /// underlying handler reports the file is fully written.
  Future<void> download(
    AiModelInfo model, {
    void Function(int progress)? onProgress,
  }) async {
    _assertLlmModel(model);
    _cancelToken = CancelToken();
    try {
      final InferenceInstallationBuilder builder = FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.litertlm,
      ).fromNetwork(_platformLinkFor(model)).withCancelToken(_cancelToken!);

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

  /// Returns the platform-appropriate download URL.
  ///
  /// Preference order: platform-specific link → generic [AiModelInfo.modelLink].
  String _platformLinkFor(AiModelInfo model) {
    if (Platform.isAndroid && model.androidModelLink != null) {
      return model.androidModelLink!;
    }
    if (Platform.isIOS && model.iosModelLink != null) {
      return model.iosModelLink!;
    }
    return model.modelLink;
  }

  void _assertLlmModel(AiModelInfo model) {
    if (model.modelType != ModelKind.llm) {
      throw ServerException(
        message: 'LocalGemmaDatasource only accepts LLM models. '
            '"${model.name}" is a ${model.modelType.name} model and must not '
            'be passed to flutter_gemma / MediaPipe LlmInference.',
      );
    }
  }
  Future<void> dispose() async {
    await _activeModel?.close();
    _activeModel = null;
    _chat = null;
  }
}
