// lib/dashboard/data/datasources/file_upload_remote_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../models/firearm_model.dart';
import '../models/ammunition_model.dart';

abstract class FileUploadRemoteDataSource {
  Future<List<FirearmModel>> validateFirearmFile(String filePath);
  Future<List<AmmunitionModel>> validateAmmunitionFile(String filePath);
  Future<void> uploadFirearms(List<FirearmModel> firearms);
  Future<void> uploadAmmunitions(List<AmmunitionModel> ammunitions);
  Future<List<FirearmModel>> getFirearms();
  Future<List<AmmunitionModel>> getAmmunitions();
}

class FileUploadRemoteDataSourceImpl implements FileUploadRemoteDataSource {
  final FirebaseFirestore firestore;

  FileUploadRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<FirearmModel>> validateFirearmFile(String filePath) async {
    final data = await _parseFile(filePath);
    if (data.isEmpty) throw Exception('File is empty');

    // Normalize headers to lowercase for comparison
    final headers = data.first.keys.map((e) => e.toString().toLowerCase().trim()).toSet();
    const requiredHeaders = {
      'type', 'brand', 'model', 'generation',
      'caliber', 'firing_machanism', 'make'
    };

    if (!requiredHeaders.every((header) => headers.contains(header))) {
      throw Exception('Wrong file type. Required headers: ${requiredHeaders.join(', ')}');
    }

    return data.map((row) => FirearmModel.fromMap(row)).toList();
  }

  @override
  Future<List<AmmunitionModel>> validateAmmunitionFile(String filePath) async {
    final data = await _parseFile(filePath);
    if (data.isEmpty) throw Exception('File is empty');

    // Normalize headers to lowercase for comparison
    final headers = data.first.keys.map((e) => e.toString().toLowerCase().trim()).toSet();
    const requiredHeaders = {'brand', 'caliber', 'bullet weight (gr)'};

    if (!requiredHeaders.every((header) => headers.contains(header))) {
      throw Exception('Wrong file type. Required headers: Brand, Caliber, Bullet Weight (gr)');
    }

    return data.map((row) => AmmunitionModel.fromMap(row)).toList();
  }

  @override
  Future<void> uploadFirearms(List<FirearmModel> firearms) async {
    final collection = firestore.collection('firearms');

    // Get existing count
    final existingDocs = await collection.get();
    final existingCount = existingDocs.docs.length;

    // Check length condition
    if (firearms.length < existingCount) {
      throw Exception(
          'Upload failed: Firearms list length (${firearms.length}) is less than existing records ($existingCount).');
    }

    // Batch delete and upload
    final batch = firestore.batch();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }
    for (final firearm in firearms) {
      final docRef = collection.doc();
      batch.set(docRef, firearm.toMap());
    }
    await batch.commit();
  }

  @override
  Future<void> uploadAmmunitions(List<AmmunitionModel> ammunitions) async {
    final collection = firestore.collection('ammunition');

    // Get existing count
    final existingDocs = await collection.get();
    final existingCount = existingDocs.docs.length;

    if (ammunitions.length < existingCount) {
      throw Exception(
          'Upload failed: Ammunition list length (${ammunitions.length}) is less than existing records ($existingCount).');
    }

    final batch = firestore.batch();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }
    for (final ammunition in ammunitions) {
      final docRef = collection.doc();
      batch.set(docRef, ammunition.toMap());
    }
    await batch.commit();
  }


  @override
  Future<List<FirearmModel>> getFirearms() async {
    try {
      final querySnapshot = await firestore.collection('firearms').get();
      return querySnapshot.docs
          .map((doc) => FirearmModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch firearms: $e');
    }
  }

  @override
  Future<List<AmmunitionModel>> getAmmunitions() async {
    try {
      final querySnapshot = await firestore.collection('ammunition').get();
      return querySnapshot.docs
          .map((doc) => AmmunitionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch ammunitions: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _parseFile(String filePath) async {
    final file = File(filePath);
    final extension = filePath.split('.').last.toLowerCase();

    if (extension == 'csv') {
      final content = await file.readAsString();
      final cleanedContent = content.replaceAll('\uFEFF', ''); // Remove BOM
      final List<List<dynamic>> csvData =
      const CsvToListConverter(eol: '\n').convert(cleanedContent);

      if (csvData.isEmpty) return [];

// Normalize headers
      final headers = csvData.first
          .map((e) => e.toString().toLowerCase().trim())
          .toList();
      final rows = csvData.skip(1).toList();

      return rows.map((row) {
        final map = <String, dynamic>{};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          map[headers[i]] = row[i];
        }
        return map;
      }).toList();
    } else if (extension == 'xlsx' || extension == 'xls') {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.tables.values.first;
      if (sheet == null || sheet.rows.isEmpty) return [];

      // Normalize headers to lowercase and trim whitespace
      final headers = sheet.rows.first.map((cell) => cell?.value.toString().toLowerCase().trim() ?? '').toList();
      final rows = sheet.rows.skip(1).toList();

      return rows.map((row) {
        final map = <String, dynamic>{};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          map[headers[i]] = row[i]?.value;
        }
        return map;
      }).toList();
    } else {
      throw Exception('Unsupported file format. Please select CSV or Excel file.');
    }
  }
}