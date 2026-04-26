import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/utils/baybayify.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/direction_toggle.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/input_strip.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/output_stage.dart';

/// Latin ↔ Baybayin transliterator screen.
/// Pushed from the Home tab tools section.
class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _latinToBaybayin = true;
  bool _listening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _baybayinOutput {
    final String text = _controller.text.trim();
    if (text.isEmpty) return '';
    return _latinToBaybayin ? baybayifyWord(text) : text;
  }

  String get _latinOutput {
    final String text = _controller.text.trim();
    if (text.isEmpty) return '';
    return _latinToBaybayin ? text : baybayinToLatin(text);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: OutputStage(
                baybayinText: _baybayinOutput,
                latinText: _latinOutput,
                hasInput: _controller.text.trim().isNotEmpty,
              ),
            ),
            DirectionToggle(
              latinToBaybayin: _latinToBaybayin,
              onToggle: (bool v) => setState(() => _latinToBaybayin = v),
            ),
            InputStrip(
              controller: _controller,
              listening: _listening,
              onMicTap: () => setState(() => _listening = !_listening),
              onChanged: (_) => setState(() {}),
              onClear: () => setState(() => _controller.clear()),
            ),
          ],
        ),
      ),
    );
  }
}
