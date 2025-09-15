// lib/home_feature/domain/entities/ammunition.dart
import 'package:equatable/equatable.dart';

class Ammunition extends Equatable {
  final String brand;
  final String caliber;
  final String bulletWeight;
  final Map<String, dynamic>? additionalFields;

  const Ammunition({
    required this.brand,
    required this.caliber,
    required this.bulletWeight,
    this.additionalFields,
  });

  @override
  List<Object?> get props => [brand, caliber, bulletWeight, additionalFields];
}