// lib/user_dashboard/data/datasources/armory_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/armory_firearm_model.dart';
import '../models/armory_ammunition_model.dart';
import '../models/armory_gear_model.dart';
import '../models/armory_maintenance_model.dart';
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
  Future<List<DropdownOption>> getFirearmModels( [String? brand,String? type]);
  Future<List<DropdownOption>> getFirearmGenerations( [String? brand, String? model,String? type]);
  Future<List<DropdownOption>> getFirearmFiringMechanisms([String? type, String? caliber]);
  Future<List<DropdownOption>> getFirearmMakes([String? type, String? brand, String? model, String? generation, String? caliber]);
  Future<List<DropdownOption>> getCalibers([String? brand, String? model, String? generation]);
  Future<List<DropdownOption>> getAmmunitionBrands();
  Future<List<DropdownOption>> getBulletTypes([String? caliber]);


  // Maintenance
  Future<List<ArmoryMaintenanceModel>> getMaintenance(String userId);
  Future<void> addMaintenance(String userId, ArmoryMaintenanceModel maintenance);



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



  // User's personal armory data load کرنے کے لیے نئے methods
  Future<List<Map<String, dynamic>>> _getUserFirearmsData() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return [];

      final querySnapshot = await firestore
          .collection('armory')
          .doc(currentUserId)
          .collection('firearms')
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return []; // Error case میں empty list return کریں
    }
  }

  Future<List<Map<String, dynamic>>> _getUserAmmunitionData() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return [];

      final querySnapshot = await firestore
          .collection('armory')
          .doc(currentUserId)
          .collection('ammunition')
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return []; // Error case میں empty list return کریں
    }
  }

// Helper method to merge and deduplicate data
  List<String> _mergeAndDeduplicateStrings(
      List<Map<String, dynamic>> referenceData,
      List<Map<String, dynamic>> userData,
      String field,
      [String? filterField,
        String? filterValue])
  {

    final allValues = <String>{};

    // Reference data سے values نکالیں
    for (final data in referenceData) {
      if (filterField != null && filterValue != null) {
        if (data[filterField]?.toString().toLowerCase() != filterValue.toLowerCase()) {
          continue;
        }
      }
      final value = data[field]?.toString() ?? '';
      if (value.isNotEmpty) allValues.add(value);
    }

    // User data سے values نکالیں
    for (final data in userData) {
      if (filterField != null && filterValue != null) {
        if (data[filterField]?.toString().toLowerCase() != filterValue.toLowerCase()) {
          continue;
        }
      }
      final value = data[field]?.toString() ?? '';
      if (value.isNotEmpty) allValues.add(value);
    }

    final result = allValues.toList();
    result.sort();
    return result;
  }

// Updated dropdown methods

  @override
  Future<List<DropdownOption>> getCalibers([
    String? brand, String? model, String? generation]) async
  {
    try {
      final firearmsRefData = await _getFirearmsData();
      final ammoRefData = await _getAmmunitionData();
      final userFirearmsData = await _getUserFirearmsData();
      final userAmmoData = await _getUserAmmunitionData();

      final calibers = <String>{};
      final allFirearmsData = [...firearmsRefData, ...userFirearmsData];
      final allAmmoData = [...ammoRefData, ...userAmmoData];

      // Filter firearms data based on brand, model, generation
      final filteredFirearms = allFirearmsData.where((data) {
        bool matches = true;

        if (brand?.isNotEmpty == true && !_isCustomValue(brand)) {
          matches = matches && data['brand']?.toString() == brand;
        }
        if (model?.isNotEmpty == true && !_isCustomValue(model)) {
          matches = matches && data['model']?.toString() == model;
        }
        if (generation?.isNotEmpty == true && !_isCustomValue(generation)) {
          matches = matches && data['generation']?.toString() == generation;
        }

        return matches;
      });

      // Also include ammo data filtered by brand if available
      final filteredAmmo = allAmmoData.where((data) {
        if (brand?.isNotEmpty == true && !_isCustomValue(brand)) {
          return data['brand']?.toString() == brand;
        }
        return true;
      });

      // Collect calibers from both sources
      for (final data in [...filteredFirearms, ...filteredAmmo]) {
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

  @override
  Future<List<DropdownOption>> getFirearmFiringMechanisms([
    String? type, String? caliber]) async
  {
    try {
      final firearmsData = await _getFirearmsData();
      final userFirearmsData = await _getUserFirearmsData();
      final allData = [...firearmsData, ...userFirearmsData];

      final filteredData = allData.where((data) {
        bool matches = true;

        if (type?.isNotEmpty == true && !_isCustomValue(type)) {
          matches = matches && data['type']?.toString().toLowerCase() == type?.toLowerCase();
        }
        if (caliber?.isNotEmpty == true && !_isCustomValue(caliber)) {
          matches = matches && data['caliber']?.toString() == caliber;
        }

        return matches;
      });

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
  Future<List<DropdownOption>> getFirearmMakes([
    String? type, String? brand, String? model, String? generation, String? caliber]) async
  {
    try {
      final referenceData = await _getFirearmsData();
      final userData = await _getUserFirearmsData();
      final allData = [...referenceData, ...userData];

      final filteredData = allData.where((data) {
        bool matches = true;

        if (type?.isNotEmpty == true && !_isCustomValue(type)) {
          matches = matches && data['type']?.toString().toLowerCase() == type?.toLowerCase();
        }
        if (brand?.isNotEmpty == true && !_isCustomValue(brand)) {
          matches = matches && data['brand']?.toString() == brand;
        }
        if (model?.isNotEmpty == true && !_isCustomValue(model)) {
          matches = matches && data['model']?.toString() == model;
        }
        if (generation?.isNotEmpty == true && !_isCustomValue(generation)) {
          matches = matches && data['generation']?.toString() == generation;
        }
        if (caliber?.isNotEmpty == true && !_isCustomValue(caliber)) {
          matches = matches && data['caliber']?.toString() == caliber;
        }

        return matches;
      });

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

  // Helper method to check if value is custom
  bool _isCustomValue(String? value) {
    return value != null && value.startsWith('__CUSTOM__');
  }

  @override
  Future<List<DropdownOption>> getFirearmBrands([String? type]) async {
    try {
      final referenceData = await _getFirearmsData();
      final userData = await _getUserFirearmsData();

      final brands = _mergeAndDeduplicateStrings(
          referenceData,
          userData,
          'brand',
          type?.isNotEmpty == true ? 'type' : null,
          type
      );

      return brands.map((brand) => DropdownOption(value: brand, label: brand)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm brands: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmModels([String? brand, String? type]) async {
    try {
      final refData = await _getFirearmsData();
      final userData = await _getUserFirearmsData();
      final allData = [...refData, ...userData];

      final filteredData = allData.where((data) {
        bool matches = true;

        if (brand?.isNotEmpty == true && !_isCustomValue(brand)) {
          matches = matches && data['brand']?.toString() == brand;
        }
        if (type?.isNotEmpty == true && !_isCustomValue(type)) {
          matches = matches && data['type']?.toString().toLowerCase() == type?.toLowerCase();
        }

        return matches;
      });

      final models = filteredData
          .map((data) => data['model']?.toString() ?? '')
          .where((m) => m.isNotEmpty)
          .toSet()
          .toList();

      models.sort();
      return models.map((m) => DropdownOption(value: m, label: m)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm models: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmGenerations([String? brand, String? model, String? type]) async {
    try {
      final refData = await _getFirearmsData();
      final userData = await _getUserFirearmsData();
      final allData = [...refData, ...userData];

      final filteredData = allData.where((data) {
        bool matches = true;

        if (brand?.isNotEmpty == true && !_isCustomValue(brand)) {
          matches = matches && data['brand']?.toString() == brand;
        }
        if (model?.isNotEmpty == true && !_isCustomValue(model)) {
          matches = matches && data['model']?.toString() == model;
        }
        if (type?.isNotEmpty == true && !_isCustomValue(type)) {
          matches = matches && data['type']?.toString().toLowerCase() == type?.toLowerCase();
        }

        return matches;
      });

      final generations = filteredData
          .map((data) => data['generation']?.toString() ?? '')
          .where((g) => g.isNotEmpty)
          .toSet()
          .toList();

      generations.sort();
      return generations.map((g) => DropdownOption(value: g, label: g)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm generations: $e');
    }
  }


  @override
  Future<List<DropdownOption>> getAmmunitionBrands() async {
    try {
      final referenceData = await _getAmmunitionData();
      final userData = await _getUserAmmunitionData();

      final brands = _mergeAndDeduplicateStrings(referenceData, userData, 'brand');

      return brands.map((brand) => DropdownOption(value: brand, label: brand)).toList();
    } catch (e) {
      throw Exception('Failed to get ammunition brands: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getBulletTypes([String? caliber]) async {
    try {
      final referenceData = await _getAmmunitionData();
      final userData = await _getUserAmmunitionData();

      final bulletTypes = _mergeAndDeduplicateStrings(
          referenceData,
          userData,
          'bullet weight (gr)',
          caliber?.isNotEmpty == true ? 'caliber' : null,
          caliber
      );

      return bulletTypes.map((bullet) => DropdownOption(value: bullet, label: bullet)).toList();
    } catch (e) {
      throw Exception('Failed to get bullet types: $e');
    }
  }



  @override
  Future<List<ArmoryMaintenanceModel>> getMaintenance(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('armory')
          .doc(userId)
          .collection('maintenance')
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ArmoryMaintenanceModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get maintenance: $e');
    }
  }

  @override
  Future<void> addMaintenance(String userId, ArmoryMaintenanceModel maintenance) async {
    try {
      await firestore
          .collection('armory')
          .doc(userId)
          .collection('maintenance')
          .add(maintenance.toMap());
    } catch (e) {
      throw Exception('Failed to add maintenance: $e');
    }
  }
}