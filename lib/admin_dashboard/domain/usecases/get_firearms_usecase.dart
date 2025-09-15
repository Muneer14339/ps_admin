// lib/home_feature/domain/usecases/get_firearms_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/firearm.dart';
import '../repositories/file_upload_repository.dart';

class GetFirearmsUseCase implements UseCase<List<Firearm>, NoParams> {
  final FileUploadRepository repository;

  GetFirearmsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Firearm>>> call(NoParams params) async {
    return await repository.getFirearms();
  }
}