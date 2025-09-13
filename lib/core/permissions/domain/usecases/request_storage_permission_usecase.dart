// lib/core/permissions/domain/usecases/request_storage_permission_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../../../usecases/usecase.dart';
import '../entities/permission_status.dart';
import '../repositories/permission_repository.dart';

class RequestStoragePermissionUseCase implements UseCase<PermissionStatus, NoParams> {
  final PermissionRepository repository;

  RequestStoragePermissionUseCase(this.repository);

  @override
  Future<Either<Failure, PermissionStatus>> call(NoParams params) async {
    // First check current status
    final checkResult = await repository.checkPermission(AppPermission.storage);

    return checkResult.fold(
          (failure) => Left(failure),
          (status) async {
        // If already granted, return status
        if (status.isGranted) {
          return Right(status);
        }

        // If not granted, request permission
        return await repository.requestPermission(AppPermission.storage);
      },
    );
  }
}

