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

  // Dropdown options with filtering support
  Future<List<DropdownOption>> getFirearmBrands([String? type]);
  Future<List<DropdownOption>> getFirearmModels(String brand, [String? type]);
  Future<List<DropdownOption>> getFirearmGenerations(String brand, String model, [String? type]);
  Future<List<DropdownOption>> getFirearmFiringMechanisms([String? type]);
  Future<List<DropdownOption>> getFirearmMakes([String? type]);
  Future<List<DropdownOption>> getCalibers([String? brand]);
  Future<List<DropdownOption>> getAmmunitionBrands();
  Future<List<DropdownOption>> getBulletTypes([String? caliber]);

  // Method to clear cache when needed
  void clearCache();
}

class ArmoryRemoteDataSourceImpl implements ArmoryRemoteDataSource {
  final FirebaseFirestore firestore;

  // Cache for dropdown data to avoid repeated Firebase queries
  List<Map<String, dynamic>>? _firearmsCache;
  List<Map<String, dynamic>>? _ammunitionCache;

  ArmoryRemoteDataSourceImpl({required this.firestore});

  // Load all firearms data once and cache it
  Future<List<Map<String, dynamic>>> _getFirearmsData() async {
    if (_firearmsCache != null) return _firearmsCache!;

    try {
      final querySnapshot = await firestore.collection('firearms').get();
      _firearmsCache = querySnapshot.docs.map((doc) => doc.data()).toList();
      return _firearmsCache!;
    } catch (e) {
      throw Exception('Failed to load firearms data: $e');
    }
  }

  // Load all ammunition data once and cache it
  Future<List<Map<String, dynamic>>> _getAmmunitionData() async {
    if (_ammunitionCache != null) return _ammunitionCache!;

    try {
      final querySnapshot = await firestore.collection('ammunition').get();
      _ammunitionCache = querySnapshot.docs.map((doc) => doc.data()).toList();
      return _ammunitionCache!;
    } catch (e) {
      throw Exception('Failed to load ammunition data: $e');
    }
  }

  @override
  void clearCache() {
    _firearmsCache = null;
    _ammunitionCache = null;
  }

  // Fixed dropdown options with proper filtering and caching
  @override
  Future<List<DropdownOption>> getFirearmBrands([String? type]) async {
    try {
      final firearmsData = await _getFirearmsData();

      // Filter by type if provided and not empty
      final filteredData = (type != null && type.isNotEmpty)
          ? firearmsData.where((data) => data['type']?.toString().toLowerCase() == type.toLowerCase())
          : firearmsData;

      final brands = filteredData
          .map((data) => data['brand']?.toString() ?? '')
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
  Future<List<DropdownOption>> getFirearmModels(String brand, [String? type]) async {
    try {
      final firearmsData = await _getFirearmsData();

      // Brand empty ہے تو کوئی models نہیں دکھانا
      if (brand.isEmpty) {
        return [];
      }

      final filteredData = firearmsData.where((data) {
        final matchesBrand = data['brand']?.toString() == brand;
        final matchesType = type == null || type.isEmpty ||
            data['type']?.toString().toLowerCase() == type.toLowerCase();
        return matchesBrand && matchesType;
      });

      final models = filteredData
          .map((data) => data['model']?.toString() ?? '')
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
  Future<List<DropdownOption>> getFirearmGenerations(String brand, String model, [String? type]) async {
    try {
      final firearmsData = await _getFirearmsData();

      // Brand یا model empty ہے تو کوئی generations نہیں دکھانا
      if (brand.isEmpty || model.isEmpty) {
        return [];
      }

      final filteredData = firearmsData.where((data) {
        final matchesBrand = data['brand']?.toString() == brand;
        final matchesModel = data['model']?.toString() == model;
        final matchesType = type == null || type.isEmpty ||
            data['type']?.toString().toLowerCase() == type.toLowerCase();
        return matchesBrand && matchesModel && matchesType;
      });

      final generations = filteredData
          .map((data) => data['generation']?.toString() ?? '')
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
  Future<List<DropdownOption>> getCalibers([String? brand]) async {
    try {
      // Get calibers from both firearms and ammunition collections
      final firearmsData = await _getFirearmsData();
      final ammoData = await _getAmmunitionData();

      final calibers = <String>{};

      // Filter firearms by brand if provided and not empty
      final filteredFirearms = (brand != null && brand.isNotEmpty)
          ? firearmsData.where((data) => data['brand']?.toString() == brand)
          : firearmsData;

      // Filter ammunition by brand if provided and not empty
      final filteredAmmo = (brand != null && brand.isNotEmpty)
          ? ammoData.where((data) => data['brand']?.toString() == brand)
          : ammoData;

      for (final data in filteredFirearms) {
        final caliber = data['caliber']?.toString() ?? '';
        if (caliber.isNotEmpty) calibers.add(caliber);
      }

      for (final data in filteredAmmo) {
        final caliber = data['caliber']?.toString() ?? '';
        if (caliber.isNotEmpty) calibers.add(caliber);
      }

      final caliberList = calibers.toList();
      caliberList.sort();
      return caliberList.map((caliber) => DropdownOption(value: caliber, label: caliber)).toList();
    } catch (e) {
      throw Exception('Failed to get calibers: $e');
    }
  }

  // Firearms CRUD operations remain the same...
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

  // Ammunition CRUD operations remain the same...
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

  // Gear, Tools, Loadouts CRUD operations remain the same...
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



  @override
  Future<List<DropdownOption>> getFirearmFiringMechanisms([String? type]) async {
    try {
      final firearmsData = await _getFirearmsData();

      // Filter by type if provided and not empty
      final filteredData = (type != null && type.isNotEmpty)
          ? firearmsData.where((data) => data['type']?.toString().toLowerCase() == type.toLowerCase())
          : firearmsData;

      final mechanisms = filteredData
          .map((data) => data['firing_machanism']?.toString() ?? '')
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
  Future<List<DropdownOption>> getFirearmMakes([String? type]) async {
    try {
      final firearmsData = await _getFirearmsData();

      // Filter by type if provided and not empty
      final filteredData = (type != null && type.isNotEmpty)
          ? firearmsData.where((data) => data['type']?.toString().toLowerCase() == type.toLowerCase())
          : firearmsData;

      final makes = filteredData
          .map((data) => data['make']?.toString() ?? '')
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
  Future<List<DropdownOption>> getAmmunitionBrands() async {
    try {
      final ammoData = await _getAmmunitionData();
      final brands = ammoData
          .map((data) => data['brand']?.toString() ?? '')
          .where((brand) => brand.isNotEmpty)
          .toSet()
          .toList();

      brands.sort();
      return brands.map((brand) => DropdownOption(value: brand, label: brand)).toList();
    } catch (e) {
      throw Exception('Failed to get ammunition brands: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getBulletTypes([String? caliber]) async {
    try {
      final ammoData = await _getAmmunitionData();

      // Filter ammunition by caliber if provided and not empty
      final filteredAmmo = (caliber != null && caliber.isNotEmpty)
          ? ammoData.where((data) => data['caliber']?.toString() == caliber)
          : ammoData;

      final bullets = filteredAmmo
          .map((data) => data['bullet weight (gr)']?.toString() ?? '')
          .where((bullet) => bullet.isNotEmpty)
          .toSet()
          .toList();

      bullets.sort();
      return bullets.map((bullet) => DropdownOption(value: bullet, label: bullet)).toList();
    } catch (e) {
      throw Exception('Failed to get bullet types: $e');
    }
  }
}