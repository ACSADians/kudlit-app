import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';

import 'home_screen.dart';

/// OTP verification screen. Receives the [phoneNumber] the code was sent to.
/// Renders 6 individual digit boxes that auto-advance focus on input.
class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  static const int _length = 6;

  final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(
        _length,
        (_) => TextEditingController(),
      );
  final List<FocusNode> _focusNodes = List<FocusNode>.generate(
    _length,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool _hasError = false;
  final int _resendCooldown = 0;

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp =>
      _controllers.map((TextEditingController c) => c.text).join();

  bool get _isComplete => _otp.length == _length;

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) {
      // Backspace — move focus back
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }
    // Move focus forward
    if (index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
    // Auto-submit when all filled
    if (_isComplete) _submit();
  }

  Future<void> _submit() async {
    if (!_isComplete || _isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // TODO: call auth notifier for OTP verification
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Simulate success — replace with actual auth result
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _clearOtp() {
    for (final TextEditingController c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() => _hasError = false);
  }

  @override
  Widget build(BuildContext context) {
    final String maskedNumber = _maskPhone(widget.phoneNumber);

    return AuthScreenShell(
      heroFraction: 0.38,
      hero: const LoginHero(
        buttyAsset: 'assets/brand/ButtyTextBubble.webp',
        bubbleText: 'Check your phone!',
        showBackButton: true,
        showLanguageToggle: false,
      ),
      sheet: AuthSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AuthDragHandle(),
            const SizedBox(height: 10),
            AuthSheetHeadline(
              title: 'Enter the code',
              subtitle: 'Sent to $maskedNumber',
            ),
            const SizedBox(height: 24),
            _OtpRow(
              controllers: _controllers,
              focusNodes: _focusNodes,
              hasError: _hasError,
              onChanged: _onDigitChanged,
            ),
            if (_hasError) ...<Widget>[
              const SizedBox(height: 12),
              const Text(
                'Incorrect code. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: KudlitColors.danger400, fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),
            AuthSubmitButton(
              label: 'Verify',
              isLoading: _isLoading,
              onTap: _submit,
            ),
            const SizedBox(height: 20),
            _ResendRow(cooldown: _resendCooldown, onResend: _clearOtp),
          ],
        ),
      ),
    );
  }

  /// Masks all but the last 4 digits: +63 917 *** 3456
  static String _maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    final String last4 = phone.substring(phone.length - 4);
    final String prefix = phone.substring(0, phone.length - 7);
    return '$prefix *** $last4';
  }
}

// ── OTP row ──────────────────────────────────────────────────────────────────

class _OtpRow extends StatelessWidget {
  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    this.hasError = false,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(controllers.length, (int i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: _OtpBox(
            controller: controllers[i],
            focusNode: focusNodes[i],
            hasError: hasError,
            onChanged: (String v) => onChanged(i, v),
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.hasError = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = hasError
        ? KudlitColors.danger400
        : KudlitColors.blue400;

    return SizedBox(
      width: 44,
      height: 54,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: onChanged,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: KudlitColors.blue300,
          height: 1,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: KudlitColors.blue300, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: KudlitColors.danger400,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: KudlitColors.blue900,
        ),
      ),
    );
  }
}

// ── Resend row ───────────────────────────────────────────────────────────────

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.onResend, this.cooldown = 0});

  final VoidCallback onResend;
  final int cooldown;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Didn't get a code?  ",
          style: TextStyle(fontSize: 12.5, color: KudlitColors.grey200),
        ),
        if (cooldown > 0)
          Text(
            'Resend in ${cooldown}s',
            style: const TextStyle(fontSize: 12.5, color: KudlitColors.grey400),
          )
        else
          GestureDetector(
            onTap: onResend,
            child: const Text(
              'Resend code',
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
