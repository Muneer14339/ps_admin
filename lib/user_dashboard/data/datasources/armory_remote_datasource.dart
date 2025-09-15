// lib/user_dashboard/data/datasources/armory_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/armory_firearm_model.dart';
import '../models/armory_ammunition_model.dart';
import '../models/armory_gear_model.dart';
import '../models/armory_tool_model.dart';
import '../models/armory_loadout_model.dart';
import '../../domain/entities/dropdown_option.dart';

abstract class ArmoryRemoteDataSource {
  // Firearms
  Future<List<ArmoryFirearmModel>> getFirearms(String userId);
  Future<void> addFirearm(String userId, ArmoryFirearmModel firearm);
  Future<void> updateFirearm(String userId, ArmoryFirearmModel firearm);
  Future<void> deleteFirearm(String userId, String firearmId);

  // Ammunition
  Future<List<ArmoryAmmunitionModel>> getAmmunition(String userId);
  Future<void> addAmmunition(String userId, ArmoryAmmunitionModel ammunition);
  Future<void> updateAmmunition(String userId, ArmoryAmmunitionModel ammunition);
  Future<void> deleteAmmunition(String userId, String ammunitionId);

  // Gear
  Future<List<ArmoryGearModel>> getGear(String userId);
  Future<void> addGear(String userId, ArmoryGearModel gear);
  Future<void> updateGear(String userId, ArmoryGearModel gear);
  Future<void> deleteGear(String userId, String gearId);

  // Tools
  Future<List<ArmoryToolModel>> getTools(String userId);
  Future<void> addTool(String userId, ArmoryToolModel tool);
  Future<void> updateTool(String userId, ArmoryToolModel tool);
  Future<void> deleteTool(String userId, String toolId);

  // Loadouts
  Future<List<ArmoryLoadoutModel>> getLoadouts(String userId);
  Future<void> addLoadout(String userId, ArmoryLoadoutModel loadout);
  Future<void> updateLoadout(String userId, ArmoryLoadoutModel loadout);
  Future<void> deleteLoadout(String userId, String loadoutId);

  // Dropdown options
  Future<List<DropdownOption>> getFirearmBrands();
  Future<List<DropdownOption>> getFirearmModels(String brand);
  Future<List<DropdownOption>> getFirearmGenerations(String brand, String model);
  Future<List<DropdownOption>> getFirearmFiringMechanisms();
  Future<List<DropdownOption>> getFirearmMakes();
  Future<List<DropdownOption>> getCalibers();
  Future<List<DropdownOption>> getAmmunitionBrands();
}

class ArmoryRemoteDataSourceImpl implements ArmoryRemoteDataSource {
  final FirebaseFirestore firestore;

  ArmoryRemoteDataSourceImpl({required this.firestore});

  // Firearms
  @override
  Future<List<ArmoryFirearmModel>> getFirearms(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('armory')
          .doc(userId)
          .collection('firearms')
          .orderBy('dateAdded', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ArmoryFirearmModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get firearms: $e');
    }
  }

  @override
  Future<void> addFirearm(String userId, ArmoryFirearmModel firearm) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('firearms')
          .add(firearm.toMap());
    } catch (e) {
      throw Exception('Failed to add firearm: $e');
    }
  }

  @override
  Future<void> updateFirearm(String userId, ArmoryFirearmModel firearm) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('firearms')
          .doc(firearm.id)
          .update(firearm.toMap());
    } catch (e) {
      throw Exception('Failed to update firearm: $e');
    }
  }

  @override
  Future<void> deleteFirearm(String userId, String firearmId) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('firearms')
          .doc(firearmId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete firearm: $e');
    }
  }

  // Ammunition
  @override
  Future<List<ArmoryAmmunitionModel>> getAmmunition(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('armory')
          .doc(userId)
          .collection('ammunition')
          .orderBy('dateAdded', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ArmoryAmmunitionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get ammunition: $e');
    }
  }

  @override
  Future<void> addAmmunition(String userId, ArmoryAmmunitionModel ammunition) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('ammunition')
          .add(ammunition.toMap());
    } catch (e) {
      throw Exception('Failed to add ammunition: $e');
    }
  }

  @override
  Future<void> updateAmmunition(String userId, ArmoryAmmunitionModel ammunition) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('ammunition')
          .doc(ammunition.id)
          .update(ammunition.toMap());
    } catch (e) {
      throw Exception('Failed to update ammunition: $e');
    }
  }

  @override
  Future<void> deleteAmmunition(String userId, String ammunitionId) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('ammunition')
          .doc(ammunitionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete ammunition: $e');
    }
  }

  // Gear
  @override
  Future<List<ArmoryGearModel>> getGear(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('armory')
          .doc(userId)
          .collection('gear')
          .orderBy('dateAdded', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ArmoryGearModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get gear: $e');
    }
  }

  @override
  Future<void> addGear(String userId, ArmoryGearModel gear) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('gear')
          .add(gear.toMap());
    } catch (e) {
      throw Exception('Failed to add gear: $e');
    }
  }

  @override
  Future<void> updateGear(String userId, ArmoryGearModel gear) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('gear')
          .doc(gear.id)
          .update(gear.toMap());
    } catch (e) {
      throw Exception('Failed to update gear: $e');
    }
  }

  @override
  Future<void> deleteGear(String userId, String gearId) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('gear')
          .doc(gearId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete gear: $e');
    }
  }

  // Tools
  @override
  Future<List<ArmoryToolModel>> getTools(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('armory')
          .doc(userId)
          .collection('tools')
          .orderBy('dateAdded', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ArmoryToolModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tools: $e');
    }
  }

  @override
  Future<void> addTool(String userId, ArmoryToolModel tool) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('tools')
          .add(tool.toMap());
    } catch (e) {
      throw Exception('Failed to add tool: $e');
    }
  }

  @override
  Future<void> updateTool(String userId, ArmoryToolModel tool) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('tools')
          .doc(tool.id)
          .update(tool.toMap());
    } catch (e) {
      throw Exception('Failed to update tool: $e');
    }
  }

  @override
  Future<void> deleteTool(String userId, String toolId) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('tools')
          .doc(toolId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete tool: $e');
    }
  }

  // Loadouts
  @override
  Future<List<ArmoryLoadoutModel>> getLoadouts(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('armory')
          .doc(userId)
          .collection('loadouts')
          .orderBy('dateAdded', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ArmoryLoadoutModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get loadouts: $e');
    }
  }

  @override
  Future<void> addLoadout(String userId, ArmoryLoadoutModel loadout) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('loadouts')
          .add(loadout.toMap());
    } catch (e) {
      throw Exception('Failed to add loadout: $e');
    }
  }

  @override
  Future<void> updateLoadout(String userId, ArmoryLoadoutModel loadout) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('loadouts')
          .doc(loadout.id)
          .update(loadout.toMap());
    } catch (e) {
      throw Exception('Failed to update loadout: $e');
    }
  }

  @override
  Future<void> deleteLoadout(String userId, String loadoutId) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('loadouts')
          .doc(loadoutId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete loadout: $e');
    }
  }

  // Dropdown options from existing collections
  @override
  Future<List<DropdownOption>> getFirearmBrands() async {
    try {
      final querySnapshot = await firestore.collection('firearms').get();
      final brands = querySnapshot.docs
          .map((doc) => doc.data()['brand']?.toString() ?? '')
          .where((brand) => brand.isNotEmpty)
          .toSet()
          .toList();

      brands.sort();
      return brands.map((brand) => DropdownOption(value: brand, label: brand)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm brands: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmModels(String brand) async {
    try {
      final querySnapshot = await firestore
          .collection('firearms')
          .where('brand', isEqualTo: brand)
          .get();

      final models = querySnapshot.docs
          .map((doc) => doc.data()['model']?.toString() ?? '')
          .where((model) => model.isNotEmpty)
          .toSet()
          .toList();

      models.sort();
      return models.map((model) => DropdownOption(value: model, label: model)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm models: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmGenerations(String brand, String model) async {
    try {
      final querySnapshot = await firestore
          .collection('firearms')
          .where('brand', isEqualTo: brand)
          .where('model', isEqualTo: model)
          .get();

      final generations = querySnapshot.docs
          .map((doc) => doc.data()['generation']?.toString() ?? '')
          .where((gen) => gen.isNotEmpty)
          .toSet()
          .toList();

      generations.sort();
      return generations.map((gen) => DropdownOption(value: gen, label: gen)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm generations: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmFiringMechanisms() async {
    try {
      final querySnapshot = await firestore.collection('firearms').get();
      final mechanisms = querySnapshot.docs
          .map((doc) => doc.data()['firing_machanism']?.toString() ?? '')
          .where((mech) => mech.isNotEmpty)
          .toSet()
          .toList();

      mechanisms.sort();
      return mechanisms.map((mech) => DropdownOption(value: mech, label: mech)).toList();
    } catch (e) {
      throw Exception('Failed to get firing mechanisms: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmMakes() async {
    try {
      final querySnapshot = await firestore.collection('firearms').get();
      final makes = querySnapshot.docs
          .map((doc) => doc.data()['make']?.toString() ?? '')
          .where((make) => make.isNotEmpty)
          .toSet()
          .toList();

      makes.sort();
      return makes.map((make) => DropdownOption(value: make, label: make)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm makes: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getCalibers() async {
    try {
      // Get calibers from both firearms and ammunition collections
      final firearmsSnapshot = await firestore.collection('firearms').get();
      final ammoSnapshot = await firestore.collection('ammunition').get();

      final calibers = <String>{};

      for (final doc in firearmsSnapshot.docs) {
        final caliber = doc.data()['caliber']?.toString() ?? '';
        if (caliber.isNotEmpty) calibers.add(caliber);
      }

      for (final doc in ammoSnapshot.docs) {
        final caliber = doc.data()['caliber']?.toString() ?? '';
        if (caliber.isNotEmpty) calibers.add(caliber);
      }

      final caliberList = calibers.toList();
      caliberList.sort();
      return caliberList.map((caliber) => DropdownOption(value: caliber, label: caliber)).toList();
    } catch (e) {
      throw Exception('Failed to get calibers: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getAmmunitionBrands() async {
    try {
      final querySnapshot = await firestore.collection('ammunition').get();
      final brands = querySnapshot.docs
          .map((doc) => doc.data()['brand']?.toString() ?? '')
          .where((brand) => brand.isNotEmpty)
          .toSet()
          .toList();

      brands.sort();
      return brands.map((brand) => DropdownOption(value: brand, label: brand)).toList();
    } catch (e) {
      throw Exception('Failed to get ammunition brands: $e');
    }
  }
}
