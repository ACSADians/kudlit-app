import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';

const String _learnHomeLocation = '${AppConstants.routeHome}?tab=learn';

void returnToLearn(BuildContext context) {
  final NavigatorState navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }

  context.go(_learnHomeLocation);
}

class LearnRouteBackButton extends StatelessWidget {
  const LearnRouteBackButton({super.key, this.tooltip = 'Back to Learn'});

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: IconButton(
        tooltip: tooltip,
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => returnToLearn(context),
      ),
    );
  }
}
