// lib/home_feature/domain/usecases/upload_firearm_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/firearm.dart';
import '../repositories/file_upload_repository.dart';

class UploadFirearmUseCase implements UseCase<void, UploadFirearmParams> {
  final FileUploadRepository repository;

  UploadFirearmUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadFirearmParams params) async {
    final validationResult = await repository.validateFirearmFile(params.filePath);

    return validationResult.fold(
          (failure) => Left(failure),
          (firearms) async {
        if (firearms.isEmpty) {
          return const Left(FileFailure('No valid data found in file'));
        }
        return await repository.uploadFirearms(firearms);
      },
    );
  }
}