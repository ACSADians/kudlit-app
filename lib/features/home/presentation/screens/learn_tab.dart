import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/lesson_detail_card.dart';

/// Baybayin learning guide screen — full-width lesson cards.
class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  static const List<_LessonData> _lessons = <_LessonData>[
    _LessonData(
      title: 'Vowels',
      subtitle: 'A · E/I · O/U',
      description:
          'The three foundational Baybayin vowels — the starting point for every learner.',
      imageAsset: 'assets/brand/baybayin.vowels.webp',
      glyph: 'a',
      tag: 'Start here',
    ),
    _LessonData(
      title: 'Consonants',
      subtitle: '14 base characters',
      description:
          'Each consonant carries a default "a" sound. Learn to recognize all 14.',
      imageAsset: 'assets/brand/baybayin.consonant.webp',
      glyph: 'ka',
      tag: null,
    ),
    _LessonData(
      title: 'Kudlit Marks',
      subtitle: 'Vowel diacritics',
      description:
          'Small marks above or below a consonant shift its vowel to "e/i" or "o/u".',
      imageAsset: 'assets/brand/baybayin.kudlit.webp',
      glyph: 'ki',
      tag: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const _LearnHeader(),
        Expanded(child: _LessonList(lessons: _lessons)),
      ],
    );
  }
}

class _LearnHeader extends StatelessWidget {
  const _LearnHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KudlitColors.blue300,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            SizedBox(height: 8),
            Text(
              'Guide to Baybayin',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: KudlitColors.blue900,
                letterSpacing: -0.15,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Three lessons. That\'s all you need.',
              style: TextStyle(fontSize: 12, color: Color(0xA6E9EEFF)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({required this.lessons});

  final List<_LessonData> lessons;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KudlitColors.paper,
      child: ListView(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + kFloatingNavClearance),
        children: <Widget>[
          for (final _LessonData l in lessons) ...<Widget>[
            LessonDetailCard(
              title: l.title,
              subtitle: l.subtitle,
              description: l.description,
              imageAsset: l.imageAsset,
              glyph: l.glyph,
              tag: l.tag,
            ),
            const SizedBox(height: 12),
          ],
          const _ComingSoonCard(),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KudlitColors.grey400, width: 1.5),
      ),
      child: const Column(
        children: <Widget>[
          Text(
            'More lessons coming soon',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KudlitColors.grey300,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "We're working on advanced Baybayin topics.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: KudlitColors.grey300),
          ),
        ],
      ),
    );
  }
}

class _LessonData {
  const _LessonData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageAsset,
    required this.glyph,
    this.tag,
  });

  final String title;
  final String subtitle;
  final String description;
  final String imageAsset;
  final String glyph;
  final String? tag;
}
