import 'package:flutter/material.dart';

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
    // TODO: replace with actual transliteration logic
    final String text = _controller.text.trim().toLowerCase();
    if (text.isEmpty) return '';
    return text; // rendered with Baybayin font, font handles display
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0E1220),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const _TranslateHeader(),
            _DirectionToggle(
              latinToBaybayin: _latinToBaybayin,
              onToggle: (bool v) => setState(() => _latinToBaybayin = v),
            ),
            Expanded(
              child: _OutputStage(
                baybayinText: _baybayinOutput,
                latinText: _controller.text.trim(),
                hasInput: _controller.text.trim().isNotEmpty,
              ),
            ),
            _InputStrip(
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

// ── Header ───────────────────────────────────────────────────────────────────

class _TranslateHeader extends StatelessWidget {
  const _TranslateHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Text(
        'Transliterator',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ── Direction toggle ──────────────────────────────────────────────────────────

class _DirectionToggle extends StatelessWidget {
  const _DirectionToggle({
    required this.latinToBaybayin,
    required this.onToggle,
  });

  final bool latinToBaybayin;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _TogglePill(
                label: 'Latin → Baybayin',
                active: latinToBaybayin,
                onTap: () => onToggle(true),
              ),
              _TogglePill(
                label: 'Baybayin → Latin',
                active: !latinToBaybayin,
                onTap: () => onToggle(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}

// ── Output stage ──────────────────────────────────────────────────────────────

class _OutputStage extends StatelessWidget {
  const _OutputStage({
    required this.baybayinText,
    required this.latinText,
    required this.hasInput,
  });

  final String baybayinText;
  final String latinText;
  final bool hasInput;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: hasInput
            ? _FilledOutput(baybayin: baybayinText, latin: latinText)
            : const _EmptyOutput(),
      ),
    );
  }
}

class _FilledOutput extends StatelessWidget {
  const _FilledOutput({required this.baybayin, required this.latin});

  final String baybayin;
  final String latin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          baybayin,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Baybayin Simple TAWBID',
            fontSize: 54,
            color: Colors.white,
            letterSpacing: 10,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(width: 40, height: 1.5, color: Colors.white24),
        const SizedBox(height: 14),
        Text(
          latin,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xBFFFFFFF),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 24),
        _OutputActions(),
      ],
    );
  }
}

class _EmptyOutput extends StatelessWidget {
  const _EmptyOutput();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const <Widget>[
        Icon(Icons.text_fields_rounded, size: 36, color: Colors.white24),
        SizedBox(height: 10),
        Text(
          'Type or speak below\nto see Baybayin',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white38, height: 1.4),
        ),
      ],
    );
  }
}

class _OutputActions extends StatelessWidget {
  const _OutputActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _OutputActionPill(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _OutputActionPill(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () {},
        ),
      ],
    );
  }
}

class _OutputActionPill extends StatelessWidget {
  const _OutputActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 13, color: Colors.white54),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Input strip ───────────────────────────────────────────────────────────────

class _InputStrip extends StatelessWidget {
  const _InputStrip({
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
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0x0DFFFFFF),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: <Widget>[
          _MicButton(listening: listening, onTap: onMicTap),
          const SizedBox(width: 10),
          Expanded(
            child: _TextInputBox(
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

class _MicButton extends StatelessWidget {
  const _MicButton({required this.listening, required this.onTap});

  final bool listening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: listening ? const Color(0xFF9C2F2F) : Colors.white10,
          border: Border.all(
            color: listening ? Colors.red.withAlpha(128) : Colors.white24,
          ),
          boxShadow: listening
              ? const <BoxShadow>[
                  BoxShadow(color: Color(0x66FF5040), blurRadius: 16),
                ]
              : null,
        ),
        child: Icon(
          Icons.mic_rounded,
          size: 20,
          color: listening ? Colors.white : Colors.white70,
        ),
      ),
    );
  }
}

class _TextInputBox extends StatelessWidget {
  const _TextInputBox({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.showClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 15, color: Color(0xBFFFFFFF)),
              decoration: const InputDecoration.collapsed(
                hintText: 'Type in Latin…',
                hintStyle: TextStyle(fontSize: 15, color: Colors.white38),
              ),
            ),
          ),
          if (showClear)
            GestureDetector(
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white30,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
