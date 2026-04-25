import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Gradient hero card at the top of the home tab.
class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({required this.isGuest, this.userName, super.key});

  final bool isGuest;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-1, -0.6),
          end: Alignment(1, 1),
          colors: <Color>[KudlitColors.blue300, KudlitColors.blue400],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40172F69),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          const Positioned(
            right: -8,
            bottom: -22,
            child: Text(
              'ka',
              style: TextStyle(
                fontFamily: 'Baybayin Simple TAWBID',
                fontSize: 110,
                color: Color(0x12FFFFFF),
                height: 1,
              ),
            ),
          ),
          _BannerContent(isGuest: isGuest, userName: userName),
        ],
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({required this.isGuest, this.userName});

  final bool isGuest;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: _BannerTextColumn(isGuest: isGuest, userName: userName),
        ),
        const SizedBox(width: 12),
        Image.asset(
          isGuest
              ? 'assets/brand/ButtyWave.webp'
              : 'assets/brand/user.profile/butty.thumbsup.webp',
          width: 78,
          height: 78,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _BannerTextColumn extends StatelessWidget {
  const _BannerTextColumn({required this.isGuest, this.userName});

  final bool isGuest;
  final String? userName;

  String get _displayName => userName ?? 'Explorer';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isGuest ? 'Browsing as Guest' : 'Mabuhay 👋',
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xCCE9EEFF),
            letterSpacing: 0.06,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          isGuest ? 'Kumusta, Bisita!' : 'Kumusta, $_displayName!',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: KudlitColors.blue900,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          isGuest
              ? 'Explore the app. Sign in to save your work.'
              : 'What would you like to do today?',
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xE0E9EEFF),
            height: 1.4,
          ),
        ),
        if (isGuest) ...<Widget>[
          const SizedBox(height: 10),
          const _CreateAccountCta(),
        ],
      ],
    );
  }
}

class _CreateAccountCta extends StatelessWidget {
  const _CreateAccountCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Create Free Account',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
        ],
      ),
    );
  }
}
