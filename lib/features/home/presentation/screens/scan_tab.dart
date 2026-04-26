import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/aggregated_bounding_box.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/detection_overlay.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/scanner_camera.dart';

/// Baybayin scanner screen.
///
/// Embeds [ScannerCamera] (which owns the YOLO inference), reads the latest
/// detections from [ScannerNotifier], and renders the controls + result panel.
class ScanTab extends ConsumerStatefulWidget {
  const ScanTab({super.key});

  @override
  ConsumerState<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends ConsumerState<ScanTab> {
  bool _resultVisible = false;
  bool _flashOn = false;

  Future<void> _toggleFlash() async {
    final bool next = !_flashOn;
    setState(() => _flashOn = next);
    await ref.read(baybayinDetectorProvider).toggleTorch(enabled: next);
  }

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double controlsBottom = safeBottom + 20;
    final List<BaybayinDetection> detections = ref.watch(
      scannerNotifierProvider,
    );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _ScanCameraStack(
          detections: detections,
          flashOn: _flashOn,
          onDetections: (List<BaybayinDetection> d) =>
              ref.read(scannerNotifierProvider.notifier).update(d),
          onFlashToggle: kIsWeb ? null : _toggleFlash,
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(bottom: false, child: _ScanningIndicator()),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: controlsBottom,
          child: _ScanControls(
            flashOn: _flashOn,
            onShutter: () => setState(() => _resultVisible = !_resultVisible),
            onFlashToggle: kIsWeb ? null : _toggleFlash,
          ),
        ),
        if (_resultVisible)
          Positioned(
            left: 14,
            right: 14,
            bottom: controlsBottom + 96,
            child: _ScanResultPanel(
              onDismiss: () => setState(() => _resultVisible = false),
            ),
          ),
      ],
    );
  }
}

// ── Camera + overlays ────────────────────────────────────────────────────────

class _ScanCameraStack extends StatelessWidget {
  const _ScanCameraStack({
    required this.detections,
    required this.flashOn,
    required this.onDetections,
    required this.onFlashToggle,
  });

  final List<BaybayinDetection> detections;
  final bool flashOn;
  final void Function(List<BaybayinDetection>) onDetections;
  final VoidCallback? onFlashToggle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ScannerCamera(
          flashOn: flashOn,
          onDetections: onDetections,
          onFlashToggle: onFlashToggle,
        ),
        AggregatedBoundingBox(detections: detections),
        DetectionOverlay(detections: detections),
      ],
    );
  }
}

// ── Scanning indicator ────────────────────────────────────────────────────────

class _ScanningIndicator extends StatelessWidget {
  const _ScanningIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.only(top: 10), child: Center());
  }
}

// ── Controls ──────────────────────────────────────────────────────────────────

class _ScanControls extends StatelessWidget {
  const _ScanControls({
    required this.flashOn,
    required this.onShutter,
    required this.onFlashToggle,
  });

  final bool flashOn;
  final VoidCallback onShutter;
  final VoidCallback? onFlashToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const _ControlIcon(icon: Icons.image_outlined),
                  if (onFlashToggle != null) ...<Widget>[
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: onFlashToggle,
                      child: _ControlIcon(
                        icon: flashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _ShutterButton(onTap: onShutter),
        ],
      ),
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0E1425).withAlpha(160),
      ),
      child: Icon(icon, size: 22, color: Colors.white.withAlpha(220)),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0E1425).withAlpha(100),
          border: Border.all(color: Colors.white.withAlpha(180), width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Color(0x4D7AAAFF), blurRadius: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Result panel ──────────────────────────────────────────────────────────────

class _ScanResultPanel extends StatelessWidget {
  const _ScanResultPanel({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _ResultHandle(),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(child: _ResultText()),
              const SizedBox(width: 12),
              _ResultActions(onDismiss: onDismiss),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultHandle extends StatelessWidget {
  const _ResultHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 28,
        height: 3,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _ResultText extends StatelessWidget {
  const _ResultText();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'mhal kita',
          style: TextStyle(
            fontFamily: 'Baybayin Simple TAWBID',
            fontSize: 28,
            color: cs.onSurface,
            letterSpacing: 6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Mahal kita',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withAlpha(217),
            letterSpacing: -0.15,
          ),
        ),
      ],
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ActionChip(icon: Icons.copy_rounded, onTap: () {}),
        const SizedBox(width: 6),
        _ActionChip(icon: Icons.share_rounded, onTap: () {}),
        const SizedBox(width: 6),
        _ActionChip(icon: Icons.close_rounded, onTap: onDismiss),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline),
        ),
        child: Icon(icon, size: 15, color: cs.onSurface.withAlpha(150)),
      ),
    );
  }
}
