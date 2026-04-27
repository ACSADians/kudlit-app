import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';

class CheckLocalModelInstalled implements UseCase<bool, AiModelInfo> {
  const CheckLocalModelInstalled(this._repository);

  final AiInferenceRepository _repository;

  @override
  Future<Either<Failure, bool>> call(AiModelInfo params) {
    return _repository.isLocalModelInstalled(params);
  }
}
