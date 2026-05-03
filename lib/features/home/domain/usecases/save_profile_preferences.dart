import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/repositories/profile_management_repository.dart';

class SaveProfilePreferencesParams {
  const SaveProfilePreferencesParams({required this.preferences});
  final ProfilePreferences preferences;
}

class SaveProfilePreferences
    implements UseCase<Unit, SaveProfilePreferencesParams> {
  const SaveProfilePreferences(this._repository);

  final ProfileManagementRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveProfilePreferencesParams params) {
    return _repository.savePreferences(preferences: params.preferences);
  }
}
