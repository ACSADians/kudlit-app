import 'package:flutter/material.dart';

import 'profile_management_action_button.dart';
import 'profile_management_item.dart';

class ProfileManagementTileActions extends StatelessWidget {
  const ProfileManagementTileActions({
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        ProfileManagementActionButton(
          label: item.primaryActionLabel,
          onTap: onPrimaryTap,
          isPrimary: true,
          isLoading: isPrimaryLoading,
        ),
        if (item.secondaryActionLabel != null && onSecondaryTap != null)
          ProfileManagementActionButton(
            label: item.secondaryActionLabel!,
            onTap: onSecondaryTap!,
            isLoading: isSecondaryLoading,
          ),
      ],
    );
  }
}
