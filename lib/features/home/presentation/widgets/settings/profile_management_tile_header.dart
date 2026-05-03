import 'package:flutter/material.dart';

import 'profile_management_item.dart';
import 'row_icon.dart';

class ProfileManagementTileHeader extends StatelessWidget {
  const ProfileManagementTileHeader({super.key, required this.item});

  final ProfileManagementItem item;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RowIcon(icon: item.icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withAlpha(165),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
