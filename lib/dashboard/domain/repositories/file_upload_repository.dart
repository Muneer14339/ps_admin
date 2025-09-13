// lib/home_feature/domain/repositories/file_upload_repository.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/firearm.dart';
import '../entities/ammunition.dart';

abstract class FileUploadRepository {
  Future<Either<Failure, List<Firearm>>> validateFirearmFile(String filePath);
  Future<Either<Failure, List<Ammunition>>> validateAmmunitionFile(String filePath);
  Future<Either<Failure, void>> uploadFirearms(List<Firearm> firearms);
  Future<Either<Failure, void>> uploadAmmunitions(List<Ammunition> ammunitions);
  Future<Either<Failure, List<Firearm>>> getFirearms();
  Future<Either<Failure, List<Ammunition>>> getAmmunitions();
}