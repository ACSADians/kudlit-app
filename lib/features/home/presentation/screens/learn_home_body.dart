import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/widgets/learn_home/butty_talk_card.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn_home/learn_section_label.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn_home/lesson_card.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn_home/locked_card.dart';

class LearnHomeBody extends StatelessWidget {
  const LearnHomeBody({
    super.key,
    required this.onStart,
    required this.onChatWithButty,
    required this.bottomPad,
  });

  final VoidCallback onStart;
  final VoidCallback onChatWithButty;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomPad + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ButtyTalkCard(onTap: onChatWithButty),
          const SizedBox(height: 24),
          const LearnSectionLabel(text: 'Lessons'),
          const SizedBox(height: 10),
          LessonCard(onStart: onStart),
          const SizedBox(height: 8),
          const LockedCard(
            index: 2,
            title: 'Core Consonants',
            subtitle: 'DA, GA, HA, LA, MA, NA and more',
          ),
          const SizedBox(height: 8),
          const LockedCard(
            index: 3,
            title: 'Kudlit — Diacritics',
            subtitle: 'Modify consonants to change vowel sounds',
          ),
        ],
      ),
    );
  }
}
