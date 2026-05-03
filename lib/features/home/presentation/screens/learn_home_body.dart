import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
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
    required this.bottomPad,
  });

  final void Function(String) onStartLesson;
  final VoidCallback onChatWithButty;
  final double bottomPad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<String> completed = ref
        .watch(appPreferencesNotifierProvider)
        .maybeWhen(
          data: (AppPreferences p) => p.completedLessons,
          orElse: () => const <String>{},
        );

    bool locked(int lessonIndex) {
      if (lessonIndex == 0) return false;
      return !completed.contains(_lessonOrder[lessonIndex - 1]);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomPad + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ButtyTalkCard(onTap: onChatWithButty),
          const SizedBox(height: 24),
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
