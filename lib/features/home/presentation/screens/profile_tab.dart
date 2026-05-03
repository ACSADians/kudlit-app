import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';

/// Profile tab — shows user info when authenticated, or a sign-in prompt for guests.
class ProfileTab extends StatelessWidget {
  const ProfileTab({this.user, super.key});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: user == null
            ? _GuestProfile(onSignIn: () => context.go(AppConstants.routeLogin))
            : _UserProfile(user: user!),
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/brand/ButtyWave.webp', width: 120, height: 120),
          const SizedBox(height: 20),
          Text(
            'Kumusta, Bisita!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create an account to save your progress\nand access your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: cs.onSurface.withAlpha(180),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onSignIn,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Sign In or Create Account',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserProfile extends StatelessWidget {
  const _UserProfile({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary, width: 2.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/brand/user.profile/butty.thumbsup.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Logged in',
            style: TextStyle(
              fontSize: 12.5,
              color: cs.onSurface.withAlpha(160),
            ),
          ),
        ],
      ),
    );
  }
}
