// lib/user_dashboard/domain/usecases/get_firearms_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/armory_firearm.dart';
import '../entities/dropdown_option.dart';
import '../repositories/armory_repository.dart';
// lib/user_dashboard/domain/usecases/get_dropdown_options_usecase.dart
class GetDropdownOptionsUseCase implements UseCase<List<DropdownOption>, DropdownParams> {
  final ArmoryRepository repository;

  GetDropdownOptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DropdownOption>>> call(DropdownParams params) async {
    switch (params.type) {
      case DropdownType.firearmBrands:
        return await repository.getFirearmBrands();
      case DropdownType.firearmModels:
        return await repository.getFirearmModels(params.filterValue ?? '');
      case DropdownType.firearmGenerations:
        return await repository.getFirearmGenerations(
            params.filterValue ?? '',
            params.secondaryFilter ?? ''
        );
      case DropdownType.firearmFiringMechanisms:
        return await repository.getFirearmFiringMechanisms();
      case DropdownType.firearmMakes:
        return await repository.getFirearmMakes();
      case DropdownType.calibers:
        return await repository.getCalibers();
      case DropdownType.ammunitionBrands:
        return await repository.getAmmunitionBrands();
    }
  }
}