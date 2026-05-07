import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';

abstract interface class ProfileManagementRepository {
  Future<Either<Failure, ProfileSummary>> getSummary();

  Future<Either<Failure, ProfilePreferences>> getPreferences();

  Future<Either<Failure, Unit>> updateDisplayName({
    required String displayName,
  });

  Future<Either<Failure, Unit>> updateAvatar({
    required Uint8List bytes,
    required String fileName,
    required String? mimeType,
  });

  Future<Either<Failure, Unit>> savePreferences({
    required ProfilePreferences preferences,
  });

  Future<Either<Failure, Unit>> saveLessonProgress({
    required String lessonId,
    required bool completed,
    required int score,
  });
}
