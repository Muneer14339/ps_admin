// lib/home_feature/data/repositories/file_upload_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/firearm.dart';
import '../../domain/entities/ammunition.dart';
import '../../domain/repositories/file_upload_repository.dart';
import '../datasources/file_upload_remote_datasource.dart';
import '../models/ammunition_model.dart';
import '../models/firearm_model.dart';

class FileUploadRepositoryImpl implements FileUploadRepository {
  final FileUploadRemoteDataSource remoteDataSource;

  FileUploadRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Firearm>>> validateFirearmFile(String filePath) async {
    try {
      final firearms = await remoteDataSource.validateFirearmFile(filePath);
      return Right(firearms);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Ammunition>>> validateAmmunitionFile(String filePath) async {
    try {
      final ammunitions = await remoteDataSource.validateAmmunitionFile(filePath);
      return Right(ammunitions);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadFirearms(List<Firearm> firearms) async {
    try {
      final models = firearms.map((f) => f as FirearmModel).toList();
      await remoteDataSource.uploadFirearms(models);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadAmmunitions(List<Ammunition> ammunitions) async {
    try {
      final models = ammunitions.map((a) => a as AmmunitionModel).toList();
      await remoteDataSource.uploadAmmunitions(models);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Ammunition>>> getAmmunitions() {
    // TODO: implement getAmmunitions
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Firearm>>> getFirearms() {
    // TODO: implement getFirearms
    throw UnimplementedError();
  }
}