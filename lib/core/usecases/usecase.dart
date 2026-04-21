import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';

abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
