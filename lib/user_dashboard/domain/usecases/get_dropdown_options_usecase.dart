// lib/user_dashboard/domain/usecases/get_dropdown_options_usecase.dart - Update call method

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
       // final typeFilter = _isCustomValue(params.filterValue) ? null : params.filterValue;
        return await repository.getFirearmBrands(params.filterValue);

      case DropdownType.firearmModels:
        if (_isCustomValue(params.filterValue)) {
          return await repository.getFirearmModels('');
        }
        return await repository.getFirearmModels(
            params.filterValue ?? '',
        );

      case DropdownType.firearmGenerations:
        if (_isCustomValue(params.filterValue) || _isCustomValue(params.secondaryFilter)) {
          return await repository.getFirearmGenerations('');
        }
        return await repository.getFirearmGenerations(
          params.filterValue ?? '',
        );

      case DropdownType.calibers:
        return await repository.getCalibers(
            _isCustomValue(params.filterValue) ? null : params.filterValue,
        );

      case DropdownType.firearmFiringMechanisms:
        return await repository.getFirearmFiringMechanisms(
            _isCustomValue(params.filterValue) ? null : params.filterValue,      // caliber
        );

      case DropdownType.firearmMakes:
        return await repository.getFirearmMakes(
            _isCustomValue(params.filterValue) ? null : params.filterValue,          // caliber
        );

      case DropdownType.ammunitionBrands:
        return await repository.getAmmunitionBrands();

      case DropdownType.ammunitionCaliber:
        return await repository.getAmmoCalibers(
          _isCustomValue(params.filterValue) ? null : params.filterValue,
        );

      case DropdownType.bulletTypes:
        final caliberFilter = _isCustomValue(params.filterValue) ? null : params.filterValue;
        return await repository.getBulletTypes(caliberFilter);
    }
  }

  bool _isCustomValue(String? value) {

    return value != null && value.startsWith('__CUSTOM__');
  }
}