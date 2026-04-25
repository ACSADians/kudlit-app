import 'package:flutter/material.dart';
import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/core/design_system/kudlit_theme.dart';

class KudlitHomePlaceholder extends StatelessWidget {
  const KudlitHomePlaceholder({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        _KudlitHeroBanner(email: email),
        const SizedBox(height: 24),
        const _KudlitSectionHeader(
          title: 'Learning Paths',
          action: 'Baybayin lessons and practice cards',
        ),
        const SizedBox(height: 16),
        const _KudlitCardRow(
          children: <Widget>[
            _FeatureCard(
              title: 'Guide to Baybayin',
              description: 'Start with vowels, consonants, and kudlit marks.',
              assetPath: 'assets/brand/baybayin.vowels.webp',
              chipLabel: 'Lesson',
            ),
            _FeatureCard(
              title: 'Quiz Challenges',
              description: 'Practice recognition with quick answer rounds.',
              assetPath: 'assets/brand/baybayin.multiplechoice.webp',
              chipLabel: 'Quiz',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _KudlitSectionHeader(
          title: 'Tools',
          action: 'Sample placeholders from the mobile kit',
        ),
        const SizedBox(height: 16),
        const _KudlitCardRow(
          children: <Widget>[
            _FeatureCard(
              title: 'Baybayin Scanner',
              description: 'Camera and detection overlay placeholder.',
              assetPath: 'assets/brand/ButtyRead.webp',
              chipLabel: 'Scanner',
            ),
            _FeatureCard(
              title: 'Transliterator',
              description: 'Romanized text to Baybayin conversion surface.',
              assetPath: 'assets/brand/TransliteratorHeader.webp',
              chipLabel: 'Translate',
            ),
            _FeatureCard(
              title: 'Progress',
              description:
                  'Keep lessons, streaks, and saved sessions together.',
              assetPath: 'assets/brand/ButtyPhone.webp',
              chipLabel: 'Profile',
            ),
          ],
        ),
      ],
    );
  }
}

class _KudlitHeroBanner extends StatelessWidget {
  const _KudlitHeroBanner({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 700;

            return stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _KudlitHeroCopy(email: email),
                      const SizedBox(height: 24),
                      Center(
                        child: Image.asset(
                          'assets/brand/ButtyWave.webp',
                          height: 180,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Expanded(child: _KudlitHeroCopy(email: email)),
                      const SizedBox(width: 24),
                      Image.asset('assets/brand/ButtyWave.webp', height: 220),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _KudlitHeroCopy extends StatelessWidget {
  const _KudlitHeroCopy({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('ᜃᜓᜇ᜔ᜎᜒᜆ᜔', style: KudlitTheme.baybayinDisplay(context)),
        const SizedBox(height: 12),
        Text('Welcome back', style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          email.isEmpty ? 'Your learning setup is ready.' : email,
          style: textTheme.bodyLarge?.copyWith(
            color: KudlitColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'This placeholder home screen applies the Kudlit Design System to '
          'the app shell while scanner, translator, and learning features are '
          'still being built.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _KudlitSectionHeader extends StatelessWidget {
  const _KudlitSectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Text(action, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _KudlitCardRow extends StatelessWidget {
  const _KudlitCardRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 16, runSpacing: 16, children: children);
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.chipLabel,
  });

  final String title;
  final String description;
  final String assetPath;
  final String chipLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              Chip(label: Text(chipLabel)),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
