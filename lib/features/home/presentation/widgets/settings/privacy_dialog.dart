import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';

class PrivacyDialog extends StatefulWidget {
  const PrivacyDialog({super.key, required this.current});

  final ProfilePreferences current;

  @override
  State<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  late bool _consent;

  @override
  void initState() {
    super.initState();
    _consent = widget.current.dataSharingConsent;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Share Analytics Data'),
            subtitle: const Text(
              'Help improve Kudlit by sharing anonymous usage data.',
            ),
            value: _consent,
            onChanged: (bool val) => setState(() => _consent = val),
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
              highContrast: widget.current.highContrast,
              reducedMotion: widget.current.reducedMotion,
              dataSharingConsent: _consent,
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
