import 'package:flutter/material.dart';

class ProfileManagementItem {
  const ProfileManagementItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryActionId,
    required this.primaryActionLabel,
    required this.primaryActionMessage,
    this.secondaryActionId,
    this.secondaryActionLabel,
    this.secondaryActionMessage,
  });

  final String id;
  final IconData icon;
  final String title;
  final String description;
  final String primaryActionId;
  final String primaryActionLabel;
  final String primaryActionMessage;
  final String? secondaryActionId;
  final String? secondaryActionLabel;
  final String? secondaryActionMessage;
}
