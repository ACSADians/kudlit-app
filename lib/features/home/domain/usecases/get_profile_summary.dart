import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/domain/repositories/profile_management_repository.dart';

class GetProfileSummary implements UseCase<ProfileSummary, NoParams> {
  const GetProfileSummary(this._repository);

  final ProfileManagementRepository _repository;

  @override
  Future<Either<Failure, ProfileSummary>> call(NoParams params) {
    return _repository.getSummary();
  }
}
