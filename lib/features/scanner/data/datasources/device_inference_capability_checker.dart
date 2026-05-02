import 'dart:io';

/// Minimum supported OS versions for on-device YOLO inference.
///
/// Android: API 23 (Android 6.0) — minimum for TFLite + CameraX.
/// iOS:     12.0 — minimum for CoreML 2.
const int _kMinAndroidApiLevel = 23;
const double _kMinIosVersion = 12.0;

/// Checks whether the current device meets the minimum OS requirements to
/// run on-device YOLO inference.
///
/// Call [check] once at start-up (it reads static platform strings and is
/// effectively free). The result is stable for the life of the process.
class DeviceInferenceCapabilityChecker {
  const DeviceInferenceCapabilityChecker._();

  static const DeviceInferenceCapabilityChecker instance =
      DeviceInferenceCapabilityChecker._();

  /// Returns `true` if the device can run on-device YOLO inference.
  ///
  /// Returns `true` optimistically when the OS version string cannot be
  /// parsed — better to attempt and fail gracefully than to block the user.
  bool check() {
    if (Platform.isAndroid) return _checkAndroid();
    if (Platform.isIOS) return _checkIos();
    // macOS / Linux / Windows desktop — not a target platform.
    return false;
  }

  /// Parses the API level from [Platform.operatingSystemVersion].
  ///
  /// Example string: `"Android 11 (API 30)"`
  bool _checkAndroid() {
    final RegExp re = RegExp(r'API\s+(\d+)', caseSensitive: false);
    final RegExpMatch? match = re.firstMatch(Platform.operatingSystemVersion);
    if (match == null) return true;
    final int? level = int.tryParse(match.group(1) ?? '');
    return level == null || level >= _kMinAndroidApiLevel;
  }

  /// Parses the major.minor version from [Platform.operatingSystemVersion].
  ///
  /// Example string: `"15.1"`
  bool _checkIos() {
    final List<String> parts = Platform.operatingSystemVersion.split('.');
    final String versionString =
        '${parts[0]}.${parts.length > 1 ? parts[1] : '0'}';
    final double? parsed = double.tryParse(versionString);
    return parsed == null || parsed >= _kMinIosVersion;
  }
}
