import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'login_butty_area.dart';
import 'login_hero_wordmark.dart';
import 'login_language_toggle.dart';

/// Foreground content column inside the login hero.
class LoginHeroContent extends StatelessWidget {
  const LoginHeroContent({
    required this.buttyAsset,
    required this.bubbleText,
    this.showBackButton = false,
    this.showLanguageToggle = true,
    this.showButtyArea = true,
    super.key,
  });

  final String buttyAsset;
  final String bubbleText;
  final bool showBackButton;
  final bool showLanguageToggle;
  final bool showButtyArea;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: showBackButton
                        ? const _HeroBackButton()
                        : const SizedBox(width: 36, height: 44),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: showLanguageToggle
                        ? const LoginLanguageToggle()
                        : const SizedBox(width: 36, height: 44),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const LoginHeroWordmark(),
          if (showButtyArea)
            Expanded(
              child: LoginButtyArea(
                buttyAsset: buttyAsset,
                bubbleText: bubbleText,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}

class _HeroBackButton extends StatelessWidget {
  const _HeroBackButton();

  static const Set<String> _routerBackToLoginRoutes = <String>{
    AppConstants.routeSignUp,
    AppConstants.routeForgotPassword,
    AppConstants.routeAuthReset,
  };

  void _handleBack(BuildContext context) {
    final String? matchedLocation = _safeMatchedLocation(context);
    if (_routerBackToLoginRoutes.contains(matchedLocation)) {
      context.go(AppConstants.routeLogin);
      return;
    }

    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    _goToLoginIfAvailable(context);
  }

  String? _safeMatchedLocation(BuildContext context) {
    try {
      return GoRouterState.of(context).matchedLocation;
    } catch (_) {
      return null;
    }
  }

  void _goToLoginIfAvailable(BuildContext context) {
    try {
      context.go(AppConstants.routeLogin);
    } catch (_) {
      // Some widget tests mount the auth subpages outside GoRouter. In that
      // case there is no route fallback available, so the button safely no-ops.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppConstants.backToLoginAction,
      child: Semantics(
        button: true,
        label: AppConstants.backToLoginAction,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleBack(context),
            borderRadius: BorderRadius.circular(9999),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0x40FFFFFF)),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
