import 'package:flutter/material.dart';

class IntroActions extends StatelessWidget {
  const IntroActions({
    required this.isLastPage,
    required this.onNext,
    required this.onStart,
    super.key,
  });

  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: isLastPage ? onStart : onNext,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(isLastPage ? 'Start scanning' : 'Next'),
        ),
      ),
    );
  }
}
