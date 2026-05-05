import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/country_code.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_drag_handle.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet_headline.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/country_picker_sheet.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/phone_field.dart';

import 'phone_otp_screen.dart';
import 'sign_in_screen.dart';

/// Phone number entry screen.
/// Defaults to Philippines (+63); user can tap the prefix to pick another
/// country code. Tapping "Send OTP" pushes [PhoneOtpScreen].
class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  CountryCode _country = CountryCode.ph;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final String v = _normalizePhone(value ?? '');
    if (v.isEmpty) return 'Phone number is required.';
    if (v.length < 7) return 'Enter a valid phone number.';
    return null;
  }

  String _normalizePhone(String value) {
    final String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.startsWith('0') && digitsOnly.length > 1) {
      return digitsOnly.substring(1);
    }
    return digitsOnly;
  }

  String _mapFailure(Failure failure) => failure.when(
    network: (String msg) => '${AppConstants.networkErrorPrefix}$msg',
    tooManyRequests: () => AppConstants.tooManyRequestsMessage,
    invalidCredentials: () => 'Enter a valid phone number.',
    unknown: (String msg) => msg,
    emailAlreadyInUse: () => AppConstants.unexpectedError,
    weakPassword: () => AppConstants.unexpectedError,
    userNotFound: () => AppConstants.unexpectedError,
    sessionExpired: () => AppConstants.unexpectedError,
    passwordResetEmailSent: () => AppConstants.unexpectedError,
  );

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String fullNumber =
        '${_country.dialCode}${_normalizePhone(_phoneController.text)}';
    final Either<Failure, Unit> result = await ref
        .read(authNotifierProvider.notifier)
        .sendPhoneOtp(phoneNumber: fullNumber);

    if (!mounted) return;
    result.fold(
      (Failure failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = _mapFailure(failure);
        });
      },
      (_) {
        setState(() => _isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PhoneOtpScreen(phoneNumber: fullNumber),
          ),
        );
      },
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
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          'Prefer email?  ',
          style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(153)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
          ),
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
