import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';
import 'package:kudlit_ph/features/home/presentation/screens/profile_tab.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/accessibility_dialog.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/settings_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _FakeProfileSummaryNotifier extends ProfileSummaryNotifier {
  _FakeProfileSummaryNotifier(this.summary);

  final ProfileSummary summary;

  @override
  FutureOr<Option<ProfileSummary>> build() => Some(summary);
}

void main() {
  testWidgets('guest profile fits short landscape with comfortable CTA', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(593, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: ProfileTab())),
      ),
    );

    final Rect action = tester.getRect(find.byType(InkWell).first);

    expect(action.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });

  testWidgets('signed-in profile keeps history shortcuts inside phone width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileSummaryNotifierProvider.overrideWith(
            () => _FakeProfileSummaryNotifier(
              const ProfileSummary(
                displayName: 'Kudlit Learner With A Long Name',
                completedLessons: 12,
                scanHistoryItems: 8,
                translationHistoryItems: 6,
                bookmarkedTranslations: 3,
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

    final Rect scanShortcut = tester.getRect(find.text('Scanner History'));
    final Rect translateShortcut = tester.getRect(
      find.text('Translation History'),
    );

    expect(scanShortcut.left, greaterThanOrEqualTo(0));
    expect(scanShortcut.right, lessThanOrEqualTo(320));
    expect(translateShortcut.left, greaterThanOrEqualTo(0));
    expect(translateShortcut.right, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings list fits narrow guest account surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SettingsList(
              user: null,
              isAuthLoading: false,
              bottomPadding: 0,
              onActionTap: (_) {},
              onSignOutTap: () async {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accessibility dialog fits compact landscape', (tester) async {
    await tester.binding.setSurfaceSize(const Size(593, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccessibilityDialog(
            current: ProfilePreferences(
              highContrast: false,
              reducedMotion: false,
              dataSharingConsent: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Accessibility'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
