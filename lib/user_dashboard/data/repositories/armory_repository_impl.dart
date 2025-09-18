// lib/user_dashboard/data/repositories/armory_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/armory_firearm.dart';
import '../../domain/entities/armory_ammunition.dart';
import '../../domain/entities/armory_gear.dart';
import '../../domain/entities/armory_maintenance.dart';
import '../../domain/entities/armory_tool.dart';
import '../../domain/entities/armory_loadout.dart';
import '../../domain/entities/dropdown_option.dart';
import '../../domain/repositories/armory_repository.dart';
import '../datasources/armory_remote_datasource.dart';
import '../models/armory_firearm_model.dart';
import '../models/armory_ammunition_model.dart';
import '../models/armory_gear_model.dart';
import '../models/armory_maintenance_model.dart';
import '../models/armory_tool_model.dart';
import '../models/armory_loadout_model.dart';

class ArmoryRepositoryImpl implements ArmoryRepository {
  final ArmoryRemoteDataSource remoteDataSource;

  ArmoryRepositoryImpl({required this.remoteDataSource});

  // Firearms - methods remain the same
  @override
  Future<Either<Failure, List<ArmoryFirearm>>> getFirearms(String userId) async {
    try {
      final firearms = await remoteDataSource.getFirearms(userId);
      return Right(firearms);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFirearm(String userId, ArmoryFirearm firearm) async {
    try {
      final model = ArmoryFirearmModel(
        type: firearm.type,
        make: firearm.make,
        model: firearm.model,
        caliber: firearm.caliber,
        nickname: firearm.nickname,
        status: firearm.status,
        serial: firearm.serial,
        notes: firearm.notes,
        brand: firearm.brand,
        generation: firearm.generation,
        firingMechanism: firearm.firingMechanism,
        detailedType: firearm.detailedType,
        purpose: firearm.purpose,
        condition: firearm.condition,
        purchaseDate: firearm.purchaseDate,
        purchasePrice: firearm.purchasePrice,
        currentValue: firearm.currentValue,
        fflDealer: firearm.fflDealer,
        manufacturerPN: firearm.manufacturerPN,
        finish: firearm.finish,
        stockMaterial: firearm.stockMaterial,
        triggerType: firearm.triggerType,
        safetyType: firearm.safetyType,
        feedSystem: firearm.feedSystem,
        magazineCapacity: firearm.magazineCapacity,
        twistRate: firearm.twistRate,
        threadPattern: firearm.threadPattern,
        overallLength: firearm.overallLength,
        weight: firearm.weight,
        barrelLength: firearm.barrelLength,
        actionType: firearm.actionType,
        roundCount: firearm.roundCount,
        lastCleaned: firearm.lastCleaned,
        zeroDistance: firearm.zeroDistance,
        modifications: firearm.modifications,
        accessoriesIncluded: firearm.accessoriesIncluded,
        storageLocation: firearm.storageLocation,
        photos: firearm.photos,
        dateAdded: firearm.dateAdded,
      );
      await remoteDataSource.addFirearm(userId, model);
      // Clear cache when new firearm is added
      remoteDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFirearm(String userId, ArmoryFirearm firearm) async {
    try {
      final model = firearm as ArmoryFirearmModel;
      await remoteDataSource.updateFirearm(userId, model);
      // Clear cache when firearm is updated
      remoteDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFirearm(String userId, String firearmId) async {
    try {
      await remoteDataSource.deleteFirearm(userId, firearmId);
      // Clear cache when firearm is deleted
      remoteDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  // Ammunition - methods remain mostly the same
  @override
  Future<Either<Failure, List<ArmoryAmmunition>>> getAmmunition(String userId) async {
    try {
      final ammunition = await remoteDataSource.getAmmunition(userId);
      return Right(ammunition);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addAmmunition(String userId, ArmoryAmmunition ammunition) async {
    try {
      final model = ArmoryAmmunitionModel(
        brand: ammunition.brand,
        line: ammunition.line,
        caliber: ammunition.caliber,
        bullet: ammunition.bullet,
        quantity: ammunition.quantity,
        status: ammunition.status,
        lot: ammunition.lot,
        notes: ammunition.notes,
        primerType: ammunition.primerType,
        powderType: ammunition.powderType,
        powderWeight: ammunition.powderWeight,
        caseMaterial: ammunition.caseMaterial,
        caseCondition: ammunition.caseCondition,
        headstamp: ammunition.headstamp,
        ballisticCoefficient: ammunition.ballisticCoefficient,
        muzzleEnergy: ammunition.muzzleEnergy,
        velocity: ammunition.velocity,
        temperatureTested: ammunition.temperatureTested,
        standardDeviation: ammunition.standardDeviation,
        extremeSpread: ammunition.extremeSpread,
        groupSize: ammunition.groupSize,
        testDistance: ammunition.testDistance,
        testFirearm: ammunition.testFirearm,
        storageLocation: ammunition.storageLocation,
        purchaseDate: ammunition.purchaseDate,
        purchasePrice: ammunition.purchasePrice,
        costPerRound: ammunition.costPerRound,
        expirationDate: ammunition.expirationDate,
        performanceNotes: ammunition.performanceNotes,
        environmentalConditions: ammunition.environmentalConditions,
        isHandloaded: ammunition.isHandloaded,
        loadData: ammunition.loadData,
        dateAdded: ammunition.dateAdded,
      );
      await remoteDataSource.addAmmunition(userId, model);
      // Clear cache when new ammunition is added
      remoteDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAmmunition(String userId, ArmoryAmmunition ammunition) async {
    try {
      final model = ammunition as ArmoryAmmunitionModel;
      await remoteDataSource.updateAmmunition(userId, model);
      // Clear cache when ammunition is updated
      remoteDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAmmunition(String userId, String ammunitionId) async {
    try {
      await remoteDataSource.deleteAmmunition(userId, ammunitionId);
      // Clear cache when ammunition is deleted
      remoteDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  // Gear, Tools, Loadouts methods remain the same...
  @override
  Future<Either<Failure, List<ArmoryGear>>> getGear(String userId) async {
    try {
      final gear = await remoteDataSource.getGear(userId);
      return Right(gear);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addGear(String userId, ArmoryGear gear) async {
    try {
      final model = ArmoryGearModel(
        category: gear.category,
        model: gear.model,
        serial: gear.serial,
        quantity: gear.quantity,
        notes: gear.notes,
        dateAdded: gear.dateAdded,
      );
      await remoteDataSource.addGear(userId, model);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGear(String userId, ArmoryGear gear) async {
    try {
      final model = gear as ArmoryGearModel;
      await remoteDataSource.updateGear(userId, model);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGear(String userId, String gearId) async {
    try {
      await remoteDataSource.deleteGear(userId, gearId);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArmoryTool>>> getTools(String userId) async {
    try {
      final tools = await remoteDataSource.getTools(userId);
      return Right(tools);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTool(String userId, ArmoryTool tool) async {
    try {
      final model = ArmoryToolModel(
        name: tool.name,
        category: tool.category,
        quantity: tool.quantity,
        status: tool.status,
        notes: tool.notes,
        dateAdded: tool.dateAdded,
      );
      await remoteDataSource.addTool(userId, model);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTool(String userId, ArmoryTool tool) async {
    try {
      final model = tool as ArmoryToolModel;
      await remoteDataSource.updateTool(userId, model);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTool(String userId, String toolId) async {
    try {
      await remoteDataSource.deleteTool(userId, toolId);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArmoryLoadout>>> getLoadouts(String userId) async {
    try {
      final loadouts = await remoteDataSource.getLoadouts(userId);
      return Right(loadouts);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addLoadout(String userId, ArmoryLoadout loadout) async {
    try {
      final model = ArmoryLoadoutModel(
        name: loadout.name,
        firearmId: loadout.firearmId,
        ammunitionId: loadout.ammunitionId,
        gearIds: loadout.gearIds,
        notes: loadout.notes,
        dateAdded: loadout.dateAdded,
      );
      await remoteDataSource.addLoadout(userId, model);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLoadout(String userId, ArmoryLoadout loadout) async {
    try {
      final model = loadout as ArmoryLoadoutModel;
      await remoteDataSource.updateLoadout(userId, model);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLoadout(String userId, String loadoutId) async {
    try {
      await remoteDataSource.deleteLoadout(userId, loadoutId);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  // Updated dropdown options with filtering support
  @override
  Future<Either<Failure, List<DropdownOption>>> getFirearmBrands([String? type]) async {
    try {
      final options = await remoteDataSource.getFirearmBrands(type);
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownOption>>> getFirearmModels( [String? brand]) async {
    try {
      final options = await remoteDataSource.getFirearmModels(brand);
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownOption>>> getFirearmGenerations( [ String? model]) async {
    try {
      final options = await remoteDataSource.getFirearmGenerations(model);
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownOption>>> getCalibers([
     String? generation]) async
  {
    try {
      final options = await remoteDataSource.getCalibers( generation);
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownOption>>> getFirearmFiringMechanisms([
     String? caliber]) async
  {
    try {
      final options = await remoteDataSource.getFirearmFiringMechanisms( caliber);
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownOption>>> getFirearmMakes([
    String?  firingMechanism]) async
  {
    try {
      final options = await remoteDataSource.getFirearmMakes( firingMechanism);
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }


  @override
  Future<Either<Failure, List<DropdownOption>>> getAmmunitionBrands() async {
    try {
      final options = await remoteDataSource.getAmmunitionBrands();
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownOption>>> getAmmoCalibers([String? brand]) async{
    try {
      final options = await remoteDataSource.getAmmoCalibers(brand);
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownOption>>> getBulletTypes([String? caliber]) async {
    try {
      final options = await remoteDataSource.getBulletTypes(caliber);
      return Right(options);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArmoryMaintenance>>> getMaintenance(String userId) async {
    try {
      final maintenance = await remoteDataSource.getMaintenance(userId);
      return Right(maintenance);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMaintenance(String userId, ArmoryMaintenance maintenance) async {
    try {
      final model = ArmoryMaintenanceModel(
        assetType: maintenance.assetType,
        assetId: maintenance.assetId,
        maintenanceType: maintenance.maintenanceType,
        date: maintenance.date,
        roundsFired: maintenance.roundsFired,
        notes: maintenance.notes,
        dateAdded: maintenance.dateAdded,
      );
      await remoteDataSource.addMaintenance(userId, model);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMaintenance(String userId, String maintenanceId) async{
    try {
      await remoteDataSource.deleteMaintenance(userId, maintenanceId);
      return const Right(null);
    } catch (e) {
      return Left(FileFailure(e.toString()));
    }
  }


}