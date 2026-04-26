import 'package:flutter/material.dart';

import 'mic_button.dart';
import 'text_input_box.dart';

class InputStrip extends StatelessWidget {
  const InputStrip({
    super.key,
    required this.controller,
    required this.listening,
    required this.onMicTap,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool listening;
  final VoidCallback onMicTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.paddingOf(context).bottom + 10,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: Row(
        children: <Widget>[
          MicButton(listening: listening, onTap: onMicTap),
          const SizedBox(width: 10),
          Expanded(
            child: TextInputBox(
              controller: controller,
              onChanged: onChanged,
              onClear: onClear,
              showClear: controller.text.isNotEmpty,
            ),
          ),
        ],
      ),
    );
  }
}
