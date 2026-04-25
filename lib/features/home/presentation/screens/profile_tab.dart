import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';

/// Profile tab — shows user info when authenticated, or a sign-in prompt for guests.
class ProfileTab extends StatelessWidget {
  const ProfileTab({this.user, super.key});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KudlitColors.blue900,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/brand/ButtyWave.webp', width: 120, height: 120),
          const SizedBox(height: 20),
          const Text(
            'Kumusta, Bisita!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: KudlitColors.blue300,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create an account to save your progress\nand access your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: KudlitColors.grey200,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onSignIn,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: KudlitColors.blue300,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x40172F69),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Sign In or Create Account',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: KudlitColors.blue900,
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
              border: Border.all(color: KudlitColors.blue400, width: 2.5),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: KudlitColors.blue300,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Logged in',
            style: TextStyle(fontSize: 12.5, color: KudlitColors.grey200),
          ),
        ],
      ),
    );
  }
}
