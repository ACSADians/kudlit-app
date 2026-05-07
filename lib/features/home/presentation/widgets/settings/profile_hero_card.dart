import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';

import 'profile_hero_avatar.dart';
import 'profile_stats_bar.dart';

/// Identity card under [SettingsHeader]. Lifted slightly so it overlaps the
/// wave at the bottom of the header. Intentionally restrained — the only
/// visual elements are the avatar (identity), the name (with a tiny edit
/// pencil), the email, and the stats. No chips, no decorative icons.
class ProfileHeroCard extends ConsumerStatefulWidget {
  const ProfileHeroCard({super.key, required this.user});

  final AuthUser user;

  @override
  ConsumerState<ProfileHeroCard> createState() => _ProfileHeroCardState();
}

class _ProfileHeroCardState extends ConsumerState<ProfileHeroCard> {
  bool _isEditingName = false;
  bool _isSavingName = false;
  bool _isUploadingAvatar = false;
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String _initials(String name, String email) {
    final String src = name.trim().isNotEmpty ? name.trim() : email;
    return src.isNotEmpty ? src[0].toUpperCase() : '?';
  }

  void _startEditingName(String currentName) {
    _nameController.text = currentName;
    _nameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _nameController.text.length,
    );
    setState(() => _isEditingName = true);
    _nameFocusNode.requestFocus();
  }

  void _cancelEditingName() {
    setState(() {
      _isEditingName = false;
      _isSavingName = false;
    });
  }

  Future<void> _saveDisplayName(String currentName) async {
    final String newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name cannot be empty.')),
      );
      return;
    }

    if (newName == currentName.trim()) {
      _cancelEditingName();
      return;
    }

    setState(() => _isSavingName = true);
    await ref
        .read(profileSummaryNotifierProvider.notifier)
        .updateDisplayName(newName);

    final s = ref.read(profileSummaryNotifierProvider);
    if (!mounted) return;

    if (s.hasError) {
      setState(() => _isSavingName = false);
      _showError('Failed to update name', s.error);
    } else {
      setState(() {
        _isEditingName = false;
        _isSavingName = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Display name updated.')));
    }
  }

  Future<void> _uploadAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 88,
      );
      if (image == null || !mounted) return;

      setState(() => _isUploadingAvatar = true);
      final Uint8List bytes = await image.readAsBytes();
      await ref
          .read(profileSummaryNotifierProvider.notifier)
          .updateAvatar(
            bytes: bytes,
            fileName: image.name,
            mimeType: image.mimeType,
          );

      if (!mounted) return;
      final s = ref.read(profileSummaryNotifierProvider);
      if (s.hasError) {
        _showError('Failed to upload avatar', s.error);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Avatar updated.')));
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to upload avatar', e);
    } finally {
      if (mounted && _isUploadingAvatar) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  void _showError(String prefix, Object? error) {
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$prefix: $message')));
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

    final Widget card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ProfileHeroAvatar(
            initials: _initials(displayName, widget.user.email),
            avatarUrl: summary?.avatarUrl,
            isUploading: _isUploadingAvatar,
            onTap: _isUploadingAvatar ? null : _uploadAvatar,
          ),
          const SizedBox(height: 14),
          _NameRow(
            displayName: displayName,
            controller: _nameController,
            focusNode: _nameFocusNode,
            isEditing: _isEditingName,
            isSaving: _isSavingName,
            onEdit: () => _startEditingName(displayName),
            onCancel: _cancelEditingName,
            onSave: () => _saveDisplayName(displayName),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(160)),
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

    return Transform.translate(offset: const Offset(0, -22), child: card)
        .animate()
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.05, end: 0, duration: 280.ms, curve: Curves.easeOut);
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.displayName,
    required this.controller,
    required this.focusNode,
    required this.isEditing,
    required this.isSaving,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  final String displayName;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    if (isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !isSaving,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                maxLength: 40,
                onSubmitted: (_) => isSaving ? null : onSave(),
                decoration: InputDecoration(
                  counterText: '',
                  isDense: true,
                  hintText: 'Set display name',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          _InlineIconButton(
            tooltip: 'Save display name',
            icon: isSaving ? null : Icons.check_rounded,
            isLoading: isSaving,
            onPressed: isSaving ? null : onSave,
          ),
          _InlineIconButton(
            tooltip: 'Cancel display name edit',
            icon: Icons.close_rounded,
            onPressed: isSaving ? null : onCancel,
          ),
        ],
      );
    }

    final bool hasName = displayName.trim().isNotEmpty;
    final String label = hasName ? displayName : 'Set display name';

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: hasName ? cs.onSurface : cs.onSurface.withAlpha(120),
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.edit_rounded,
              size: 14,
              color: cs.onSurface.withAlpha(120),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineIconButton extends StatelessWidget {
  const _InlineIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String tooltip;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: isLoading
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            )
          : Icon(icon, size: 20),
    );
  }
}
