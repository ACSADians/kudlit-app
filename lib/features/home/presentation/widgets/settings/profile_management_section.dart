import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';

import 'edit_name_dialog.dart';
import 'profile_management_card.dart';
import 'profile_management_item.dart';
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

  List<ProfileManagementItem> _getItems(ProfileSummary? summary) {
    final String? displayName = summary?.displayName;

    String learningDesc =
        'Track lesson completion, milestones, and last activity.';
    if (summary != null && summary.completedLessons > 0) {
      learningDesc += ' ${summary.completedLessons} lessons completed.';
    }

    String scanDesc = 'Review prior scan results and retry translations.';
    if (summary != null && summary.scanHistoryItems > 0) {
      scanDesc += ' ${summary.scanHistoryItems} scans.';
    }

    String translationDesc = 'Save and revisit translated phrases quickly.';
    if (summary != null) {
      final int t = summary.translationHistoryItems;
      final int b = summary.bookmarkedTranslations;
      if (t > 0 || b > 0) {
        translationDesc += ' $t translations, $b bookmarked.';
      }
    }

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
        primaryActionMessage: 'edit-name',
        secondaryActionId: 'upload-avatar',
        secondaryActionLabel: 'Upload avatar',
        secondaryActionMessage: 'Avatar update flow is available soon.',
      ),
      ProfileManagementItem(
        id: 'learning-progress-dashboard',
        icon: Icons.menu_book_rounded,
        title: 'Learning progress dashboard',
        description: learningDesc,
        primaryActionId: 'view-progress',
        primaryActionLabel: 'View progress',
        primaryActionMessage: 'Progress dashboard will be available soon.',
        secondaryActionId: 'continue-lesson',
        secondaryActionLabel: 'Continue lesson',
        secondaryActionMessage: 'Lesson resume flow is available soon.',
      ),
      ProfileManagementItem(
        id: 'scanner-history',
        icon: Icons.document_scanner_outlined,
        title: 'Scanner history',
        description: scanDesc,
        primaryActionId: 'open-scan-history',
        primaryActionLabel: 'Open history',
        primaryActionMessage: 'Scanner history will be available soon.',
        secondaryActionId: 'clear-scan-history',
        secondaryActionLabel: 'Clear history',
        secondaryActionMessage: 'History cleanup flow is available soon.',
      ),
      ProfileManagementItem(
        id: 'translator-history-bookmarks',
        icon: Icons.translate_rounded,
        title: 'Translator history and bookmarks',
        description: translationDesc,
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
        primaryActionMessage: 'open-accessibility-setup',
      ),
      const ProfileManagementItem(
        id: 'privacy-controls',
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy controls',
        description: 'Manage analytics consent and data sharing preferences.',
        primaryActionId: 'open-privacy-settings',
        primaryActionLabel: 'Privacy settings',
        primaryActionMessage: 'open-privacy-settings',
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
    final String initialName =
        summaryOpt?.toNullable()?.displayName ?? '';

    final String? newName = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(initialName: initialName),
    );

    if (newName == null || newName.trim() == initialName || !mounted) return;

    setState(() => _loadingActions.add('edit-name'));
    await ref
        .read(profileSummaryNotifierProvider.notifier)
        .updateDisplayName(newName.trim());

    if (!mounted) return;
    setState(() => _loadingActions.remove('edit-name'));

    final currentState = ref.read(profileSummaryNotifierProvider);
    if (currentState.hasError) {
      _showErrorSnackBar('Failed to update name', currentState.error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name updated.')),
      );
    }
  }

  Future<void> _showAccessibilityDialog() async {
    final prefsOpt = ref.read(profilePreferencesNotifierProvider).valueOrNull;
    final ProfilePreferences current = prefsOpt?.toNullable() ??
        const ProfilePreferences(
          highContrast: false,
          reducedMotion: false,
          dataSharingConsent: false,
        );

    final ProfilePreferences? newPrefs = await showDialog<ProfilePreferences>(
      context: context,
      builder: (BuildContext ctx) {
        bool highContrast = current.highContrast;
        bool reducedMotion = current.reducedMotion;

        return StatefulBuilder(
          builder: (BuildContext ctx2, StateSetter setInner) {
            return AlertDialog(
              title: const Text('Accessibility Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('High Contrast'),
                    value: highContrast,
                    onChanged: (bool val) =>
                        setInner(() => highContrast = val),
                  ),
                  SwitchListTile(
                    title: const Text('Reduced Motion'),
                    value: reducedMotion,
                    onChanged: (bool val) =>
                        setInner(() => reducedMotion = val),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(
                    ProfilePreferences(
                      highContrast: highContrast,
                      reducedMotion: reducedMotion,
                      dataSharingConsent: current.dataSharingConsent,
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

    if (newPrefs == null || !mounted) return;

    setState(() => _loadingActions.add('open-accessibility-setup'));
    await ref
        .read(profilePreferencesNotifierProvider.notifier)
        .updatePreferences(newPrefs);

    if (!mounted) return;
    setState(() => _loadingActions.remove('open-accessibility-setup'));

    final currentState = ref.read(profilePreferencesNotifierProvider);
    if (currentState.hasError) {
      _showErrorSnackBar('Failed to update preferences', currentState.error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accessibility settings updated.')),
      );
    }
  }

  Future<void> _showPrivacyDialog() async {
    final prefsOpt = ref.read(profilePreferencesNotifierProvider).valueOrNull;
    final ProfilePreferences current = prefsOpt?.toNullable() ??
        const ProfilePreferences(
          highContrast: false,
          reducedMotion: false,
          dataSharingConsent: false,
        );

    final ProfilePreferences? newPrefs = await showDialog<ProfilePreferences>(
      context: context,
      builder: (BuildContext ctx) {
        bool consent = current.dataSharingConsent;

        return StatefulBuilder(
          builder: (BuildContext ctx2, StateSetter setInner) {
            return AlertDialog(
              title: const Text('Privacy Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('Share Analytics Data'),
                    subtitle: const Text(
                      'Help us improve Kudlit by sharing anonymous usage data.',
                    ),
                    value: consent,
                    onChanged: (bool val) => setInner(() => consent = val),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(
                    ProfilePreferences(
                      highContrast: current.highContrast,
                      reducedMotion: current.reducedMotion,
                      dataSharingConsent: consent,
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

    if (newPrefs == null || !mounted) return;

    setState(() => _loadingActions.add('open-privacy-settings'));
    await ref
        .read(profilePreferencesNotifierProvider.notifier)
        .updatePreferences(newPrefs);

    if (!mounted) return;
    setState(() => _loadingActions.remove('open-privacy-settings'));

    final currentState = ref.read(profilePreferencesNotifierProvider);
    if (currentState.hasError) {
      _showErrorSnackBar(
          'Failed to update privacy settings', currentState.error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy settings updated.')),
      );
    }
  }

  void _showErrorSnackBar(String prefix, Object? error) {
    String message = error.toString();
    if (error is Failure) {
      message = error.when(
        network: (String msg) => msg,
        unknown: (String msg) => msg,
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
      SnackBar(content: Text('$prefix: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAuthenticated) return const SizedBox.shrink();

    final ProfileSummary? summary = ref
        .watch(profileSummaryNotifierProvider)
        .valueOrNull
        ?.toNullable();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingsSectionLabel(text: 'Profile management'),
        ProfileManagementCard(
          items: _getItems(summary),
          loadingActions: _loadingActions,
          onAction: _handleAction,
        ),
      ],
    );
  }
}
