import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/auth/current_user_role_provider.dart';
import 'package:kudlit_ph/core/auth/user_role.dart';
import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Admin-only settings section.  Hidden entirely for regular users.
class AdminSection extends ConsumerWidget {
  const AdminSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserRole> roleAsync = ref.watch(currentUserRoleProvider);

    return roleAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, e) => const SizedBox.shrink(),
      data: (UserRole role) {
        if (!role.isAdmin) return const SizedBox.shrink();
        return _AdminSectionContent();
      },
    );
  }
}

class _AdminSectionContent extends StatelessWidget {
  const _AdminSectionContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.admin_panel_settings_rounded,
                size: 14,
                color: KudlitColors.danger400,
              ),
              const SizedBox(width: 6),
              Text(
                'Admin Tools',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: KudlitColors.danger400,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        _AdminTile(
          icon: Icons.gesture_rounded,
          title: 'Stroke Recorder',
          subtitle: 'Record Baybayin stroke patterns for model training',
          onTap: () => context.push(AppConstants.routeAdminStrokeRecorder),
        ),
      ],
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: KudlitColors.danger400.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: KudlitColors.danger400),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: KudlitColors.grey300),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: KudlitColors.grey300,
      ),
      onTap: onTap,
    );
  }
}
