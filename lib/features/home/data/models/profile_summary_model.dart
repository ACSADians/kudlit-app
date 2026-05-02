import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';

class ProfileSummaryModel extends ProfileSummary {
  const ProfileSummaryModel({
    required super.displayName,
    required super.completedLessons,
    required super.scanHistoryItems,
    required super.translationHistoryItems,
    required super.bookmarkedTranslations,
  });

  factory ProfileSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProfileSummaryModel(
      displayName: json['display_name'] as String?,
      completedLessons: json['completed_lessons'] as int? ?? 0,
      scanHistoryItems: json['scan_history_items'] as int? ?? 0,
      translationHistoryItems: json['translation_history_items'] as int? ?? 0,
      bookmarkedTranslations: json['bookmarked_translations'] as int? ?? 0,
    );
  }
}
