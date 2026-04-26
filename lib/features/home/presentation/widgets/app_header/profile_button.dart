import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push(AppConstants.routeSettings),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.primaryContainer,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/brand/user.profile/butty.thumbsup.webp',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
