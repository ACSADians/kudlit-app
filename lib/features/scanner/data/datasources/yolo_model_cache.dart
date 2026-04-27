import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local on-disk cache for the Baybayin YOLO model.
///
/// Models are stored in:
///   `<app-support>/yolo_models/baybayin_yolo.{tflite|mlpackage.zip}`
///
/// Usage:
/// - [downloadedPath] — returns the file's absolute path if it has been
///   downloaded, `null` otherwise.
/// - [resolvedModelPath] — returns the downloaded path, or throws a
///   [StateError] if the model has not been downloaded yet.
/// - [download] — downloads the model from [url] and returns its local path.
class YoloModelCache {
  YoloModelCache._();

  static final YoloModelCache instance = YoloModelCache._();

  /// Platform-specific filename for the YOLO model.
  String get _fileName =>
      Platform.isIOS ? 'baybayin_yolo.mlpackage.zip' : 'baybayin_yolo.tflite';


  Future<Directory> _modelsDir() async {
    final Directory base = await getApplicationSupportDirectory();
    final Directory dir = Directory(p.join(base.path, 'yolo_models'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _modelFile() async {
    final Directory dir = await _modelsDir();
    return File(p.join(dir.path, _fileName));
  }

  /// Returns `true` if the model has been downloaded.
  Future<bool> isDownloaded() async {
    final File file = await _modelFile();
    return file.existsSync();
  }

  /// Returns the absolute filesystem path of the downloaded model, or `null`
  /// if no downloaded model exists.
  Future<String?> downloadedPath() async {
    final File file = await _modelFile();
    return file.existsSync() ? file.path : null;
  }

  /// Returns the absolute path of the downloaded model.
  ///
  /// Throws a [StateError] if the model has not been downloaded yet.
  /// Check [isDownloaded] or watch `yoloModelPathProvider` to gate access.
  Future<String> resolvedModelPath() async {
    final String? downloaded = await downloadedPath();
    if (downloaded == null) {
      throw StateError(
        'YOLO model not downloaded. Prompt the user to download it first.',
      );
    }
    return downloaded;
  }

  /// Downloads the model from [url] into the cache directory.
  ///
  /// [onProgress] is called with `(bytesReceived, totalBytes)` each chunk;
  /// `totalBytes` is `-1` when the server does not send Content-Length.
  ///
  /// Returns the absolute path of the saved file.
  Future<String> download(
    String url, {
    void Function(int received, int total)? onProgress,
  }) async {
    final File target = await _modelFile();
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request = await client.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();
      if (response.statusCode != 200) {
        throw Exception(
          'YOLO model download failed — HTTP ${response.statusCode}',
        );
      }
      final int total = response.contentLength; // -1 if unknown
      int received = 0;
      final IOSink sink = target.openWrite();
      await for (final List<int> chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
      await sink.flush();
      await sink.close();
    } catch (e) {
      // Remove a partially written file so the next attempt starts clean.
      if (target.existsSync()) await target.delete();
      rethrow;
    } finally {
      client.close();
    }
    debugPrint('[YoloModelCache] downloaded → ${target.path}');
    return target.path;
  }

  /// Deletes the cached model file (e.g. to force a re-download).
  Future<void> clear() async {
    final File file = await _modelFile();
    if (file.existsSync()) await file.delete();
    debugPrint('[YoloModelCache] cache cleared');
  }
}
