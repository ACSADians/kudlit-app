import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/streak_provider.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn_home/butty_talk_card.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn_home/learn_section_label.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn_home/lesson_card.dart';

const List<String> _lessonOrder = <String>[
  'vowels-01',
  'consonants-01',
  'consonants-02',
  'consonants-03',
  'consonants-04',
  'kudlit-01',
];

class LearnHomeBody extends ConsumerWidget {
  const LearnHomeBody({
    super.key,
    required this.onStartLesson,
    required this.onChatWithButty,
    required this.onOpenGallery,
    required this.onStartQuiz,
    required this.bottomPad,
  });

  final void Function(String) onStartLesson;
  final VoidCallback onChatWithButty;
  final VoidCallback onOpenGallery;
  final VoidCallback onStartQuiz;
  final double bottomPad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<String> completed = ref
        .watch(appPreferencesNotifierProvider)
        .maybeWhen(
          data: (AppPreferences p) => p.completedLessons,
          orElse: () => const <String>{},
        );

    final int streakCount = ref.watch(streakProvider).value ?? 0;

    bool locked(int lessonIndex) {
      if (lessonIndex == 0) return false;
      return !completed.contains(_lessonOrder[lessonIndex - 1]);
    }

    final bool hasCompletedAny = completed.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomPad + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ButtyTalkCard(onTap: onChatWithButty),
          const SizedBox(height: 16),
          _QuickActionsRow(
            streakCount: streakCount,
            hasCompletedAny: hasCompletedAny,
            onOpenGallery: onOpenGallery,
            onStartQuiz: onStartQuiz,
          ),
          const SizedBox(height: 20),
          const LearnSectionLabel(text: 'Lessons'),
          const SizedBox(height: 10),
          LessonCard(
            index: 1,
            title: 'Baybayin Basics',
            subtitle: '3 vowels',
            items: const <(String, String)>[
              ('a', 'A'),
              ('e', 'E / I'),
              ('o', 'O / U'),
            ],
            isLocked: locked(0),
            onStart: () => onStartLesson('vowels-01'),
          ),
          const SizedBox(height: 8),
          LessonCard(
            index: 2,
            title: 'Core Consonants',
            subtitle: 'Ba, Ka, Da/Ra, Ga',
            items: const <(String, String)>[
              ('b+', 'BA'),
              ('k+', 'KA'),
              ('d+', 'DA/RA'),
              ('g+', 'GA'),
            ],
            isLocked: locked(1),
            onStart: () => onStartLesson('consonants-01'),
          ),
          const SizedBox(height: 8),
          LessonCard(
            index: 3,
            title: 'The Waves',
            subtitle: 'Ha, La, Ma, Na',
            items: const <(String, String)>[
              ('h+', 'HA'),
              ('l+', 'LA'),
              ('m+', 'MA'),
              ('n+', 'NA'),
            ],
            isLocked: locked(2),
            onStart: () => onStartLesson('consonants-02'),
          ),
          const SizedBox(height: 8),
          LessonCard(
            index: 4,
            title: 'The Loops',
            subtitle: 'Nga, Pa, Sa, Ta',
            items: const <(String, String)>[
              ('ng', 'NGA'),
              ('p+', 'PA'),
              ('s+', 'SA'),
              ('t+', 'TA'),
            ],
            isLocked: locked(3),
            onStart: () => onStartLesson('consonants-03'),
          ),
          const SizedBox(height: 8),
          LessonCard(
            index: 5,
            title: 'The Tails',
            subtitle: 'Wa, Ya',
            items: const <(String, String)>[
              ('w+', 'WA'),
              ('y+', 'YA'),
            ],
            isLocked: locked(4),
            onStart: () => onStartLesson('consonants-04'),
          ),
          const SizedBox(height: 8),
          LessonCard(
            index: 6,
            title: 'The Kudlit',
            subtitle: 'Changing vowel sounds',
            items: const <(String, String)>[
              ('b', 'BA'),
              ('be', 'BE/BI'),
              ('bo', 'BO/BU'),
            ],
            isLocked: locked(5),
            onStart: () => onStartLesson('kudlit-01'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.streakCount,
    required this.hasCompletedAny,
    required this.onOpenGallery,
    required this.onStartQuiz,
  });

  final int streakCount;
  final bool hasCompletedAny;
  final VoidCallback onOpenGallery;
  final VoidCallback onStartQuiz;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        if (streakCount > 0) ...<Widget>[
          _StreakChip(count: streakCount, cs: cs),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onOpenGallery,
            icon: const Icon(Icons.grid_view_rounded, size: 16),
            label: const Text('All Glyphs'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonal(
            onPressed: hasCompletedAny ? onStartQuiz : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: const Text('Quick Quiz'),
          ),
        ),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.count, required this.cs});

  final int count;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '\u{1F525}',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: cs.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
