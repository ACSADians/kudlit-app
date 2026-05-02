import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/home/data/datasources/local_profile_management_datasource.dart';
import 'package:kudlit_ph/features/home/data/datasources/profile_management_datasource.dart';
import 'package:kudlit_ph/features/home/data/models/profile_preferences_model.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/domain/repositories/profile_management_repository.dart';

class ProfileManagementRepositoryImpl implements ProfileManagementRepository {
  const ProfileManagementRepositoryImpl(this._remote, this._local);

  final ProfileManagementDatasource _remote;
  final LocalProfileManagementDatasource _local;

  @override
  Future<Either<Failure, ProfileSummary>> getSummary() async {
    try {
      final String? userId = _remote.getCurrentUserId();
      if (userId != null) {
        try {
          final cached = await _local.getCachedSummary(userId: userId);
          if (cached != null) return Right(cached);
        } on CacheException {
          // Fall through to remote on cache failure
        }
      }

      final summary = await _remote.getSummary();

      if (userId != null) {
        try {
          await _local.cacheSummary(userId: userId, summary: summary);
        } on CacheException {
          // Best-effort — don't fail the read if caching fails
        }
      }

      return Right(summary);
    } on ServerException catch (e) {
      return Left(Failure.unknown(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfilePreferences>> getPreferences() async {
    try {
      final String? userId = _remote.getCurrentUserId();
      if (userId != null) {
        try {
          final cached = await _local.getCachedPreferences(userId: userId);
          if (cached != null) return Right(cached);
        } on CacheException {
          // Fall through to remote on cache failure
        }
      }

      final prefs = await _remote.getPreferences();

      if (userId != null) {
        try {
          await _local.cachePreferences(userId: userId, preferences: prefs);
        } on CacheException {
          // Best-effort
        }
      }

      return Right(prefs);
    } on ServerException catch (e) {
      return Left(Failure.unknown(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDisplayName({
    required String displayName,
  }) async {
    try {
      await _remote.updateDisplayName(displayName: displayName);

      // Invalidate cached summary so the next read reflects the new name
      final String? userId = _remote.getCurrentUserId();
      if (userId != null) {
        try {
          await _local.clearCachedSummary(userId: userId);
        } on CacheException {
          // Best-effort
        }
      }

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(Failure.unknown(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePreferences({
    required ProfilePreferences preferences,
  }) async {
    try {
      final ProfilePreferencesModel model = ProfilePreferencesModel(
        highContrast: preferences.highContrast,
        reducedMotion: preferences.reducedMotion,
        dataSharingConsent: preferences.dataSharingConsent,
      );
      await _remote.savePreferences(preferences: model);

      // Update cache so the next read returns the saved state immediately
      final String? userId = _remote.getCurrentUserId();
      if (userId != null) {
        try {
          await _local.cachePreferences(userId: userId, preferences: model);
        } on CacheException {
          // Best-effort
        }
      }

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(Failure.unknown(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
