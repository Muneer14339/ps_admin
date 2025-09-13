// lib/home_feature/data/models/firearm_model.dart
import '../../domain/entities/firearm.dart';

class FirearmModel extends Firearm {
  const FirearmModel({
    required super.type,
    required super.brand,
    required super.model,
    required super.generation,
    required super.caliber,
    required super.firingMachanism,
    required super.make,
    super.additionalFields,
  });

  factory FirearmModel.fromMap(Map<String, dynamic> map) {
    // Required headers
    const requiredFields = {
      'type', 'brand', 'model', 'generation',
      'caliber', 'firing_machanism', 'make'
    };

    // Extract additional fields
    final additionalFields = <String, dynamic>{};
    for (final entry in map.entries) {
      if (!requiredFields.contains(entry.key.toLowerCase())) {
        additionalFields[entry.key] = entry.value;
      }
    }

    return FirearmModel(
      type: map['type']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      generation: map['generation']?.toString() ?? '',
      caliber: map['caliber']?.toString() ?? '',
      firingMachanism: map['firing_machanism']?.toString() ?? '',
      make: map['make']?.toString() ?? '',
      additionalFields: additionalFields.isEmpty ? null : additionalFields,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'type': type,
      'brand': brand,
      'model': model,
      'generation': generation,
      'caliber': caliber,
      'firing_machanism': firingMachanism,
      'make': make,
    };

    if (additionalFields != null) {
      map.addAll(additionalFields!);
    }

    return map;
  }
}