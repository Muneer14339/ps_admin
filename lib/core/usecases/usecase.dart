import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

// Use Case Parameters
class UploadFirearmParams {
  final String filePath;
  UploadFirearmParams({required this.filePath});
}

class UploadAmmunitionParams {
  final String filePath;
  UploadAmmunitionParams({required this.filePath});
}