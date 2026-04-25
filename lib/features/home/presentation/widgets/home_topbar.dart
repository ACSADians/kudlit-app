import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// App top bar shown on the home/dashboard screen.
class HomeTopbar extends StatelessWidget {
  const HomeTopbar({required this.isGuest, super.key});

  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: KudlitColors.blue500,
        border: Border(
          bottom: BorderSide(color: KudlitColors.blue400, width: 1.25),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x1A0E1425),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          const _AppIconCenter(),
          const Align(alignment: Alignment.centerLeft, child: _MenuButton()),
          Align(
            alignment: Alignment.centerRight,
            child: isGuest ? const _SignInButton() : const _AvatarButton(),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: KudlitColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KudlitColors.blue400, width: 1.25),
      ),
      child: const Icon(
        Icons.menu_rounded,
        size: 18,
        color: KudlitColors.blue300,
      ),
    );
  }
}

class _AppIconCenter extends StatelessWidget {
  const _AppIconCenter();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/brand/BaybayInscribe-AppIcon.webp',
        width: 36,
        height: 36,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: KudlitColors.paper,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: KudlitColors.blue400, width: 1.25),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.login_rounded, size: 13, color: KudlitColors.blue300),
          SizedBox(width: 5),
          Text(
            'Sign In',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: KudlitColors.blue300,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KudlitColors.blue800, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/brand/user.profile/butty.thumbsup.webp',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
