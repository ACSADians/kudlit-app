import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    required this.title,
    required this.subtitle,
    required this.lastUpdated,
    required this.summaryTitle,
    required this.summary,
    required this.sections,
    this.relatedAction,
    super.key,
  });

  final String title;
  final String subtitle;
  final String lastUpdated;
  final String summaryTitle;
  final String summary;
  final List<LegalSectionData> sections;
  final LegalRelatedAction? relatedAction;

  void _goBack(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go(AppConstants.routeLogin);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppConstants.backToLoginAction,
          onPressed: () => _goBack(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(title),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool wide = constraints.maxWidth >= 720;
              final EdgeInsets padding = EdgeInsets.fromLTRB(
                wide ? 28 : 16,
                18,
                wide ? 28 : 16,
                28,
              );

              return SingleChildScrollView(
                padding: padding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _LegalHero(
                          title: title,
                          subtitle: subtitle,
                          lastUpdated: lastUpdated,
                          summaryTitle: summaryTitle,
                          summary: summary,
                        ),
                        const SizedBox(height: 14),
                        for (int index = 0; index < sections.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LegalSectionCard(
                              index: index + 1,
                              section: sections[index],
                            ),
                          ),
                        if (relatedAction != null) ...<Widget>[
                          const SizedBox(height: 2),
                          _RelatedLegalAction(action: relatedAction!),
                        ],
                        const SizedBox(height: 20),
                        _LegalFootnote(title: title),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LegalSectionData {
  const LegalSectionData({
    required this.title,
    required this.body,
    this.points = const <String>[],
  });

  final String title;
  final String body;
  final List<String> points;
}

class LegalRelatedAction {
  const LegalRelatedAction({required this.label, required this.route});

  final String label;
  final String route;
}

class _LegalHero extends StatelessWidget {
  const _LegalHero({
    required this.title,
    required this.subtitle,
    required this.lastUpdated,
    required this.summaryTitle,
    required this.summary,
  });

  final String title;
  final String subtitle;
  final String lastUpdated;
  final String summaryTitle;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(subtitle, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoPill(
              icon: Icons.event_available_outlined,
              text: 'Last updated: $lastUpdated',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(summaryTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(summary, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({required this.index, required this.section});

  final int index;
  final LegalSectionData section;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  label: 'Section $index',
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$index',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(section.title, style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(section.body, style: theme.textTheme.bodyMedium),
            if (section.points.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              for (final String point in section.points)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LegalBullet(text: point),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegalBullet extends StatelessWidget {
  const _LegalBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _RelatedLegalAction extends StatelessWidget {
  const _RelatedLegalAction({required this.action});

  final LegalRelatedAction action;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.go(action.route),
      icon: const Icon(Icons.description_outlined),
      label: Text(action.label),
    );
  }
}

class _LegalFootnote extends StatelessWidget {
  const _LegalFootnote({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodySmall;

    return Text(
      '$title is written in plain language for the Kudlit app experience. '
      'For formal legal interpretation, ask a qualified professional.',
      textAlign: TextAlign.center,
      style: style,
    );
  }
}
