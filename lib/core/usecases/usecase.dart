import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';

abstract interface class UseCase<TResult, Params> {
  Future<Either<Failure, TResult>> call(Params params);
}

class NoParams {
  const NoParams();
}
