import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/widgets/yolo_sim_overlay.dart';

/// Baybayin scanner screen.
/// On web: shows a simulated scanner UI with upload placeholder.
/// On mobile: YOLO on-device inference will be wired here.
class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  bool _resultVisible = false;

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double controlsBottom = safeBottom + 20;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const _ScanBackground(),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(bottom: false, child: _ScanningIndicator()),
        ),
        const YoloSimOverlay(),
        Positioned(
          left: 0,
          right: 0,
          bottom: controlsBottom,
          child: _ScanControls(
            onShutter: () => setState(() => _resultVisible = !_resultVisible),
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

// ── Background ────────────────────────────────────────────────────────────────

class _ScanBackground extends StatelessWidget {
  const _ScanBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF0F1520), Color(0xFF080C18)],
        ),
      ),
    );
  }
}

// ── Scanning indicator ────────────────────────────────────────────────────────

class _ScanningIndicator extends StatelessWidget {
  const _ScanningIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xE664D2FF),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Color(0xB364D2FF), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                kIsWeb
                    ? 'Web preview  ·  Tap shutter to simulate'
                    : 'Scanning…',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0x8CFFFFFF),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Controls ──────────────────────────────────────────────────────────────────

class _ScanControls extends StatelessWidget {
  const _ScanControls({required this.onShutter});

  final VoidCallback onShutter;

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
                children: const <Widget>[
                  _ControlIcon(icon: Icons.image_outlined),
                  SizedBox(width: 18),
                  _ControlIcon(icon: Icons.flash_off_rounded),
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
    return Icon(icon, size: 26, color: Colors.white70);
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
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: Center(
          child: Container(
            width: 54,
            height: 54,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xD20C0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
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
          color: Colors.white24,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'mhal kita',
          style: TextStyle(
            fontFamily: 'Baybayin Simple TAWBID',
            fontSize: 28,
            color: Colors.white,
            letterSpacing: 6,
            height: 1.1,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Mahal kita',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xD9FFFFFF),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, size: 15, color: Colors.white60),
      ),
    );
  }
}
