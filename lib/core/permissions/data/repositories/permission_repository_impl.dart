// lib/core/permissions/data/repositories/permission_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/repositories/permission_repository.dart';
import '../datasources/permission_local_datasource.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionLocalDataSource localDataSource;

  PermissionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, PermissionStatus>> checkPermission(AppPermission permission) async {
    try {
      final status = await localDataSource.checkPermission(permission);
      return Right(status);
    } catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PermissionStatus>> requestPermission(AppPermission permission) async {
    try {
      final status = await localDataSource.requestPermission(permission);
      return Right(status);
    } catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> openAppSettings() async {
    try {
      await localDataSource.openAppSettings();
      return const Right(null);
    } catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }
}