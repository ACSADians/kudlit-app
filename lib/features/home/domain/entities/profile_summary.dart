import 'package:meta/meta.dart';

@immutable
class ProfileSummary {
  const ProfileSummary({
    required this.displayName,
    required this.avatarUrl,
    required this.completedLessons,
    required this.scanHistoryItems,
    required this.translationHistoryItems,
    required this.bookmarkedTranslations,
  });

  final String? displayName;
  final String? avatarUrl;
  final int completedLessons;
  final int scanHistoryItems;
  final int translationHistoryItems;
  final int bookmarkedTranslations;
}
