import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';

import 'profile_management_item.dart';
import 'profile_management_tile.dart';
import 'settings_card.dart';
import 'settings_divider.dart';
import 'settings_section_label.dart';

class ProfileManagementSection extends ConsumerStatefulWidget {
  const ProfileManagementSection({
    super.key,
    required this.isAuthenticated,
    required this.onActionTap,
  });

  final bool isAuthenticated;
  final void Function(String message) onActionTap;

  @override
  ConsumerState<ProfileManagementSection> createState() =>
      _ProfileManagementSectionState();
}

class _ProfileManagementSectionState
    extends ConsumerState<ProfileManagementSection> {
  final Set<String> _loadingActions = <String>{};

  List<ProfileManagementItem> _getItems(String? displayName) {
    return <ProfileManagementItem>[
      ProfileManagementItem(
        id: 'edit-profile-identity',
        icon: Icons.badge_outlined,
        title: 'Edit profile identity',
        description: 'Update display name and avatar profile appearance.',
        primaryActionId: 'edit-name',
        primaryActionLabel: displayName != null && displayName.isNotEmpty
            ? 'Edit name ($displayName)'
            : 'Edit name',
        primaryActionMessage: 'edit-name', // Special action id
        secondaryActionId: 'upload-avatar',
        secondaryActionLabel: 'Upload avatar',
        secondaryActionMessage: 'Avatar update flow is available soon.',
      ),
      const ProfileManagementItem(
        id: 'learning-progress-dashboard',
        icon: Icons.menu_book_rounded,
        title: 'Learning progress dashboard',
        description: 'Track lesson completion, milestones, and last activity.',
        primaryActionId: 'view-progress',
        primaryActionLabel: 'View progress',
        primaryActionMessage: 'Progress dashboard will be available soon.',
        secondaryActionId: 'continue-lesson',
        secondaryActionLabel: 'Continue lesson',
        secondaryActionMessage: 'Lesson resume flow is available soon.',
      ),
      const ProfileManagementItem(
        id: 'scanner-history',
        icon: Icons.document_scanner_outlined,
        title: 'Scanner history',
        description: 'Review prior scan results and retry translations.',
        primaryActionId: 'open-scan-history',
        primaryActionLabel: 'Open history',
        primaryActionMessage: 'Scanner history will be available soon.',
        secondaryActionId: 'clear-scan-history',
        secondaryActionLabel: 'Clear history',
        secondaryActionMessage: 'History cleanup flow is available soon.',
      ),
      const ProfileManagementItem(
        id: 'translator-history-bookmarks',
        icon: Icons.translate_rounded,
        title: 'Translator history and bookmarks',
        description: 'Save and revisit translated phrases quickly.',
        primaryActionId: 'view-saved-translations',
        primaryActionLabel: 'View saved',
        primaryActionMessage: 'Saved translations will be available soon.',
        secondaryActionId: 'add-bookmark',
        secondaryActionLabel: 'Add bookmark',
        secondaryActionMessage: 'Bookmark flow is available soon.',
      ),
      const ProfileManagementItem(
        id: 'accessibility-options',
        icon: Icons.accessibility_new_rounded,
        title: 'Accessibility options',
        description: 'Configure text scale, contrast, and motion comfort.',
        primaryActionId: 'open-accessibility-setup',
        primaryActionLabel: 'Accessibility setup',
        primaryActionMessage: 'open-accessibility-setup', // Special action id
      ),
      const ProfileManagementItem(
        id: 'privacy-controls',
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy controls',
        description: 'Manage analytics consent and data sharing preferences.',
        primaryActionId: 'open-privacy-settings',
        primaryActionLabel: 'Privacy settings',
        primaryActionMessage: 'open-privacy-settings', // Special action id
      ),
      const ProfileManagementItem(
        id: 'account-deletion-flow',
        icon: Icons.delete_forever_outlined,
        title: 'Account deletion flow',
        description: 'Run a safe and confirmed account deletion process.',
        primaryActionId: 'delete-account',
        primaryActionLabel: 'Delete account',
        primaryActionMessage: 'Account deletion flow will be available soon.',
        secondaryActionId: 'account-deletion-learn-more',
        secondaryActionLabel: 'Learn more',
        secondaryActionMessage:
            'Review account data retention and deletion policies.',
      ),
    ];
  }

  Future<void> _handleAction(String actionId, String message) async {
    if (message == 'edit-name') {
      await _showEditNameDialog();
      return;
    }
    if (message == 'open-accessibility-setup') {
      await _showAccessibilityDialog();
      return;
    }
    if (message == 'open-privacy-settings') {
      await _showPrivacyDialog();
      return;
    }

    if (_loadingActions.contains(actionId)) return;
    setState(() => _loadingActions.add(actionId));
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    widget.onActionTap(message);
    setState(() => _loadingActions.remove(actionId));
  }

  Future<void> _showEditNameDialog() async {
    final summaryOpt = ref.read(profileSummaryNotifierProvider).valueOrNull;
    String initialName = '';
    if (summaryOpt != null && summaryOpt.isSome()) {
      initialName = summaryOpt.toNullable()?.displayName ?? '';
    }

    final controller = TextEditingController(text: initialName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your new display name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName != initialName && mounted) {
      setState(() => _loadingActions.add('edit-name'));
      await ref
          .read(profileSummaryNotifierProvider.notifier)
          .updateDisplayName(newName.trim());
      if (mounted) {
        setState(() => _loadingActions.remove('edit-name'));
        final error = ref.read(profileSummaryNotifierProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update name: $error')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Display name updated.')),
          );
        }
      }
    }
  }

  Future<void> _showAccessibilityDialog() async {
    final prefsOpt = ref.read(profilePreferencesNotifierProvider).valueOrNull;
    bool highContrast = false;
    bool reducedMotion = false;
    bool dataSharingConsent = false;

    if (prefsOpt != null && prefsOpt.isSome()) {
      final prefs = prefsOpt.toNullable()!;
      highContrast = prefs.highContrast;
      reducedMotion = prefs.reducedMotion;
      dataSharingConsent = prefs.dataSharingConsent;
    }

    final newPrefs = await showDialog<ProfilePreferences>(
      context: context,
      builder: (context) {
        bool currentHighContrast = highContrast;
        bool currentReducedMotion = reducedMotion;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Accessibility Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('High Contrast'),
                    value: currentHighContrast,
                    onChanged: (val) =>
                        setState(() => currentHighContrast = val),
                  ),
                  SwitchListTile(
                    title: const Text('Reduced Motion'),
                    value: currentReducedMotion,
                    onChanged: (val) =>
                        setState(() => currentReducedMotion = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(
                    ProfilePreferences(
                      highContrast: currentHighContrast,
                      reducedMotion: currentReducedMotion,
                      dataSharingConsent: dataSharingConsent,
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newPrefs != null && mounted) {
      setState(() => _loadingActions.add('open-accessibility-setup'));
      await ref
          .read(profilePreferencesNotifierProvider.notifier)
          .updatePreferences(newPrefs);
      if (mounted) {
        setState(() => _loadingActions.remove('open-accessibility-setup'));
        final error = ref.read(profilePreferencesNotifierProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update preferences: $error')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Accessibility settings updated.')),
          );
        }
      }
    }
  }

  Future<void> _showPrivacyDialog() async {
    final prefsOpt = ref.read(profilePreferencesNotifierProvider).valueOrNull;
    bool highContrast = false;
    bool reducedMotion = false;
    bool dataSharingConsent = false;

    if (prefsOpt != null && prefsOpt.isSome()) {
      final prefs = prefsOpt.toNullable()!;
      highContrast = prefs.highContrast;
      reducedMotion = prefs.reducedMotion;
      dataSharingConsent = prefs.dataSharingConsent;
    }

    final newPrefs = await showDialog<ProfilePreferences>(
      context: context,
      builder: (context) {
        bool currentConsent = dataSharingConsent;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Privacy Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Share Analytics Data'),
                    subtitle: const Text(
                      'Help us improve Kudlit by sharing anonymous usage data.',
                    ),
                    value: currentConsent,
                    onChanged: (val) => setState(() => currentConsent = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(
                    ProfilePreferences(
                      highContrast: highContrast,
                      reducedMotion: reducedMotion,
                      dataSharingConsent: currentConsent,
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newPrefs != null && mounted) {
      setState(() => _loadingActions.add('open-privacy-settings'));
      await ref
          .read(profilePreferencesNotifierProvider.notifier)
          .updatePreferences(newPrefs);
      if (mounted) {
        setState(() => _loadingActions.remove('open-privacy-settings'));
        final error = ref.read(profilePreferencesNotifierProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update privacy settings: $error'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Privacy settings updated.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final summaryOpt = ref.watch(profileSummaryNotifierProvider).valueOrNull;
    String? currentDisplayName;
    if (summaryOpt != null && summaryOpt.isSome()) {
      currentDisplayName = summaryOpt.toNullable()?.displayName;
    }

    final items = _getItems(currentDisplayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingsSectionLabel(text: 'Profile management'),
        SettingsCard(
          children: <Widget>[
            for (int i = 0; i < items.length; i++) ...<Widget>[
              ProfileManagementTile(
                item: items[i],
                isPrimaryLoading: _loadingActions.contains(
                  items[i].primaryActionId,
                ),
                isSecondaryLoading:
                    items[i].secondaryActionId != null &&
                    _loadingActions.contains(items[i].secondaryActionId!),
                onPrimaryTap: () => _handleAction(
                  items[i].primaryActionId,
                  items[i].primaryActionMessage,
                ),
                onSecondaryTap: items[i].secondaryActionMessage == null
                    ? null
                    : () => _handleAction(
                        items[i].secondaryActionId!,
                        items[i].secondaryActionMessage!,
                      ),
              ),
              if (i < items.length - 1) const SettingsDivider(),
            ],
          ],
        ),
      ],
    );
  }
}
