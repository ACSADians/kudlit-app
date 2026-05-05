import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';

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

class _UserProfile extends ConsumerWidget {
  const _UserProfile({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final ProfileSummary? summary = ref
        .watch(profileSummaryNotifierProvider)
        .value
        ?.toNullable();

    final String displayName =
        summary?.displayName ?? user.email.split('@').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(height: 14),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 12.5,
              color: cs.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 28),
          if (summary != null) ...<Widget>[
            _StatsRow(summary: summary, cs: cs),
            const SizedBox(height: 28),
          ],
          _ScanHistoryShortcut(cs: cs),
          const SizedBox(height: 12),
          _TranslationHistoryShortcut(cs: cs),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary, required this.cs});

  final ProfileSummary summary;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _StatCell(
          label: 'Scans',
          value: '${summary.scanHistoryItems}',
          cs: cs,
        ),
        _StatDivider(cs: cs),
        _StatCell(
          label: 'Lessons',
          value: '${summary.completedLessons}',
          cs: cs,
        ),
        _StatDivider(cs: cs),
        _StatCell(
          label: 'Saved',
          value: '${summary.bookmarkedTranslations}',
          cs: cs,
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.cs,
  });

  final String label;
  final String value;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: cs.onSurface.withAlpha(140),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: cs.outlineVariant,
    );
  }
}

class _ScanHistoryShortcut extends StatelessWidget {
  const _ScanHistoryShortcut({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppConstants.routeScanHistory),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 18,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Scanner History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'View all your past scans',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: cs.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurface.withAlpha(64),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslationHistoryShortcut extends StatelessWidget {
  const _TranslationHistoryShortcut({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppConstants.routeTranslationHistory),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.translate_rounded,
                size: 18,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Translation History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'View your past translations',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: cs.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurface.withAlpha(64),
            ),
          ],
        ),
      ),
    );
  }
}
