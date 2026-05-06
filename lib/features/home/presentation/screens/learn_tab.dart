import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn_home/ocean_bubble_background.dart';
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
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[const Color(0xFFD8EDFF), surfaceColor],
          stops: const <double>[0.0, 0.55],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: IgnorePointer(child: OceanBubbleBackground()),
          ),
          LearnHomeBody(
            onStartLesson: (String lessonId) =>
                _startLesson(context, lessonId),
            onChatWithButty: onSwitchToButty,
            onOpenGallery: () =>
                context.push(AppConstants.routeCharacterGallery),
            onStartQuiz: () => context.push(AppConstants.routeQuiz),
            bottomPad: bottomPad,
          ),
        ],
      ),
    );
  }
}
