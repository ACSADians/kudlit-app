import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';
import 'learn_home_body.dart';

class LearnTab extends StatelessWidget {
  const LearnTab({super.key, required this.onSwitchToButty});

  final VoidCallback onSwitchToButty;

  void _startLesson(BuildContext context, String lessonId) {
    context.push('${AppConstants.routeLesson}/$lessonId');
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPad =
        MediaQuery.paddingOf(context).bottom + kFloatingNavClearance;

    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: LearnHomeBody(
        onStartLesson: (String lessonId) => _startLesson(context, lessonId),
        onChatWithButty: onSwitchToButty,
        onOpenGallery: () => context.push(AppConstants.routeCharacterGallery),
        onStartQuiz: () => context.push(AppConstants.routeQuiz),
        bottomPad: bottomPad,
      ),
    );
  }
}
