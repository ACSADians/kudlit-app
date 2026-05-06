import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

// Export card dimensions in logical pixels.
const double _kCardWidth = 320;
const double _kCardHeight = 180;

class _BgOption {
  const _BgOption(this.name, this.start, this.end);

  final String name;
  final Color start;
  final Color end;

  bool get isLight => start.computeLuminance() > 0.4;
}

const List<_BgOption> _kBgOptions = <_BgOption>[
  _BgOption('Space', Color(0xFF0A1628), Color(0xFF1A3A5C)),
  _BgOption('Violet', Color(0xFF1A0533), Color(0xFF2D1B69)),
  _BgOption('Teal', Color(0xFF0B2B2C), Color(0xFF0E4040)),
  _BgOption('Ember', Color(0xFF3D0C02), Color(0xFF7C2D12)),
  _BgOption('Sakura', Color(0xFF2D0A1E), Color(0xFF5C1A40)),
  _BgOption('Parchment', Color(0xFFF0E6CE), Color(0xFFE0D0A8)),
];

class BaybayinExportSheet extends StatefulWidget {
  const BaybayinExportSheet({
    super.key,
    required this.baybayin,
    required this.latin,
  });

  final String baybayin;
  final String latin;

  static Future<void> show(
    BuildContext context, {
    required String baybayin,
    required String latin,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BaybayinExportSheet(baybayin: baybayin, latin: latin),
    );
  }

  @override
  State<BaybayinExportSheet> createState() => _BaybayinExportSheetState();
}

class _BaybayinExportSheetState extends State<BaybayinExportSheet> {
  final GlobalKey _cardKey = GlobalKey();
  int _selectedBg = 0;
  bool _exporting = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return;
      final Uint8List bytes = byteData.buffer.asUint8List();
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile.fromData(
              bytes,
              name: 'baybayin.png',
              mimeType: 'image/png',
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final _BgOption bg = _kBgOptions[_selectedBg];
    // Cap the sheet at 90% of screen height so controls are always reachable.
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.90;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Export as image',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: RepaintBoundary(
              key: _cardKey,
              child: _ExportCard(
                baybayin: widget.baybayin,
                latin: widget.latin,
                bg: bg,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kBgOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, int i) {
                final _BgOption opt = _kBgOptions[i];
                final bool selected = i == _selectedBg;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBg = i),
                  child: Tooltip(
                    message: opt.name,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: <Color>[opt.start, opt.end],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: selected ? cs.primary : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: selected
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: cs.primary.withAlpha(80),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _exporting ? null : _export,
              icon: _exporting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded),
              label: Text(_exporting ? 'Preparing…' : 'Export image'),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.baybayin,
    required this.latin,
    required this.bg,
  });

  final String baybayin;
  final String latin;
  final _BgOption bg;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        bg.isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final Color subtleColor = bg.isLight
        ? const Color(0xFF1A1A1A).withAlpha(130)
        : Colors.white.withAlpha(150);

    return Container(
      width: _kCardWidth,
      height: _kCardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[bg.start, bg.end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Text(
            baybayin,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Baybayin Simple TAWBID',
              fontSize: 48,
              color: textColor,
              letterSpacing: 8,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(width: 32, height: 1.5, color: subtleColor),
          const SizedBox(height: 10),
          Text(
            latin,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'Kudlit',
              style: TextStyle(
                fontSize: 10,
                color: subtleColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
