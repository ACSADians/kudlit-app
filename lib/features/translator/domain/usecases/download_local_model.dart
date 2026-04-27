import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/core/usecases/usecase.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';

class DownloadLocalModelParams {
  const DownloadLocalModelParams({required this.model, this.onProgress});

  final AiModelInfo model;
  final void Function(int progress)? onProgress;
}

class DownloadLocalModel implements UseCase<Unit, DownloadLocalModelParams> {
  const DownloadLocalModel(this._repository);

  final AiInferenceRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DownloadLocalModelParams params) {
    return _repository.downloadLocalModel(
      params.model,
      onProgress: params.onProgress,
    );
  }
}
