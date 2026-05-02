import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/home_section_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/home_tool_card.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/home_topbar.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/lesson_preview_card.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/welcome_banner.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({this.user, this.onScanTap, this.onTranslateTap, super.key});

  final AuthUser? user;
  final VoidCallback? onScanTap;
  final VoidCallback? onTranslateTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const _HomeBackground(),
        SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              HomeTopbar(isGuest: user == null),
              Expanded(
                child: _HomeFeed(
                  user: user,
                  onScanTap: onScanTap,
                  onTranslateTap: onTranslateTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        image: const DecorationImage(
          image: AssetImage('assets/brand/BaybayInscribe-BackgroundImage.webp'),
          fit: BoxFit.cover,
          opacity: 0.12,
        ),
      ),
    );
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed({this.user, this.onScanTap, this.onTranslateTap});

  final AuthUser? user;
  final VoidCallback? onScanTap;
  final VoidCallback? onTranslateTap;

  String get _userName {
    final String? email = user?.email;
    if (email == null) return 'Explorer';
    final int atIndex = email.indexOf('@');
    return atIndex > 0 ? email.substring(0, atIndex) : email;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          WelcomeBanner(isGuest: user == null, userName: _userName),
          const HomeSectionHeader(title: 'Tools'),
          _ToolsRow(onScanTap: onScanTap, onTranslateTap: onTranslateTap),
          const HomeSectionHeader(
            title: 'Guide to Baybayin',
            action: 'See all',
          ),
          const _LessonsGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ToolsRow extends StatelessWidget {
  const _ToolsRow({this.onScanTap, this.onTranslateTap});

  final VoidCallback? onScanTap;
  final VoidCallback? onTranslateTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: HomeToolCard(
                icon: Icons.document_scanner_outlined,
                title: 'Baybayin Scanner',
                description:
                    'Point your camera at Baybayin script for an instant reading.',
                accentColor: KudlitColors.blue300,
                onTap: onScanTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: HomeToolCard(
                icon: Icons.translate_rounded,
                title: 'Transliterator',
                description:
                    'Type in Latin script and see it in Baybayin — and back.',
                accentColor: KudlitColors.blue500,
                onTap: onTranslateTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonsGrid extends StatelessWidget {
  const _LessonsGrid();

  static const List<_LessonDef> _lessons = <_LessonDef>[
    _LessonDef(
      title: 'Vowels',
      tag: 'Start Here',
      description: 'The three foundational Baybayin vowels: A, E/I, O/U.',
      imageAsset: 'assets/brand/baybayin.vowels.webp',
    ),
    _LessonDef(
      title: 'Consonants',
      tag: null,
      description: '14 base consonants with a default "a" vowel sound.',
      imageAsset: 'assets/brand/baybayin.consonant.webp',
    ),
    _LessonDef(
      title: 'Kudlit Marks',
      tag: null,
      description: 'Small diacritical marks that change vowel sounds.',
      imageAsset: 'assets/brand/baybayin.kudlit.webp',
    ),
    _LessonDef(
      title: 'Coming Soon',
      tag: 'Soon',
      description: 'More lessons on Baybayin writing are on the way.',
      imageAsset: 'assets/brand/baybayin.comingsoon.webp',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          for (final _LessonDef l in _lessons)
            LessonPreviewCard(
              title: l.title,
              description: l.description,
              imageAsset: l.imageAsset,
              tag: l.tag,
            ),
        ],
      ),
    );
  }
}

class _LessonDef {
  const _LessonDef({
    required this.title,
    required this.description,
    required this.imageAsset,
    this.tag,
  });

  final String title;
  final String description;
  final String imageAsset;
  final String? tag;
}
