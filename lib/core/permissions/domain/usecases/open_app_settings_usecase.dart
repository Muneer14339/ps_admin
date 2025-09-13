// lib/core/permissions/domain/usecases/open_app_settings_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../../../usecases/usecase.dart';
import '../repositories/permission_repository.dart';

class OpenAppSettingsUseCase implements UseCase<void, NoParams> {
  final PermissionRepository repository;

  OpenAppSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.openAppSettings();
  }
}