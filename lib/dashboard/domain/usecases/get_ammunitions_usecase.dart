// lib/home_feature/domain/usecases/get_ammunitions_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/ammunition.dart';
import '../repositories/file_upload_repository.dart';

class GetAmmunitionsUseCase implements UseCase<List<Ammunition>, NoParams> {
  final FileUploadRepository repository;

  GetAmmunitionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Ammunition>>> call(NoParams params) async {
    return await repository.getAmmunitions();
  }
}