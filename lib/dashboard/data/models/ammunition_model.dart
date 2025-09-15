// lib/home_feature/data/models/ammunition_model.dart
import '../../domain/entities/ammunition.dart';

class AmmunitionModel extends Ammunition {
  const AmmunitionModel({
    required super.brand,
    required super.caliber,
    required super.bulletWeight,
    super.additionalFields,
  });

  factory AmmunitionModel.fromMap(Map<String, dynamic> map) {
    // Required headers
    const requiredFields = {'brand', 'caliber', 'bullet weight (gr)'};

    // Extract additional fields
    final additionalFields = <String, dynamic>{};
    for (final entry in map.entries) {
      if (!requiredFields.contains(entry.key.toLowerCase())) {
        additionalFields[entry.key] = entry.value;
      }
    }

    return AmmunitionModel(
      brand: map['brand']?.toString() ?? '',
      caliber: map['caliber']?.toString() ?? '',
      bulletWeight: map['bullet weight (gr)']?.toString() ?? '',
      additionalFields: additionalFields.isEmpty ? null : additionalFields,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'brand': brand,
      'caliber': caliber,
      'bullet weight (gr)': bulletWeight,
    };

    if (additionalFields != null) {
      map.addAll(additionalFields!);
    }

    return map;
  }
}