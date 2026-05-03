import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/home/domain/repositories/profile_management_repository.dart';

class UpdateDisplayNameParams {
  const UpdateDisplayNameParams({required this.displayName});
  final String displayName;
}

class UpdateDisplayName implements UseCase<Unit, UpdateDisplayNameParams> {
  const UpdateDisplayName(this._repository);

  final ProfileManagementRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateDisplayNameParams params) {
    return _repository.updateDisplayName(displayName: params.displayName);
  }
}
