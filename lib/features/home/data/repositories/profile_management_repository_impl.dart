import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/home/data/datasources/profile_management_datasource.dart';
import 'package:kudlit_ph/features/home/data/models/profile_preferences_model.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/domain/repositories/profile_management_repository.dart';

class ProfileManagementRepositoryImpl implements ProfileManagementRepository {
  const ProfileManagementRepositoryImpl(this._datasource);

  final ProfileManagementDatasource _datasource;

  @override
  Future<Either<Failure, ProfileSummary>> getSummary() async {
    try {
      final summary = await _datasource.getSummary();
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
      final preferences = await _datasource.getPreferences();
      return Right(preferences);
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
      await _datasource.updateDisplayName(displayName: displayName);
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
      final model = ProfilePreferencesModel(
        highContrast: preferences.highContrast,
        reducedMotion: preferences.reducedMotion,
        dataSharingConsent: preferences.dataSharingConsent,
      );
      await _datasource.savePreferences(preferences: model);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(Failure.unknown(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
