import 'package:flutter/material.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/core/design_system/kudlit_theme.dart';

class KudlitAuthShell extends StatelessWidget {
  const KudlitAuthShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.heroAsset = 'assets/brand/ButtyWave.webp',
    this.showBackButton = false,
    this.bottomText,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String heroAsset;
  final bool showBackButton;
  final String? bottomText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/brand/BaybayInscribe-BackgroundImage.webp',
            ),
            fit: BoxFit.cover,
            opacity: 0.16,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool wideLayout = constraints.maxWidth >= 900;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: wideLayout
                    ? Row(
                        children: <Widget>[
                          Expanded(
                            child: _KudlitAuthHero(
                              title: title,
                              subtitle: subtitle,
                              heroAsset: heroAsset,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _KudlitAuthCard(
                              bottomText: bottomText,
                              showBackButton: showBackButton,
                              child: child,
                            ),
                          ),
                        ],
                      )
                    : _KudlitAuthCard(
                        bottomText: bottomText,
                        showBackButton: showBackButton,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _KudlitAuthHero(
                              title: title,
                              subtitle: subtitle,
                              heroAsset: heroAsset,
                              compact: true,
                            ),
                            const SizedBox(height: 24),
                            child,
                          ],
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

class _KudlitAuthHero extends StatelessWidget {
  const _KudlitAuthHero({
    required this.title,
    required this.subtitle,
    required this.heroAsset,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final String heroAsset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'ᜃᜓᜇ᜔ᜎᜒᜆ᜔',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: KudlitTheme.baybayinDisplay(context),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(
            subtitle,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: textTheme.bodyLarge?.copyWith(
              color: KudlitColors.mutedForeground,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: compact ? 180 : 260,
          height: compact ? 180 : 260,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: KudlitColors.borderSoft),
          ),
          padding: const EdgeInsets.all(16),
          child: Image.asset(heroAsset, fit: BoxFit.contain),
        ),
      ],
    );
  }
}

class _KudlitAuthCard extends StatelessWidget {
  const _KudlitAuthCard({
    required this.child,
    required this.showBackButton,
    this.bottomText,
  });

  final Widget child;
  final bool showBackButton;
  final String? bottomText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (showBackButton)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text(AppConstants.backToLoginAction),
                    ),
                  ),
                child,
                if (bottomText != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    bottomText!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
