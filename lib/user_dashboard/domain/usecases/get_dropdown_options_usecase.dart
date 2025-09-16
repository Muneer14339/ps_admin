// lib/user_dashboard/domain/usecases/get_dropdown_options_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/dropdown_option.dart';
import '../repositories/armory_repository.dart';

class GetDropdownOptionsUseCase implements UseCase<List<DropdownOption>, DropdownParams> {
  final ArmoryRepository repository;

  GetDropdownOptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DropdownOption>>> call(DropdownParams params) async {
    switch (params.type) {
      case DropdownType.firearmBrands:
      // Pass type filter only if not custom
        final typeFilter = _isCustomValue(params.filterValue) ? null : params.filterValue;
        return await repository.getFirearmBrands(typeFilter);

      case DropdownType.firearmModels:
      // Show all models if brand is custom
        if (_isCustomValue(params.filterValue)) {
          return await repository.getFirearmModels('', null); // No filtering
        }
        return await repository.getFirearmModels(
            params.filterValue ?? '',
            params.secondaryFilter
        );

      case DropdownType.firearmGenerations:
      // Show all generations if brand or model is custom
        if (_isCustomValue(params.filterValue) || _isCustomValue(params.secondaryFilter)) {
          return await repository.getFirearmGenerations('', '', null); // No filtering
        }
        return await repository.getFirearmGenerations(
          params.filterValue ?? '',
          params.secondaryFilter ?? '',
        );

      case DropdownType.firearmFiringMechanisms:
        return await repository.getFirearmFiringMechanisms();

      case DropdownType.firearmMakes:
        return await repository.getFirearmMakes();

      case DropdownType.calibers:
      // Show all calibers if brand is custom
        final brandFilter = _isCustomValue(params.filterValue) ? null : params.filterValue;
        return await repository.getCalibers(brandFilter);

      case DropdownType.ammunitionBrands:
        return await repository.getAmmunitionBrands();
    }
  }

  // Helper method to check if value is custom
  bool _isCustomValue(String? value) {
    return value != null && value.startsWith('__CUSTOM__');
  }
}