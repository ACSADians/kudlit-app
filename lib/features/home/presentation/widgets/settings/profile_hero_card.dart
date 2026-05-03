import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';

import 'edit_name_dialog.dart';
import 'profile_hero_avatar.dart';
import 'profile_stats_bar.dart';

class ProfileHeroCard extends ConsumerStatefulWidget {
  const ProfileHeroCard({super.key, required this.user});

  final AuthUser user;

  @override
  ConsumerState<ProfileHeroCard> createState() => _ProfileHeroCardState();
}

class _ProfileHeroCardState extends ConsumerState<ProfileHeroCard> {
  bool _isEditingName = false;

  String _initials(String name, String email) {
    final String src = name.isNotEmpty ? name : email;
    return src[0].toUpperCase();
  }

  Future<void> _openEditNameDialog(String currentName) async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(initialName: currentName),
    );

    if (newName == null || newName.trim() == currentName || !mounted) return;

    setState(() => _isEditingName = true);
    await ref
        .read(profileSummaryNotifierProvider.notifier)
        .updateDisplayName(newName.trim());

    if (!mounted) return;
    setState(() => _isEditingName = false);

    final s = ref.read(profileSummaryNotifierProvider);
    if (s.hasError) {
      _showError(s.error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name updated.')),
      );
    }
  }

  void _showError(Object? error) {
    String message = error.toString();
    if (error is Failure) {
      message = error.when(
        network: (String m) => m,
        unknown: (String m) => m,
        invalidCredentials: () => 'Invalid credentials',
        userNotFound: () => 'User not found',
        emailAlreadyInUse: () => 'Email already in use',
        weakPassword: () => 'Weak password',
        tooManyRequests: () => 'Too many requests',
        sessionExpired: () => 'Session expired',
        passwordResetEmailSent: () => 'Email sent',
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update name: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final summary = ref
        .watch(profileSummaryNotifierProvider)
        .value
        ?.toNullable();
    final String displayName =
        summary?.displayName ?? widget.user.displayName ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: <Widget>[
          ProfileHeroAvatar(
            initials: _initials(displayName, widget.user.email),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avatar upload coming soon.')),
            ),
          ),
          const SizedBox(height: 14),
          _NameRow(
            displayName: displayName,
            isLoading: _isEditingName,
            onEdit: () => _openEditNameDialog(displayName),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withAlpha(140),
            ),
          ),
          const SizedBox(height: 18),
          ProfileStatsBar(
            lessons: summary?.completedLessons ?? 0,
            scans: summary?.scanHistoryItems ?? 0,
            translations: summary?.translationHistoryItems ?? 0,
          ),
        ],
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.displayName,
    required this.isLoading,
    required this.onEdit,
  });

  final String displayName;
  final bool isLoading;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
      );
    }

    return GestureDetector(
      onTap: onEdit,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            displayName.isNotEmpty ? displayName : 'Set display name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: displayName.isNotEmpty
                  ? cs.onSurface
                  : cs.onSurface.withAlpha(120),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.edit_outlined, size: 15, color: cs.primary),
        ],
      ),
    );
  }
}
