import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_preferences.dart';
import 'package:kudlit_ph/features/home/domain/repositories/profile_management_repository.dart';

class GetProfilePreferences implements UseCase<ProfilePreferences, NoParams> {
  const GetProfilePreferences(this._repository);

  final ProfileManagementRepository _repository;

  @override
  Future<Either<Failure, ProfilePreferences>> call(NoParams params) {
    return _repository.getPreferences();
  }
}
