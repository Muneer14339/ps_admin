// lib/core/permissions/domain/repositories/permission_repository.dart
import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../entities/permission_status.dart';

abstract class PermissionRepository {
  Future<Either<Failure, PermissionStatus>> checkPermission(AppPermission permission);
  Future<Either<Failure, PermissionStatus>> requestPermission(AppPermission permission);
  Future<Either<Failure, void>> openAppSettings();
}