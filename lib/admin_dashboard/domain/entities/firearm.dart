// lib/home_feature/domain/entities/firearm.dart
import 'package:equatable/equatable.dart';

class Firearm extends Equatable {
  final String type;
  final String brand;
  final String model;
  final String generation;
  final String caliber;
  final String firingMachanism;
  final String make;
  final Map<String, dynamic>? additionalFields;

  const Firearm({
    required this.type,
    required this.brand,
    required this.model,
    required this.generation,
    required this.caliber,
    required this.firingMachanism,
    required this.make,
    this.additionalFields,
  });

  @override
  List<Object?> get props => [
    type, brand, model, generation, caliber, firingMachanism, make, additionalFields
  ];
}