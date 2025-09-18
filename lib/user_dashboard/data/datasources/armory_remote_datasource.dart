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
  Future<List<DropdownOption>> getFirearmModels( [String? brand]);
  Future<List<DropdownOption>> getFirearmGenerations( [ String? model]);
  Future<List<DropdownOption>> getFirearmFiringMechanisms( [String? caliber]);
  Future<List<DropdownOption>> getFirearmMakes([String?  firingMechanism,]);
  Future<List<DropdownOption>> getCalibers([String? generation,]);
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
  // Caches
  List<Map<String, dynamic>>? _firearmsCache;
  List<Map<String, dynamic>>? _ammunitionCache;
  List<Map<String, dynamic>>? _userFirearmsCache;
  List<Map<String, dynamic>>? _userAmmunitionCache;

// Filtered lists
  List<Map<String, dynamic>>? filteredFirearmBrands;
  List<Map<String, dynamic>>? filteredFirearmModel;
  List<Map<String, dynamic>>? filteredFirearmGeneration;
  List<Map<String, dynamic>>? filteredFirearmCaliber;
  List<Map<String, dynamic>>? filteredFirearmFiringMechanism;
  List<Map<String, dynamic>>? filteredFirearmMakes;

  List<Map<String, dynamic>>? filteredAmmoBrands;
  List<Map<String, dynamic>>? filteredAmmoCaliber;
  List<Map<String, dynamic>>? filteredAmmoBulletWeight;

  /// Call this ONCE (e.g., in a repository init method or when opening the Armory screen)
  Future<void> initializeArmoryData() async {
    _firearmsCache ??= await _getFirearmsData();
    _ammunitionCache ??= await _getAmmunitionData();
    _userFirearmsCache ??= await _getUserFirearmsData();
    _userAmmunitionCache ??= await _getUserAmmunitionData();
  }

  List<Map<String, dynamic>> get allFirearmsData =>
      [...?_firearmsCache, ...?_userFirearmsCache];
  List<Map<String, dynamic>> get allAmmoData =>
      [...?_ammunitionCache, ...?_userAmmunitionCache];


  ArmoryRemoteDataSourceImpl({required this.firestore});

  List<Map<String, dynamic>> _filterData({
    required List<Map<String, dynamic>> source,
    String? field,
    String? value,
  })
  {
    if (value == null || value.isEmpty || value.startsWith('__CUSTOM__')) {
      return source;
    }
    return source.where((item) => item[field]?.toString() == value).toList();
  }


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




  // Helper method to check if value is custom
  bool _isCustomValue(String? value) {
    return value != null && value.startsWith('__CUSTOM__');
  }


  @override
  Future<List<DropdownOption>> getFirearmBrands([String? type]) async {
    try {
      await initializeArmoryData();
      final filtered = _filterData(
        source: allFirearmsData,
        field: 'type',
        value: type,
      );

      final brands = filtered.map((e) => e['brand']?.toString() ?? '').where((b) => b.isNotEmpty).toSet().toList();
      brands.sort();
      filteredFirearmBrands = filtered; // Save for next filters
      filteredFirearmModel = filteredFirearmGeneration = filteredFirearmCaliber =
          filteredFirearmFiringMechanism = filteredFirearmMakes = null;

      return brands.map((brand) => DropdownOption(value: brand, label: brand)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm brands: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmModels([String? brand]) async {
    try {
      if (filteredFirearmBrands == null) return [];
      final filtered = _filterData(
        source: filteredFirearmBrands!,
        field: 'brand',
        value: brand,
      );

      final models = filtered.map((e) => e['model']?.toString() ?? '').where((m) => m.isNotEmpty).toSet().toList();
      models.sort();
      filteredFirearmModel = filtered;
      filteredFirearmGeneration = filteredFirearmCaliber =
          filteredFirearmFiringMechanism = filteredFirearmMakes = null;
      return models.map((m) => DropdownOption(value: m, label: m)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm models: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmGenerations([String? model]) async {
    try {
      if (filteredFirearmModel == null) return [];
      final filtered = _filterData(
        source: filteredFirearmModel!,
        field: 'model',
        value: model,
      );

      final generations = filtered
          .map((e) => e['generation']?.toString() ?? '')
          .where((g) => g.isNotEmpty)
          .toSet()
          .toList();
      generations.sort();
      filteredFirearmGeneration = filtered;

      // Reset deeper filters
      filteredFirearmCaliber = filteredFirearmFiringMechanism = filteredFirearmMakes = null;
      return generations.map((g) => DropdownOption(value: g, label: g)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm generations: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getCalibers([String? generation]) async
  {
    try {
      if (filteredFirearmGeneration == null) return [];
      final filtered = _filterData(
        source: filteredFirearmGeneration!,
        field: 'generation',
        value: generation,
      );

      final calibers = filtered
          .map((e) => e['caliber']?.toString() ?? '')
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      calibers.sort();
      filteredFirearmCaliber = filtered;

      // Reset deeper filters
      filteredFirearmFiringMechanism = filteredFirearmMakes = null;
      return calibers.map((caliber) => DropdownOption(value: caliber, label: caliber)).toList();
    } catch (e) {
      throw Exception('Failed to get calibers: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmFiringMechanisms([String? caliber]) async
  {
    try {
      if (filteredFirearmCaliber == null) return [];
      final filtered = _filterData(
        source: filteredFirearmCaliber!,
        field: 'caliber',
        value: caliber,
      );

      final mechanisms = filtered
          .map((e) => e['firing_machanism']?.toString() ?? '')
          .where((m) => m.isNotEmpty)
          .toSet()
          .toList();
      mechanisms.sort();
      filteredFirearmFiringMechanism = filtered;

      // Reset deeper filter
      filteredFirearmMakes = null;
      return mechanisms.map((mech) => DropdownOption(value: mech, label: mech)).toList();
    } catch (e) {
      throw Exception('Failed to get firing mechanisms: $e');
    }
  }

  @override
  Future<List<DropdownOption>> getFirearmMakes([
    String?  firingMechanism]) async
  {
    try {
      if (filteredFirearmFiringMechanism == null) return [];
      final filtered = _filterData(
        source: filteredFirearmFiringMechanism!,
        field: 'firing_machanism',
        value: firingMechanism,
      );

      final makes = filtered
          .map((e) => e['make']?.toString() ?? '')
          .where((m) => m.isNotEmpty)
          .toSet()
          .toList();
      makes.sort();
      filteredFirearmMakes = filtered;
      return makes.map((make) => DropdownOption(value: make, label: make)).toList();
    } catch (e) {
      throw Exception('Failed to get firearm makes: $e');
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