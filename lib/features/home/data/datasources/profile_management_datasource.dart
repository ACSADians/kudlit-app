import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/home/data/models/profile_preferences_model.dart';
import 'package:kudlit_ph/features/home/data/models/profile_summary_model.dart';

abstract interface class ProfileManagementDatasource {
  String? getCurrentUserId();
  Future<ProfileSummaryModel> getSummary();
  Future<ProfilePreferencesModel> getPreferences();
  Future<void> updateDisplayName({required String displayName});
  Future<void> updateAvatar({
    required Uint8List bytes,
    required String fileName,
    required String? mimeType,
  });
  Future<void> savePreferences({required ProfilePreferencesModel preferences});
  Future<void> saveLessonProgress({
    required String lessonId,
    required bool completed,
    required int score,
  });
}

class SupabaseProfileManagementDatasource
    implements ProfileManagementDatasource {
  const SupabaseProfileManagementDatasource(this._supabase);

  final SupabaseClient _supabase;

  @override
  String? getCurrentUserId() => _supabase.auth.currentUser?.id;

  @override
  Future<ProfileSummaryModel> getSummary() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User not authenticated');
    }

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _supabase.from('profiles').select().eq('id', user.id).maybeSingle(),
        _supabase
            .from('learning_progress')
            .select('id')
            .eq('user_id', user.id)
            .eq('completed', true),
        _supabase.from('scan_history').select('id').eq('user_id', user.id),
        _supabase
            .from('translation_history')
            .select('id')
            .eq('user_id', user.id),
        _supabase
            .from('translation_history')
            .select('id')
            .eq('user_id', user.id)
            .eq('is_bookmarked', true),
      ]);

      final Map<String, dynamic>? profile = results[0] as Map<String, dynamic>?;
      final List<dynamic> completedLessons = results[1] as List<dynamic>;
      final List<dynamic> scanHistory = results[2] as List<dynamic>;
      final List<dynamic> translationHistory = results[3] as List<dynamic>;
      final List<dynamic> bookmarked = results[4] as List<dynamic>;

      return ProfileSummaryModel(
        displayName: profile?['display_name'] as String?,
        avatarUrl:
            profile?['avatar_url'] as String? ??
            user.userMetadata?['avatar_url'] as String?,
        completedLessons: completedLessons.length,
        scanHistoryItems: scanHistory.length,
        translationHistoryItems: translationHistory.length,
        bookmarkedTranslations: bookmarked.length,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProfilePreferencesModel> getPreferences() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User not authenticated');
    }

    try {
      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        return const ProfilePreferencesModel(
          highContrast: false,
          reducedMotion: false,
          dataSharingConsent: false,
        );
      }

      return ProfilePreferencesModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateDisplayName({required String displayName}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User not authenticated');
    }

    try {
      // First update the auth metadata
      await _supabase.auth.updateUser(
        UserAttributes(data: {'display_name': displayName}),
      );

      // Then update the public profile (upsert since it might not exist)
      // Note: profiles table does NOT have an updated_at column in current migration.
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'display_name': displayName,
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateAvatar({
    required Uint8List bytes,
    required String fileName,
    required String? mimeType,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User not authenticated');
    }

    try {
      final String extension = _extensionFor(fileName, mimeType);
      final String path = '${user.id}/avatar.$extension';
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentTypeFor(extension, mimeType),
            ),
          );
      final String publicUrl =
          '${_supabase.storage.from('avatars').getPublicUrl(path)}'
          '?v=${DateTime.now().millisecondsSinceEpoch}';

      await _supabase.auth.updateUser(
        UserAttributes(data: {'avatar_url': publicUrl}),
      );

      try {
        await _supabase
            .from('profiles')
            .update(<String, dynamic>{'avatar_url': publicUrl})
            .eq('id', user.id);
      } on Object {
        // Auth metadata remains the durable fallback until profile migrations
        // are applied on every environment.
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> savePreferences({
    required ProfilePreferencesModel preferences,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User not authenticated');
    }

    try {
      await _supabase.from('user_preferences').upsert({
        'id': user.id,
        ...preferences.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveLessonProgress({
    required String lessonId,
    required bool completed,
    required int score,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return; // Guest user — skip silently.
    try {
      await _supabase.from('learning_progress').upsert(<String, dynamic>{
        'user_id': user.id,
        'lesson_id': lessonId,
        'completed': completed,
        'score': score,
        if (completed) 'completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,lesson_id');
    } catch (e) {
      // Non-fatal — local completion flag is the source of truth for lock/unlock.
      debugPrint('[LessonProgress] saveLessonProgress failed (non-fatal): $e');
    }
  }

  String _extensionFor(String fileName, String? mimeType) {
    final String lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png') || mimeType == 'image/png') return 'png';
    if (lowerName.endsWith('.webp') || mimeType == 'image/webp') return 'webp';
    if (lowerName.endsWith('.gif') || mimeType == 'image/gif') return 'gif';
    return 'jpg';
  }

  String _contentTypeFor(String extension, String? mimeType) {
    if (mimeType != null && mimeType.startsWith('image/')) return mimeType;
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }
}
