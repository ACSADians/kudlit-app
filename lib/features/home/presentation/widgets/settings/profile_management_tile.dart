import 'package:flutter/material.dart';

import 'profile_management_item.dart';
import 'profile_management_tile_actions.dart';
import 'profile_management_tile_header.dart';

class ProfileManagementTile extends StatelessWidget {
  const ProfileManagementTile({
    super.key,
    required this.item,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
    this.isPrimaryLoading = false,
    this.isSecondaryLoading = false,
  });

  final ProfileManagementItem item;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final bool isPrimaryLoading;
  final bool isSecondaryLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ProfileManagementTileHeader(item: item),
          const SizedBox(height: 10),
          ProfileManagementTileActions(
            item: item,
            onPrimaryTap: onPrimaryTap,
            onSecondaryTap: onSecondaryTap,
            isPrimaryLoading: isPrimaryLoading,
            isSecondaryLoading: isSecondaryLoading,
          ),
        ],
      ),
    );
  }
}
