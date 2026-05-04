import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import 'package:kudlit_ph/features/admin/data/models/stroke_pattern_model.dart';
import 'package:kudlit_ph/features/admin/domain/entities/stroke_pattern.dart';

/// Exports a [StrokePattern] as a JSON file.
///
/// Uses [SharePlus] with raw bytes so it works on all platforms:
/// - **Mobile / Desktop**: opens the system share sheet (AirDrop, email, etc.)
/// - **Web**: triggers a browser "Save As" / download or Web Share API
///
/// Returns the generated file name.
Future<String> exportStrokePatternAsJson(StrokePattern pattern) async {
  final StrokePatternModel model = StrokePatternModel.fromDomain(pattern);
  final String jsonString = const JsonEncoder.withIndent(
    '  ',
  ).convert(model.toExportJson());

  final String fileName =
      'stroke_${pattern.glyph}_${pattern.createdAt.millisecondsSinceEpoch}.json';

  final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
  final XFile xFile = XFile.fromData(
    bytes,
    name: fileName,
    mimeType: 'application/json',
  );

  await SharePlus.instance.share(
    ShareParams(
      files: <XFile>[xFile],
      subject: 'Stroke pattern: ${pattern.label} (${pattern.glyph})',
    ),
  );

  return fileName;
}
