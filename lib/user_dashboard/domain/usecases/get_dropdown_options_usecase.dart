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
        final typeFilter = _isCustomValue(params.filterValue) ? null : params.filterValue;
        return await repository.getFirearmBrands(typeFilter);

      case DropdownType.firearmModels:
        if (_isCustomValue(params.filterValue)) {
          return await repository.getFirearmModels('', null);
        }
        return await repository.getFirearmModels(
            params.filterValue ?? '',
            params.secondaryFilter
        );

      case DropdownType.firearmGenerations:
        if (_isCustomValue(params.filterValue) || _isCustomValue(params.secondaryFilter)) {
          return await repository.getFirearmGenerations('', '', null);
        }
        return await repository.getFirearmGenerations(
          params.filterValue ?? '',
          params.secondaryFilter ?? '',
        );

      case DropdownType.calibers:
        return await repository.getCalibers(
            _isCustomValue(params.filterValue) ? null : params.filterValue,      // brand
            _isCustomValue(params.secondaryFilter) ? null : params.secondaryFilter,  // model
            _isCustomValue(params.tertiaryFilter) ? null : params.tertiaryFilter     // generation
        );

      case DropdownType.firearmFiringMechanisms:
        return await repository.getFirearmFiringMechanisms(
            _isCustomValue(params.filterValue) ? null : params.filterValue,      // type
            _isCustomValue(params.secondaryFilter) ? null : params.secondaryFilter  // caliber
        );

      case DropdownType.firearmMakes:
        return await repository.getFirearmMakes(
            _isCustomValue(params.filterValue) ? null : params.filterValue,          // type
            _isCustomValue(params.secondaryFilter) ? null : params.secondaryFilter,      // brand
            _isCustomValue(params.tertiaryFilter) ? null : params.tertiaryFilter,        // model
            _isCustomValue(params.quaternaryFilter) ? null : params.quaternaryFilter,    // generation
            _isCustomValue(params.quinaryFilter) ? null : params.quinaryFilter          // caliber
        );

      case DropdownType.ammunitionBrands:
        return await repository.getAmmunitionBrands();

      case DropdownType.bulletTypes:
        final caliberFilter = _isCustomValue(params.filterValue) ? null : params.filterValue;
        return await repository.getBulletTypes(caliberFilter);
    }
  }

  bool _isCustomValue(String? value) {

    return value != null && value.startsWith('__CUSTOM__');
  }
}