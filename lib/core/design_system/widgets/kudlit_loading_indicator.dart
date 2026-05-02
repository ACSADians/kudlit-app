import 'package:flutter/material.dart';
import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// A branded loading indicator for the Kudlit application.
///
/// Replaces the generic [CircularProgressIndicator] to maintain
/// the "paper and ink" design language.
class KudlitLoadingIndicator extends StatelessWidget {
  const KudlitLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 3.0,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? KudlitColors.blue400,
        ),
      ),
    );
  }
}
