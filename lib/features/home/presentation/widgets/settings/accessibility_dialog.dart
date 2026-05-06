import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';

class AccessibilityDialog extends StatefulWidget {
  const AccessibilityDialog({super.key, required this.current});

  final ProfilePreferences current;

  @override
  State<AccessibilityDialog> createState() => _AccessibilityDialogState();
}

class _AccessibilityDialogState extends State<AccessibilityDialog> {
  late bool _highContrast;
  late bool _reducedMotion;

  @override
  void initState() {
    super.initState();
    _highContrast = widget.current.highContrast;
    _reducedMotion = widget.current.reducedMotion;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Accessibility'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('High Contrast'),
                subtitle: const Text('Increases text and icon contrast.'),
                value: _highContrast,
                onChanged: (bool val) => setState(() => _highContrast = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reduced Motion'),
                subtitle: const Text('Limits animations and transitions.'),
                value: _reducedMotion,
                onChanged: (bool val) => setState(() => _reducedMotion = val),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            ProfilePreferences(
              highContrast: _highContrast,
              reducedMotion: _reducedMotion,
              dataSharingConsent: widget.current.dataSharingConsent,
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
