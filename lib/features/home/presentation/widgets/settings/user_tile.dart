import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final String initials = (user.displayName ?? user.email)
        .substring(0, 1)
        .toUpperCase();
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (user.displayName != null && user.displayName!.isNotEmpty)
                  Text(
                    user.displayName!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: cs.onSurface.withAlpha(102),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
