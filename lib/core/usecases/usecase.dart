import 'package:dartz/dartz.dart';
import '../../user_dashboard/domain/entities/armory_ammunition.dart';
import '../../user_dashboard/domain/entities/armory_firearm.dart';
import '../../user_dashboard/domain/entities/armory_gear.dart';
import '../../user_dashboard/domain/entities/armory_loadout.dart';
import '../../user_dashboard/domain/entities/armory_tool.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

// Use Case Parameters
class UploadFirearmParams {
  final String filePath;
  UploadFirearmParams({required this.filePath});
}

class UploadAmmunitionParams {
  final String filePath;
  UploadAmmunitionParams({required this.filePath});
}

// Parameters
class UserIdParams {
  final String userId;
  UserIdParams({required this.userId});
}

class AddFirearmParams {
  final String userId;
  final ArmoryFirearm firearm;
  AddFirearmParams({required this.userId, required this.firearm});
}

class AddAmmunitionParams {
  final String userId;
  final ArmoryAmmunition ammunition;
  AddAmmunitionParams({required this.userId, required this.ammunition});
}

class AddGearParams {
  final String userId;
  final ArmoryGear gear;
  AddGearParams({required this.userId, required this.gear});
}

class AddToolParams {
  final String userId;
  final ArmoryTool tool;
  AddToolParams({required this.userId, required this.tool});
}

class AddLoadoutParams {
  final String userId;
  final ArmoryLoadout loadout;
  AddLoadoutParams({required this.userId, required this.loadout});
}

class DropdownParams {
  final DropdownType type;
  final String? filterValue;
  final String? secondaryFilter;

  DropdownParams({
    required this.type,
    this.filterValue,
    this.secondaryFilter,
  });
}

enum DropdownType {
  firearmBrands,
  firearmModels,
  firearmGenerations,
  firearmFiringMechanisms,
  firearmMakes,
  calibers,
  ammunitionBrands,
  bulletTypes  // Add this line
}