import 'dart:math' show Random;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

// Export card width in logical pixels — height is intrinsic (grows with content).
const double _kCardWidth = 320;

const List<String> _kButtyAssets = <String>[
  'assets/brand/ButtyPaint.webp',
  'assets/brand/ButtyPencilRun.webp',
  'assets/brand/ButtyPhone.webp',
  'assets/brand/ButtyRead.webp',
  'assets/brand/ButtyWave.webp',
];

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
  // Chosen once per sheet open so it stays stable across background changes.
  final String _buttyAsset =
      _kButtyAssets[Random().nextInt(_kButtyAssets.length)];

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();
      if (byteData == null) return;
      final Uint8List bytes = byteData.buffer.asUint8List();
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile.fromData(bytes, name: 'baybayin.png', mimeType: 'image/png'),
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
    final Size viewport = MediaQuery.sizeOf(context);
    final bool compactLandscape =
        viewport.width > viewport.height && viewport.height < 430;
    final double maxHeight = viewport.height * (compactLandscape ? 0.96 : 0.9);
    final double horizontalPadding = viewport.width < 380 ? 16 : 24;
    final double cardWidth = (viewport.width - (horizontalPadding * 2)).clamp(
      260.0,
      _kCardWidth,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              10,
              horizontalPadding,
              16,
            ),
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
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Export as image',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      'PNG',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface.withAlpha(140),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RepaintBoundary(
                          key: _cardKey,
                          child: _ExportCard(
                            width: cardWidth,
                            baybayin: widget.baybayin,
                            latin: widget.latin,
                            bg: bg,
                            buttyAsset: _buttyAsset,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _BackgroundPicker(
                          selectedBg: _selectedBg,
                          onSelected: (int i) =>
                              setState(() => _selectedBg = i),
                          cs: cs,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exporting ? null : _export,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: _exporting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.ios_share_rounded),
                    label: Text(_exporting ? 'Preparing...' : 'Export image'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundPicker extends StatelessWidget {
  const _BackgroundPicker({
    required this.selectedBg,
    required this.onSelected,
    required this.cs,
  });

  final int selectedBg;
  final ValueChanged<int> onSelected;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kBgOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, int i) {
          final _BgOption opt = _kBgOptions[i];
          final bool selected = i == selectedBg;
          return Semantics(
            button: true,
            selected: selected,
            label: '${opt.name} background${selected ? ', selected' : ''}',
            excludeSemantics: true,
            child: Tooltip(
              message: opt.name,
              excludeFromSemantics: true,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onSelected(i),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
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
                          color: selected ? cs.primary : cs.outlineVariant,
                          width: selected ? 3 : 1,
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.width,
    required this.baybayin,
    required this.latin,
    required this.bg,
    required this.buttyAsset,
  });

  final double width;
  final String baybayin;
  final String latin;
  final _BgOption bg;
  final String buttyAsset;

  @override
  Widget build(BuildContext context) {
    final Color textColor = bg.isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final Color subtleColor = bg.isLight
        ? const Color(0xFF1A1A1A).withAlpha(130)
        : Colors.white.withAlpha(150);

    return Container(
      width: width,
      // No fixed height — card grows to fit however much Baybayin is needed.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[bg.start, bg.end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.fromLTRB(
        width < 300 ? 22 : 28,
        26,
        width < 300 ? 22 : 28,
        20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            baybayin,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontFamily: 'Baybayin Simple TAWBID',
              fontSize: width < 300 ? 38 : 44,
              color: textColor,
              letterSpacing: width < 300 ? 6 : 8,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(width: 32, height: 1.5, color: subtleColor),
          const SizedBox(height: 12),
          Text(
            latin,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: width < 300 ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Image.asset(
                buttyAsset,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
              Text(
                'Kudlit',
                style: TextStyle(
                  fontSize: 10,
                  color: subtleColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
