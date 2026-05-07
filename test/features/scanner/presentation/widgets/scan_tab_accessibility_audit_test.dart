import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readFile(String path) {
  return File(path).readAsStringSync();
}

String _extractClassBlock(String source, String className) {
  final int start = source.indexOf('class $className');
  expect(start, isNot(-1));
  final int next = source.indexOf('\nclass ', start + 1);
  return source.substring(start, next == -1 ? source.length : next);
}

void _assertPattern(String block, Pattern pattern, String reason) {
  expect(block, contains(pattern), reason: reason);
}

void main() {
  final String scanTabSource = _readFile(
    'lib/features/home/presentation/screens/scan_tab.dart',
  );
  final String scannerCameraSource = _readFile(
    'lib/features/scanner/presentation/widgets/scanner_camera.dart',
  );

  test('scan tab interactive controls enforce >= 48dp targets', () {
    final String utilityBar = _extractClassBlock(
      scanTabSource,
      '_ScanUtilityBar',
    );
    final String shutterButton = _extractClassBlock(
      scanTabSource,
      '_ShutterButton',
    );
    final String statusChip = _extractClassBlock(
      scanTabSource,
      '_ScanStatusChip',
    );
    final String noticeButton = _extractClassBlock(
      scanTabSource,
      '_NoticeButton',
    );
    final String actionChip = _extractClassBlock(scanTabSource, '_ActionChip');
    final String cyclerButton = _extractClassBlock(
      scanTabSource,
      '_CyclerButton',
    );
    final String tellMeMore = _extractClassBlock(
      scanTabSource,
      '_TellMeMoreButton',
    );

    _assertPattern(
      utilityBar,
      '_iconSize => tiny ? (compact ? 48 : 52) : 48;',
      'utility control icons should map to a minimum 48dp',
    );
    _assertPattern(
      utilityBar,
      'size: _iconSize,',
      'utility control icons should use configured icon size',
    );
    _assertPattern(
      shutterButton,
      'final double outerSize = compact ? (tiny ? 58 : 64) : (tiny ? 66 : 72);',
      'shutter control outer target should stay above minimum touch size',
    );
    _assertPattern(
      statusChip,
      'BoxConstraints(minHeight: 48',
      'status chip should remain a minimum 48dp tall touch target',
    );
    _assertPattern(
      noticeButton,
      'height: 48,',
      'notice action buttons should be at least 48dp high',
    );
    _assertPattern(
      actionChip,
      'width: 48,',
      'result action chip width should be at least 48dp',
    );
    _assertPattern(
      actionChip,
      'height: 48,',
      'result action chip height should be at least 48dp',
    );
    _assertPattern(
      cyclerButton,
      'width: 48,',
      'cycler control should be at least 48dp wide',
    );
    _assertPattern(
      cyclerButton,
      'height: 48,',
      'cycler control should be at least 48dp tall',
    );
    _assertPattern(
      tellMeMore,
      'constraints: const BoxConstraints(minHeight: 48)',
      'follow-up button should keep a minimum 48dp hit area',
    );
  });

  test(
    'scanner status fallback message hardening keeps readable compact content',
    () {
      final String statusMessage = _extractClassBlock(
        scannerCameraSource,
        'WebStatusMessage',
      );

      _assertPattern(
        statusMessage,
        'maxLines: 3,',
        'camera status message should clamp to avoid clipping',
      );
      _assertPattern(
        statusMessage,
        'height: 1.2,',
        'camera status message should use tighter line-height',
      );
      _assertPattern(
        statusMessage,
        'maxLines: showCompact ? 1 : 2,',
        'compact camera status should stay on a single line where needed',
      );
    },
  );
}
