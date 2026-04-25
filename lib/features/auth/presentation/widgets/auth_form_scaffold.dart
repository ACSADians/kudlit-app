import 'package:flutter/material.dart';

import 'auth_header.dart';

class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    required this.title,
    required this.subtitle,
    required this.formKey,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.children,
    this.footer,
    this.statusMessage,
    super.key,
  });

  final String title;
  final String subtitle;
  final GlobalKey<FormState> formKey;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final List<Widget> children;
  final AuthFooterAction? footer;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: <Widget>[
              AuthHeader(title: title, subtitle: subtitle),
              const SizedBox(height: 28),
              AutofillGroup(child: AuthFormFields(children: children)),
              if (statusMessage != null)
                AuthStatusMessage(message: statusMessage!),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onPrimaryAction,
                child: Text(primaryActionLabel),
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

class AuthFormFields extends StatelessWidget {
  const AuthFormFields({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int index = 0; index < children.length; index += 1) ...<Widget>[
          children[index],
          if (index != children.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class AuthStatusMessage extends StatelessWidget {
  const AuthStatusMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthFooterAction extends StatelessWidget {
  const AuthFooterAction({
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
    super.key,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(child: Text(prompt)),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
