// lib/home_feature/domain/usecases/upload_ammunition_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/ammunition.dart';
import '../repositories/file_upload_repository.dart';

class UploadAmmunitionUseCase implements UseCase<void, UploadAmmunitionParams> {
  final FileUploadRepository repository;

  UploadAmmunitionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadAmmunitionParams params) async {
    final validationResult = await repository.validateAmmunitionFile(params.filePath);

    return validationResult.fold(
          (failure) => Left(failure),
          (ammunitions) async {
        if (ammunitions.isEmpty) {
          return const Left(FileFailure('No valid data found in file'));
        }
        return await repository.uploadAmmunitions(ammunitions);
      },
    );
  }
}