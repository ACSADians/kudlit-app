import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:kudlit_ph/core/utils/baybayify.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/butty_bubble.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/typing_bubble.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/scan_result.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scan_history_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scan_tab_controller.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_evaluation_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/aggregated_bounding_box.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/scanner_camera.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/yolo_model_dropdown.dart';

/// Baybayin scanner screen.
///
/// Embeds [ScannerCamera] (which owns the YOLO inference), reads the latest
/// detections from [ScannerNotifier], and renders the controls + result panel.
class ScanTab extends ConsumerWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScanTabController controller = ref.read(
      scanTabControllerProvider.notifier,
    );
    final ScanTabState scanState = ref.watch(scanTabControllerProvider);
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
          flashOn: scanState.flashOn,
          onDetections: controller.applyLiveDetections,
          onFlashToggle: kIsWeb ? null : () => controller.toggleFlash(),
          selectedImageBytes: scanState.selectedImageBytes,
          onPermutationsTap: (List<String> permutations) async {
            controller.setDetectionsFrozen(true);
            await showDialog<void>(
              context: context,
              builder: (BuildContext _) {
                return _PermutationsDialog(permutations: permutations);
              },
            );
            controller.setDetectionsFrozen(false);
          },
        ),
        if (scanState.isLoadingImage)
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator()),
          ),
        const Positioned(
          top: 0,
          right: 12,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: YoloModelDropdown(scope: YoloModelScope.camera),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: controlsBottom,
          child: _ScanControls(
            flashOn: scanState.flashOn,
            onShutter: controller.onShutterTapped,
            onFlashToggle: kIsWeb ? null : () => controller.toggleFlash(),
            onGalleryTap: () => controller.pickImageFromGallery(),
          ),
        ),
        if (scanState.resultVisible)
          Positioned(
            left: 14,
            right: 14,
            bottom: controlsBottom + 96,
            child: _ScanResultPanel(
              detections: scanState.snapshot,
              onDismiss: controller.dismissResult,
            ),
          )
        else if (scanState.aggregatedWinner != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: controlsBottom + 96,
            child: _AggregatedWinnerBanner(
              winner: scanState.aggregatedWinner!,
            ),
          ),
      ],
    );
  }
}

// ── Aggregated winner banner ─────────────────────────────────────────────────

class _AggregatedWinnerBanner extends StatelessWidget {
  const _AggregatedWinnerBanner({required this.winner});

  final String winner;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.auto_awesome_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Settled reading',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withAlpha(140),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  winner,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    letterSpacing: -0.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    required this.onPermutationsTap,
    this.selectedImageBytes,
  });

  final List<BaybayinDetection> detections;
  final bool flashOn;
  final void Function(List<BaybayinDetection>) onDetections;
  final VoidCallback? onFlashToggle;
  final Uint8List? selectedImageBytes;
  final void Function(List<String> permutations) onPermutationsTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (selectedImageBytes != null)
          Image.memory(selectedImageBytes!, fit: BoxFit.cover)
        else
          ScannerCamera(
            flashOn: flashOn,
            onDetections: onDetections,
            onFlashToggle: onFlashToggle,
          ),
        AggregatedBoundingBox(
          detections: detections,
          onPermutationsTap: onPermutationsTap,
        ),
      ],
    );
  }
}

// ── Controls ──────────────────────────────────────────────────────────────────

class _ScanControls extends StatelessWidget {
  const _ScanControls({
    required this.flashOn,
    required this.onShutter,
    required this.onFlashToggle,
    required this.onGalleryTap,
  });

  final bool flashOn;
  final VoidCallback onShutter;
  final VoidCallback? onFlashToggle;
  final VoidCallback onGalleryTap;

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
                  GestureDetector(
                    onTap: onGalleryTap,
                    child: const _ControlIcon(icon: Icons.image_outlined),
                  ),
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

class _ScanResultPanel extends ConsumerStatefulWidget {
  const _ScanResultPanel({required this.detections, required this.onDismiss});

  final List<BaybayinDetection> detections;
  final VoidCallback onDismiss;

  @override
  ConsumerState<_ScanResultPanel> createState() => _ScanResultPanelState();
}

class _ScanResultPanelState extends ConsumerState<_ScanResultPanel> {
  int _index = 0;

  static List<String> _tokensFor(List<BaybayinDetection> dets) {
    final List<BaybayinDetection> ordered = List<BaybayinDetection>.of(dets)
      ..sort(
        (BaybayinDetection a, BaybayinDetection b) => a.left.compareTo(b.left),
      );
    return ordered
        .map((BaybayinDetection d) => d.label.trim().toLowerCase())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<String> get _tokens => _tokensFor(widget.detections);
  List<String> get _permutations => permuteBaybayin(_tokens);

  @override
  void didUpdateWidget(covariant _ScanResultPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(_tokensFor(oldWidget.detections), _tokens)) {
      _index = 0;
    }
  }

  void _prev() {
    final List<String> p = _permutations;
    if (p.length <= 1) return;
    setState(() => _index = (_index - 1 + p.length) % p.length);
  }

  void _next() {
    final List<String> p = _permutations;
    if (p.length <= 1) return;
    setState(() => _index = (_index + 1) % p.length);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<String> tokens = _tokens;
    final List<String> perms = _permutations;
    final String current = perms.isEmpty
        ? ''
        : perms[_index.clamp(0, perms.length - 1)];
    final String tokenPreview = tokens.isEmpty ? '' : tokens.join(' · ');

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
              Expanded(
                child: _ResultText(
                  current: current,
                  tokenPreview: tokenPreview,
                ),
              ),
              const SizedBox(width: 12),
              _ResultActions(
                onCopy: perms.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: current),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                onShare: perms.isEmpty
                    ? null
                    : () async {
                        final ScanEvalState evalState =
                            ref.read(scannerEvaluationProvider);
                        final String translation =
                            evalState.translation.value ?? '';
                        final StringBuffer sb = StringBuffer(
                          'Scanned Baybayin word: $current',
                        );
                        if (translation.isNotEmpty) {
                          sb
                            ..write('\n')
                            ..write(translation);
                        }
                        await SharePlus.instance.share(
                          ShareParams(text: sb.toString()),
                        );
                      },
                onSave: perms.isEmpty
                    ? null
                    : () {
                        final ScanEvalState evalState =
                            ref.read(scannerEvaluationProvider);
                        final String translation =
                            evalState.translation.value ?? '';
                        ref
                            .read(scanHistoryNotifierProvider.notifier)
                            .addResult(
                              ScanResult(
                                tokens: _tokens,
                                translation: translation,
                                timestamp: DateTime.now(),
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saved to history.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                onDismiss: widget.onDismiss,
              ),
            ],
          ),
          if (perms.length > 1) ...<Widget>[
            const SizedBox(height: 10),
            _PermutationCycler(
              index: _index,
              total: perms.length,
              onPrev: _prev,
              onNext: _next,
            ),
          ],
          const _ButtyTranslationArea(),
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
  const _ResultText({required this.current, required this.tokenPreview});

  final String current;
  final String tokenPreview;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          baybayifyWord(current),
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
          current.isEmpty ? '—' : current,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.15,
          ),
        ),
        if (tokenPreview.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            tokenPreview,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withAlpha(140),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _PermutationCycler extends StatelessWidget {
  const _PermutationCycler({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int index;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _CyclerButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPrev,
            tooltip: 'Previous reading',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Reading ${index + 1} of $total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withAlpha(200),
                letterSpacing: 0.2,
              ),
            ),
          ),
          _CyclerButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
            tooltip: 'Next reading',
          ),
        ],
      ),
    );
  }
}

class _CyclerButton extends StatelessWidget {
  const _CyclerButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: cs.onSurface),
        ),
      ),
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.onDismiss,
    this.onCopy,
    this.onShare,
    this.onSave,
  });

  final VoidCallback onDismiss;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ActionChip(icon: Icons.copy_rounded, onTap: onCopy),
        const SizedBox(width: 6),
        _ActionChip(icon: Icons.share_rounded, onTap: onShare),
        const SizedBox(width: 6),
        _ActionChip(icon: Icons.bookmark_add_outlined, onTap: onSave),
        const SizedBox(width: 6),
        _ActionChip(icon: Icons.close_rounded, onTap: onDismiss),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: GestureDetector(
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
      ),
    );
  }
}

// ── Butty translation area ────────────────────────────────────────────────────

class _ButtyTranslationArea extends ConsumerWidget {
  const _ButtyTranslationArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScanEvalState evalState = ref.watch(scannerEvaluationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 8),
        evalState.translation.when(
          loading: () => const TypingBubble(),
          data: (String text) => text.isEmpty
              ? const SizedBox.shrink()
              : ButtyBubble(text: text),
          error: (Object e, StackTrace s) => ButtyBubble(
            text: 'Ay nako, I had trouble reading that. Try again?',
          ),
        ),
        if (evalState.canRequestFollowUp) ...<Widget>[
          const SizedBox(height: 2),
          _TellMeMoreButton(
            onTap: () =>
                ref.read(scannerEvaluationProvider.notifier).requestFollowUp(),
          ),
        ],
        if (evalState.followUp != null) ...<Widget>[
          const SizedBox(height: 4),
          evalState.followUp!.when(
            loading: () => const TypingBubble(),
            data: (String text) => text.isEmpty
                ? const SizedBox.shrink()
                : ButtyBubble(text: text),
            error: (Object e, StackTrace s) => const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}

class _TellMeMoreButton extends StatelessWidget {
  const _TellMeMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withAlpha(100),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: cs.primary.withAlpha(80)),
          ),
          child: Text(
            'Tell me more',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Permutations dialog ───────────────────────────────────────────────────────

class _PermutationsDialog extends StatelessWidget {
  const _PermutationsDialog({required this.permutations});

  final List<String> permutations;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: cs.surfaceContainerHigh,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 480, maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _PermDialogHeader(count: permutations.length),
            const Divider(height: 1),
            Flexible(child: _PermDialogList(permutations: permutations)),
            const Divider(height: 1),
            const _PermDialogFooter(),
          ],
        ),
      ),
    );
  }
}

class _PermDialogHeader extends StatelessWidget {
  const _PermDialogHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Possible readings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count interpretations of the detected glyphs',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermDialogList extends StatelessWidget {
  const _PermDialogList({required this.permutations});

  final List<String> permutations;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      itemCount: permutations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 2),
      itemBuilder: (BuildContext context, int i) =>
          _PermRow(text: permutations[i], index: i),
    );
  }
}

class _PermRow extends StatelessWidget {
  const _PermRow({required this.text, required this.index});

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Clipboard.setData(ClipboardData(text: text)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 28,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withAlpha(120),
                ),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.copy_rounded,
              size: 16,
              color: cs.onSurface.withAlpha(140),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermDialogFooter extends StatelessWidget {
  const _PermDialogFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
