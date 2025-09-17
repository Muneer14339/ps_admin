// lib/user_dashboard/domain/repositories/armory_repository.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/armory_firearm.dart';
import '../entities/armory_ammunition.dart';
import '../entities/armory_gear.dart';
import '../entities/armory_maintenance.dart';
import '../entities/armory_tool.dart';
import '../entities/armory_loadout.dart';
import '../entities/dropdown_option.dart';

abstract class ArmoryRepository {
  // Firearms
  Future<Either<Failure, List<ArmoryFirearm>>> getFirearms(String userId);
  Future<Either<Failure, void>> addFirearm(String userId, ArmoryFirearm firearm);
  Future<Either<Failure, void>> updateFirearm(String userId, ArmoryFirearm firearm);
  Future<Either<Failure, void>> deleteFirearm(String userId, String firearmId);

  // Ammunition
  Future<Either<Failure, List<ArmoryAmmunition>>> getAmmunition(String userId);
  Future<Either<Failure, void>> addAmmunition(String userId, ArmoryAmmunition ammunition);
  Future<Either<Failure, void>> updateAmmunition(String userId, ArmoryAmmunition ammunition);
  Future<Either<Failure, void>> deleteAmmunition(String userId, String ammunitionId);

  // Gear
  Future<Either<Failure, List<ArmoryGear>>> getGear(String userId);
  Future<Either<Failure, void>> addGear(String userId, ArmoryGear gear);
  Future<Either<Failure, void>> updateGear(String userId, ArmoryGear gear);
  Future<Either<Failure, void>> deleteGear(String userId, String gearId);

  // Tools
  Future<Either<Failure, List<ArmoryTool>>> getTools(String userId);
  Future<Either<Failure, void>> addTool(String userId, ArmoryTool tool);
  Future<Either<Failure, void>> updateTool(String userId, ArmoryTool tool);
  Future<Either<Failure, void>> deleteTool(String userId, String toolId);

  // Loadouts
  Future<Either<Failure, List<ArmoryLoadout>>> getLoadouts(String userId);
  Future<Either<Failure, void>> addLoadout(String userId, ArmoryLoadout loadout);
  Future<Either<Failure, void>> updateLoadout(String userId, ArmoryLoadout loadout);
  Future<Either<Failure, void>> deleteLoadout(String userId, String loadoutId);

  // Dropdown options with filtering support
  // Updated dropdown options with enhanced filtering support
  Future<Either<Failure, List<DropdownOption>>> getFirearmBrands([String? type]);

  Future<Either<Failure, List<DropdownOption>>> getFirearmModels(
       [String? brand,String? type]);

  Future<Either<Failure, List<DropdownOption>>> getFirearmGenerations(
       [String? brand, String? model,String? type]);

  Future<Either<Failure, List<DropdownOption>>> getCalibers([
    String? brand, String? model, String? generation]);

  Future<Either<Failure, List<DropdownOption>>> getFirearmFiringMechanisms([
    String? type, String? caliber]);

  Future<Either<Failure, List<DropdownOption>>> getFirearmMakes([
    String? type, String? brand, String? model, String? generation, String? caliber]);

  Future<Either<Failure, List<DropdownOption>>> getAmmunitionBrands();
  Future<Either<Failure, List<DropdownOption>>> getBulletTypes([String? caliber]);

  Future<Either<Failure, List<ArmoryMaintenance>>> getMaintenance(String userId);
  Future<Either<Failure, void>> addMaintenance(String userId, ArmoryMaintenance maintenance);

}