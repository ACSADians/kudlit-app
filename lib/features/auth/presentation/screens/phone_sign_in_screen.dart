import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/auth/domain/entities/country_code.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_drag_handle.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet_headline.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/country_picker_sheet.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/phone_field.dart';

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
  CountryCode _country = CountryCode.ph;
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
    showModalBottomSheet<CountryCode>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CountryPickerSheet(
        selected: _country,
        onSelect: (final CountryCode code) {
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
        bubbleText: 'What\'s your number?',
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
              subtitle: 'We\'ll text you a one-time code.',
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: PhoneField(
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
            const _EmailSignInPrompt(),
          ],
        ),
      ),
    );
  }
}

// ── Sign-in prompt ───────────────────────────────────────────────────────────

class _EmailSignInPrompt extends StatelessWidget {
  const _EmailSignInPrompt();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Prefer email?  ',
          style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(153)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Sign in with email',
            style: TextStyle(
              fontSize: 12.5,
              color: cs.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}
