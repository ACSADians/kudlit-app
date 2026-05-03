import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_drag_handle.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet_headline.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/email_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onReset() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final Either<Failure, Unit> result = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(email: _emailController.text.trim());

    result.fold(
      (Failure f) => setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = f.when(
          userNotFound: () => AppConstants.noAccountFoundMessage,
          tooManyRequests: () => AppConstants.tooManyRequestsMessage,
          network: (String msg) => '${AppConstants.networkErrorPrefix}$msg',
          unknown: (String msg) => msg,
          invalidCredentials: () => AppConstants.unexpectedError,
          emailAlreadyInUse: () => AppConstants.unexpectedError,
          weakPassword: () => AppConstants.unexpectedError,
          sessionExpired: () => AppConstants.unexpectedError,
          passwordResetEmailSent: () => AppConstants.unexpectedError,
        );
      }),
      (_) => setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = AppConstants.resetEmailSentSuccessMessage;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      heroFraction: 0.38,
      hero: const LoginHero(
        buttyAsset: 'assets/brand/ButtyTextBubble.webp',
        bubbleText: 'I\'ll help you get back in.',
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
              title: _isSuccess
                  ? 'Email sent!'
                  : AppConstants.resetPasswordTitle,
              subtitle: _isSuccess
                  ? AppConstants.resetEmailSentSuccessMessage
                  : AppConstants.resetPasswordSubtitle,
            ),
            const SizedBox(height: 20),
            if (!_isSuccess) ...<Widget>[
              EmailField(controller: _emailController),
              if (_message != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: const TextStyle(
                    color: KudlitColors.danger400,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AuthSubmitButton(
                label: AppConstants.sendResetEmailAction,
                isLoading: _isLoading,
                onTap: _onReset,
              ),
            ] else ...<Widget>[
              AuthSubmitButton(
                label: AppConstants.backToLoginAction,
                isLoading: false,
                onTap: () => context.go(AppConstants.routeLogin),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
