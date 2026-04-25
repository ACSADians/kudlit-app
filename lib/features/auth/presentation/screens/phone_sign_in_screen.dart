import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';

import 'phone_otp_screen.dart';

/// Phone number entry screen.
/// Defaults to Philippines (+63); user can tap the prefix to pick another
/// country code. Tapping "Send OTP" pushes [PhoneOtpScreen].
class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  _CountryCode _country = _CountryCode.ph;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required.';
    if (v.length < 7) return 'Enter a valid phone number.';
    return null;
  }

  void _pickCountry() {
    showModalBottomSheet<_CountryCode>(
      context: context,
      backgroundColor: KudlitColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CountryPickerSheet(
        selected: _country,
        onSelect: (final _CountryCode code) {
          setState(() => _country = code);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    final String fullNumber =
        '${_country.dialCode}${_phoneController.text.trim()}';

    // TODO: call auth notifier for phone sign-in
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhoneOtpScreen(phoneNumber: fullNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      heroFraction: 0.38,
      hero: const LoginHero(
        buttyAsset: 'assets/brand/ButtyPhone.webp',
        bubbleText: "What's your number?",
        showBackButton: true,
        showLanguageToggle: false,
      ),
      sheet: AuthSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AuthDragHandle(),
            const SizedBox(height: 10),
            const AuthSheetHeadline(
              title: 'Sign in with phone',
              subtitle: "We'll text you a one-time code.",
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: _PhoneField(
                controller: _phoneController,
                country: _country,
                onPickCountry: _pickCountry,
                validator: _validatePhone,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 20),
            AuthSubmitButton(
              label: 'Send OTP',
              isLoading: _isLoading,
              onTap: _submit,
            ),
            const SizedBox(height: 20),
            _EmailSignInPrompt(),
          ],
        ),
      ),
    );
  }
}

// ── Phone field ──────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.country,
    required this.onPickCountry,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final _CountryCode country;
  final VoidCallback onPickCountry;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: 'Phone number',
        border: const OutlineInputBorder(),
        prefixIcon: _CountryCodeButton(country: country, onTap: onPickCountry),
      ),
    );
  }
}

class _CountryCodeButton extends StatelessWidget {
  const _CountryCodeButton({required this.country, required this.onTap});

  final _CountryCode country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(country.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(
              country.dialCode,
              style: const TextStyle(
                fontSize: 14,
                color: KudlitColors.blue300,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: KudlitColors.grey200,
            ),
            const SizedBox(width: 4),
            Container(width: 1, height: 20, color: KudlitColors.grey400),
          ],
        ),
      ),
    );
  }
}

// ── Country picker ───────────────────────────────────────────────────────────

class _CountryPickerSheet extends StatelessWidget {
  const _CountryPickerSheet({required this.selected, required this.onSelect});

  final _CountryCode selected;
  final ValueChanged<_CountryCode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: KudlitColors.grey400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select country code',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: KudlitColors.blue300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final _CountryCode code in _CountryCode.values)
          ListTile(
            leading: Text(code.flag, style: const TextStyle(fontSize: 22)),
            title: Text(
              code.name,
              style: const TextStyle(
                fontSize: 14,
                color: KudlitColors.blue300,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              code.dialCode,
              style: const TextStyle(fontSize: 13, color: KudlitColors.grey200),
            ),
            selected: code == selected,
            selectedTileColor: KudlitColors.blue900.withAlpha(128),
            onTap: () => onSelect(code),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Country code data ────────────────────────────────────────────────────────

enum _CountryCode {
  ph('Philippines', '🇵🇭', '+63'),
  us('United States', '🇺🇸', '+1'),
  sg('Singapore', '🇸🇬', '+65'),
  au('Australia', '🇦🇺', '+61'),
  gb('United Kingdom', '🇬🇧', '+44'),
  jp('Japan', '🇯🇵', '+81'),
  kr('South Korea', '🇰🇷', '+82'),
  hk('Hong Kong', '🇭🇰', '+852'),
  ca('Canada', '🇨🇦', '+1');

  const _CountryCode(this.name, this.flag, this.dialCode);

  final String name;
  final String flag;
  final String dialCode;
}

// ── Sign-in prompt ───────────────────────────────────────────────────────────

class _EmailSignInPrompt extends StatelessWidget {
  const _EmailSignInPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Prefer email?  ',
          style: TextStyle(fontSize: 12.5, color: KudlitColors.grey200),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Text(
            'Sign in with email',
            style: TextStyle(
              fontSize: 12.5,
              color: KudlitColors.blue300,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: KudlitColors.blue300,
            ),
          ),
        ),
      ],
    );
  }
}
