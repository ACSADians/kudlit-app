import 'package:flutter/material.dart';

/// Shown inside [ScannerCamera] while the YOLO model is loading or unavailable.
///
/// Use the default constructor for the loading/downloading state.
/// Use [ModelNotReadyScreen.error] when the path resolution has failed and
/// the user needs a way to retry.
class ModelNotReadyScreen extends StatelessWidget {
  const ModelNotReadyScreen({super.key})
    : _isLoading = true,
      _errorMessage = null,
      _onRetry = null;

  const ModelNotReadyScreen.error({
    super.key,
    required String errorMessage,
    required VoidCallback onRetry,
  }) : _isLoading = false,
       _errorMessage = errorMessage,
       _onRetry = onRetry;

  final bool _isLoading;
  final String? _errorMessage;
  final VoidCallback? _onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _isLoading
                ? _LoadingContent(cs: cs)
                : _ErrorContent(
                    cs: cs,
                    message: _errorMessage ?? 'Scanner model could not be loaded.',
                    onRetry: _onRetry!,
                  ),
          ),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Preparing Scanner',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Loading the Baybayin recognition model…',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: cs.onSurface.withAlpha(160),
          ),
        ),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    required this.cs,
    required this.message,
    required this.onRetry,
  });

  final ColorScheme cs;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.wifi_off_rounded,
          size: 56,
          color: cs.error.withAlpha(200),
        ),
        const SizedBox(height: 20),
        Text(
          'Scanner Unavailable',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: cs.onSurface.withAlpha(160),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: onRetry,
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}
