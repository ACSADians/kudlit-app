import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

@immutable
class TranslateSketchpadState {
  const TranslateSketchpadState({
    required this.target,
    required this.aiBusy,
    required this.aiResponse,
    this.aiSource,
  });

  const TranslateSketchpadState.initial()
    : this(target: '', aiBusy: false, aiResponse: '');

  final String target;
  final bool aiBusy;
  final String aiResponse;
  final TranslateAiResultSource? aiSource;

  TranslateSketchpadState copyWith({
    String? target,
    bool? aiBusy,
    String? aiResponse,
    TranslateAiResultSource? aiSource,
    bool clearAiSource = false,
  }) {
    return TranslateSketchpadState(
      target: target ?? this.target,
      aiBusy: aiBusy ?? this.aiBusy,
      aiResponse: aiResponse ?? this.aiResponse,
      aiSource: clearAiSource ? null : (aiSource ?? this.aiSource),
    );
  }
}

final NotifierProvider<TranslateSketchpadController, TranslateSketchpadState>
translateSketchpadControllerProvider =
    NotifierProvider<TranslateSketchpadController, TranslateSketchpadState>(
      TranslateSketchpadController.new,
    );

class TranslateSketchpadController extends Notifier<TranslateSketchpadState> {
  @override
  TranslateSketchpadState build() => const TranslateSketchpadState.initial();

  void setTarget(String target) {
    state = state.copyWith(target: target);
  }

  Future<void> requestFeedback(List<List<Offset>> strokes) async {
    if (state.aiBusy) {
      return;
    }
    if (state.target.trim().isEmpty) {
      state = state.copyWith(
        aiResponse: 'Select a target glyph first.',
        clearAiSource: true,
      );
      return;
    }
    if (strokes.isEmpty) {
      state = state.copyWith(
        aiResponse: 'Draw a glyph first before requesting feedback.',
        clearAiSource: true,
      );
      return;
    }

    state = state.copyWith(aiBusy: true, aiResponse: '', clearAiSource: true);
    final Uint8List? imageBytes = await _renderSketchAsPng(strokes);
    if (imageBytes == null) {
      state = state.copyWith(
        aiBusy: false,
        aiResponse: 'Could not prepare the sketch for analysis.',
      );
      return;
    }

    final String prompt =
        'Evaluate this Baybayin sketch for target "${state.target.trim()}". '
        'Start with encouragement, then one concrete stroke tip.';
    final AiPreference mode =
        ref.read(appPreferencesNotifierProvider).value?.aiPreference ??
        AiPreference.cloud;

    if (kIsWeb || mode == AiPreference.cloud) {
      await _streamAnalysis(
        stream: ref
            .read(cloudGemmaDatasourceProvider)
            .analyzeImage(imageBytes, prompt: prompt),
        source: TranslateAiResultSource.online,
        rethrowOnError: false,
      );
      return;
    }

    final TranslateOfflineStatus offline = await ref.read(
      translateOfflineStatusProvider.future,
    );
    if (!offline.usable) {
      state = state.copyWith(
        aiBusy: false,
        aiResponse: 'Offline model is unavailable for this action.',
      );
      return;
    }

    try {
      await _streamAnalysis(
        stream: ref
            .read(localGemmaDatasourceProvider)
            .analyzeImage(imageBytes, prompt: prompt),
        source: TranslateAiResultSource.offline,
        rethrowOnError: true,
      );
    } catch (_) {
      await _streamAnalysis(
        stream: ref
            .read(cloudGemmaDatasourceProvider)
            .analyzeImage(imageBytes, prompt: prompt),
        source: TranslateAiResultSource.fallback,
        prefix:
            'Offline failed for sketch feedback, so cloud fallback was used.\n\n',
        rethrowOnError: false,
      );
    }
  }

  Future<void> _streamAnalysis({
    required Stream<String> stream,
    required TranslateAiResultSource source,
    String prefix = '',
    required bool rethrowOnError,
  }) async {
    final StringBuffer buffer = StringBuffer(prefix);
    try {
      await for (final String chunk in stream) {
        buffer.write(chunk);
        state = state.copyWith(
          aiBusy: true,
          aiResponse: buffer.toString(),
          aiSource: source,
        );
      }
      state = state.copyWith(
        aiBusy: false,
        aiResponse: buffer.toString(),
        aiSource: source,
      );
    } catch (error) {
      state = state.copyWith(
        aiBusy: false,
        aiResponse: 'Could not complete sketch feedback: $error',
        clearAiSource: true,
      );
      if (rethrowOnError) {
        rethrow;
      }
    }
  }

  Future<Uint8List?> _renderSketchAsPng(List<List<Offset>> strokes) async {
    final List<Offset> allPoints = <Offset>[
      for (final List<Offset> stroke in strokes) ...stroke,
    ];
    if (allPoints.isEmpty) {
      return null;
    }

    double minX = allPoints.first.dx;
    double minY = allPoints.first.dy;
    double maxX = allPoints.first.dx;
    double maxY = allPoints.first.dy;
    for (final Offset point in allPoints) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    const int width = 320;
    const int height = 240;
    const double padding = 24;
    final double spanX = ((maxX - minX).abs().clamp(
      1,
      double.infinity,
    )).toDouble();
    final double spanY = ((maxY - minY).abs().clamp(
      1,
      double.infinity,
    )).toDouble();
    final double scaleX = (width - (padding * 2)) / spanX;
    final double scaleY = (height - (padding * 2)) / spanY;
    final double scale = scaleX < scaleY ? scaleX : scaleY;
    final double drawnWidth = spanX * scale;
    final double drawnHeight = spanY * scale;
    final double offsetX = (width - drawnWidth) / 2;
    final double offsetY = (height - drawnHeight) / 2;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = const Color(0xFFFFFFFF),
    );

    final Paint paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final List<Offset> stroke in strokes) {
      if (stroke.length < 2) {
        continue;
      }
      final Offset first = _transformPoint(
        stroke.first,
        minX: minX,
        minY: minY,
        scale: scale,
        offsetX: offsetX,
        offsetY: offsetY,
      );
      final Path path = Path()..moveTo(first.dx, first.dy);
      for (int i = 1; i < stroke.length; i++) {
        final Offset next = _transformPoint(
          stroke[i],
          minX: minX,
          minY: minY,
          scale: scale,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        path.lineTo(next.dx, next.dy);
      }
      canvas.drawPath(path, paint);
    }

    final ui.Image image = await recorder.endRecording().toImage(width, height);
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return bytes?.buffer.asUint8List();
  }

  Offset _transformPoint(
    Offset point, {
    required double minX,
    required double minY,
    required double scale,
    required double offsetX,
    required double offsetY,
  }) {
    return Offset(
      ((point.dx - minX) * scale) + offsetX,
      ((point.dy - minY) * scale) + offsetY,
    );
  }
}
