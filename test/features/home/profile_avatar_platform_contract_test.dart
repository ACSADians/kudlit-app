import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('avatar backend migrations expose column and storage policies', () {
    final String avatarColumnMigration = File(
      'supabase/migrations/20260507000000_add_profile_avatar_url.sql',
    ).readAsStringSync();
    final String avatarsBucketMigration = File(
      'supabase/migrations/20260429190336_create_avatars_bucket.sql',
    ).readAsStringSync();

    expect(avatarColumnMigration, contains('avatar_url text'));
    expect(avatarsBucketMigration, contains("values ('avatars', 'avatars'"));
    expect(avatarsBucketMigration, contains('for insert'));
    expect(avatarsBucketMigration, contains('for update'));
    expect(avatarsBucketMigration, contains('(storage.foldername(name))[1]'));
  });

  test('mobile platform files declare gallery access for avatar selection', () {
    final String androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final String iosPlist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(androidManifest, contains('READ_MEDIA_IMAGES'));
    expect(androidManifest, contains('READ_EXTERNAL_STORAGE'));
    expect(iosPlist, contains('NSPhotoLibraryUsageDescription'));
    expect(iosPlist, contains('profile avatar'));
  });

  test(
    'avatar profile write uses update policy instead of insert upsert branch',
    () {
      final String datasource = File(
        'lib/features/home/data/datasources/profile_management_datasource.dart',
      ).readAsStringSync();

      expect(datasource, contains(".update(<String, dynamic>{'avatar_url'"));
      expect(datasource, contains("user.userMetadata?['avatar_url']"));
      expect(
        datasource,
        contains('Auth metadata remains the durable fallback'),
      );
      expect(
        datasource,
        isNot(contains("'avatar_url': publicUrl,\n      });")),
      );
    },
  );

  test('avatar upload failures propagate back to the UI layer', () {
    final String provider = File(
      'lib/features/home/presentation/providers/profile_management_provider.dart',
    ).readAsStringSync();

    expect(provider, contains('throw Exception(_failureMessage(failure))'));
    expect(provider, contains('String _failureMessage(Failure failure)'));
    expect(provider, contains('final Option<ProfileSummary> previousSummary'));
    expect(provider, contains('state = AsyncValue.data(previousSummary);'));
  });
}
