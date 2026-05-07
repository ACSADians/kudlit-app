import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> showKudlitAboutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return const KudlitAboutDialog();
    },
  );
}

class KudlitAboutDialog extends StatelessWidget {
  const KudlitAboutDialog({super.key});

  static const String version = '1.0.0 (1)';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return AlertDialog(
      backgroundColor: cs.surface,
      surfaceTintColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outline),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: <Widget>[
          const _KudlitAppIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kudlit',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: const _AboutContent(),
      actions: <Widget>[
        TextButton(
          onPressed: () => _showKudlitLicenseDialog(context),
          child: const Text('Licenses'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _KudlitAppIcon extends StatelessWidget {
  const _KudlitAppIcon();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: Image.asset(
        'assets/brand/BaybayInscribe-AppIcon.webp',
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              return Icon(Icons.translate_rounded, color: cs.primary);
            },
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Version ${KudlitAboutDialog.version}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withAlpha(150),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Kudlit is a vision-based Baybayin translator and learning app '
          'designed to preserve and promote Philippine script using AI.',
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 16),
        Text(
          'Copyright 2026 Kudlit Team',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withAlpha(130),
          ),
        ),
      ],
    );
  }
}

Future<void> _showKudlitLicenseDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return const _KudlitLicenseDialog();
    },
  );
}

class _KudlitLicenseDialog extends StatelessWidget {
  const _KudlitLicenseDialog();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double width = math.min(420, math.max(280, size.width - 64));
    final double height = math.min(520, size.height * 0.62);
    final ColorScheme cs = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: cs.surface,
      surfaceTintColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outline),
      ),
      title: const Text('Open Source Licenses'),
      content: SizedBox(
        width: width,
        height: height,
        child: FutureBuilder<List<LicenseEntry>>(
          future: LicenseRegistry.licenses.toList(),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<LicenseEntry>> snapshot,
              ) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<LicenseEntry> licenses =
                    snapshot.data ?? <LicenseEntry>[];
                return _LicenseList(licenses: licenses);
              },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _LicenseList extends StatelessWidget {
  const _LicenseList({required this.licenses});

  final List<LicenseEntry> licenses;

  @override
  Widget build(BuildContext context) {
    if (licenses.isEmpty) {
      return const Center(child: Text('No license entries found.'));
    }

    return ListView.separated(
      itemCount: licenses.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (BuildContext context, int index) {
        return _LicenseEntryTile(entry: licenses[index]);
      },
    );
  }
}

class _LicenseEntryTile extends StatelessWidget {
  const _LicenseEntryTile({required this.entry});

  final LicenseEntry entry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String packages = entry.packages.join(', ');
    final String body = entry.paragraphs
        .map((LicenseParagraph paragraph) => paragraph.text)
        .join('\n\n');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              packages.isEmpty ? 'License' : packages,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
