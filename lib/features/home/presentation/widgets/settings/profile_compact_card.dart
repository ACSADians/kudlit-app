import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';

import 'edit_name_dialog.dart';

class ProfileCompactCard extends ConsumerStatefulWidget {
  const ProfileCompactCard({super.key, required this.user});

  final AuthUser user;

  @override
  ConsumerState<ProfileCompactCard> createState() =>
      _ProfileCompactCardState();
}

class _ProfileCompactCardState extends ConsumerState<ProfileCompactCard> {
  bool _isSaving = false;

  Future<void> _openEditNameDialog(String currentName) async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(initialName: currentName),
    );

    if (newName == null || newName.trim() == currentName || !mounted) return;

    setState(() => _isSaving = true);
    await ref
        .read(profileSummaryNotifierProvider.notifier)
        .updateDisplayName(newName.trim());

    if (!mounted) return;
    setState(() => _isSaving = false);

    final AsyncValue<dynamic> s = ref.read(profileSummaryNotifierProvider);
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
    final String? fetched = ref
        .watch(profileSummaryNotifierProvider)
        .value
        ?.toNullable()
        ?.displayName;
    final String displayName =
        fetched?.trim().isNotEmpty == true
            ? fetched!
            : widget.user.displayName?.trim().isNotEmpty == true
            ? widget.user.displayName!
            : widget.user.email.split('@').first;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _isSaving ? null : () => _openEditNameDialog(displayName),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.25,
                        color: cs.onSurface.withAlpha(130),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    )
                  : Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: cs.onSurface.withAlpha(90),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
