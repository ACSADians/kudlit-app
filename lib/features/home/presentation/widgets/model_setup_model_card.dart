import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';

/// Card displaying a single AI model's name and description.
///
/// Shows a loading skeleton when [model] is null (inference state still
/// loading from Supabase).
class ModelSetupModelCard extends StatelessWidget {
  const ModelSetupModelCard({required this.model, super.key});

  final AiModelInfo? model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KudlitColors.blue100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KudlitColors.blue300.withAlpha(80)),
      ),
      child: model == null
          ? const _CardSkeleton()
          : _CardContent(model: model!),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.model});

  final AiModelInfo model;

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
                model.name,
                style: const TextStyle(
                  color: KudlitColors.blue900,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (model.description != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  model.description!,
                  style: const TextStyle(
                    color: KudlitColors.grey300,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const <Widget>[
        Icon(Icons.offline_bolt_rounded, size: 13, color: KudlitColors.blue800),
        SizedBox(width: 4),
        Text(
          'Works offline after download',
          style: TextStyle(
            color: KudlitColors.blue800,
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
