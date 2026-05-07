import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/home/data/models/profile_summary_model.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';
import 'package:kudlit_ph/features/home/presentation/screens/profile_tab.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/profile_hero_avatar.dart';

void main() {
  test('profile summary keeps avatar url from Supabase profiles row', () {
    final ProfileSummaryModel summary =
        ProfileSummaryModel.fromJson(const <String, dynamic>{
          'display_name': 'Kudlit Learner',
          'avatar_url': 'https://example.com/avatar.jpg',
        });

    expect(summary.avatarUrl, 'https://example.com/avatar.jpg');
  });

  testWidgets('profile hero avatar renders uploaded image when url exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeroAvatar(
            initials: 'K',
            avatarUrl: 'https://example.com/avatar.jpg',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('profile tab renders uploaded avatar image from summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileSummaryNotifierProvider.overrideWith(
            () => _FakeProfileSummaryNotifier(
              const ProfileSummary(
                displayName: 'Kudlit Learner',
                avatarUrl: 'https://example.com/avatar.jpg',
                completedLessons: 0,
                scanHistoryItems: 0,
                translationHistoryItems: 0,
                bookmarkedTranslations: 0,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileTab(
              user: AuthUser(id: 'u1', email: 'learner@example.com'),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}

class _FakeProfileSummaryNotifier extends ProfileSummaryNotifier {
  _FakeProfileSummaryNotifier(this.summary);

  final ProfileSummary summary;

  @override
  Future<Option<ProfileSummary>> build() async => Some(summary);
}
