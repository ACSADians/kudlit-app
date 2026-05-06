import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Card displaying a single model's name.
///
/// Shows a loading skeleton when [modelName] is null (catalog still loading
/// from Supabase).
class ModelSetupModelCard extends StatelessWidget {
  const ModelSetupModelCard({required this.modelName, super.key});

  final String? modelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KudlitColors.blue100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KudlitColors.blue300.withAlpha(80)),
      ),
      child: modelName == null
          ? const _CardSkeleton()
          : _CardContent(modelName: modelName!),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.modelName});

  final String modelName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _ModelIcon(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                modelName,
                style: const TextStyle(
                  color: KudlitColors.blue900,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const _OfflineBadge(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModelIcon extends StatelessWidget {
  const _ModelIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: KudlitColors.blue400,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.psychology_rounded,
        color: KudlitColors.blue900,
        size: 24,
      ),
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.offline_bolt_rounded,
            size: 13,
            color: KudlitColors.blue800,
          ),
        ),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            'Works offline after download',
            softWrap: true,
            style: TextStyle(
              color: KudlitColors.blue800,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _SkeletonBox(width: 44, height: 44, radius: 10),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              _SkeletonBox(width: 140, height: 14, radius: 4),
              SizedBox(height: 8),
              _SkeletonBox(width: double.infinity, height: 12, radius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: KudlitColors.blue300.withAlpha(60),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
