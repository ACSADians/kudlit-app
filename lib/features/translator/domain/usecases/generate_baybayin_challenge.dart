import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/translator/domain/entities/baybayin_challenge.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';

class GenerateBaybayinChallengeParams {
  const GenerateBaybayinChallengeParams({this.characters});

  /// Optionally restrict the challenge to a subset of Baybayin characters
  /// (e.g. only kudlit vowels). Pass `null` for a random challenge.
  final List<String>? characters;
}

/// Asks the cloud AI to generate one Baybayin learning challenge.
class GenerateBaybayinChallenge {
  const GenerateBaybayinChallenge(this._repository);

  final AiInferenceRepository _repository;

  Future<Either<Failure, BaybayinChallenge>> call(
    GenerateBaybayinChallengeParams params,
  ) {
    return _repository.generateChallenge(characters: params.characters);
  }
}
