// lib/user_dashboard/presentation/bloc/armory_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_maintenance_usecase.dart';
import '../../domain/usecases/get_firearms_usecase.dart';
import '../../domain/usecases/add_firearm_usecase.dart';
import '../../domain/usecases/get_ammunition_usecase.dart';
import '../../domain/usecases/add_ammunition_usecase.dart';
import '../../domain/usecases/get_gear_usecase.dart';
import '../../domain/usecases/add_gear_usecase.dart';
import '../../domain/usecases/get_maintenance_usecase.dart';
import '../../domain/usecases/get_tools_usecase.dart';
import '../../domain/usecases/add_tool_usecase.dart';
import '../../domain/usecases/get_loadouts_usecase.dart';
import '../../domain/usecases/add_loadout_usecase.dart';
import '../../domain/usecases/get_dropdown_options_usecase.dart';
import 'armory_event.dart';
import 'armory_state.dart';

class ArmoryBloc extends Bloc<ArmoryEvent, ArmoryState> {
  final GetFirearmsUseCase getFirearmsUseCase;
  final AddFirearmUseCase addFirearmUseCase;
  final GetAmmunitionUseCase getAmmunitionUseCase;
  final AddAmmunitionUseCase addAmmunitionUseCase;
  final GetGearUseCase getGearUseCase;
  final AddGearUseCase addGearUseCase;
  final GetToolsUseCase getToolsUseCase;
  final AddToolUseCase addToolUseCase;
  final GetLoadoutsUseCase getLoadoutsUseCase;
  final AddLoadoutUseCase addLoadoutUseCase;
  final GetDropdownOptionsUseCase getDropdownOptionsUseCase;
  final GetMaintenanceUseCase getMaintenanceUseCase;
  final AddMaintenanceUseCase addMaintenanceUseCase;

  ArmoryBloc({
    required this.getFirearmsUseCase,
    required this.addFirearmUseCase,
    required this.getAmmunitionUseCase,
    required this.addAmmunitionUseCase,
    required this.getGearUseCase,
    required this.addGearUseCase,
    required this.getToolsUseCase,
    required this.addToolUseCase,
    required this.getLoadoutsUseCase,
    required this.addLoadoutUseCase,
    required this.getDropdownOptionsUseCase,
    required this.getMaintenanceUseCase,
    required this.addMaintenanceUseCase,
  }) : super(const ArmoryInitial()) {
    on<LoadFirearmsEvent>(_onLoadFirearms);
    on<LoadAmmunitionEvent>(_onLoadAmmunition);
    on<LoadGearEvent>(_onLoadGear);
    on<LoadToolsEvent>(_onLoadTools);
    on<LoadLoadoutsEvent>(_onLoadLoadouts);
    on<AddFirearmEvent>(_onAddFirearm);
    on<AddAmmunitionEvent>(_onAddAmmunition);
    on<AddGearEvent>(_onAddGear);
    on<AddToolEvent>(_onAddTool);
    on<AddLoadoutEvent>(_onAddLoadout);
    on<LoadDropdownOptionsEvent>(_onLoadDropdownOptions);
    on<LoadMaintenanceEvent>(_onLoadMaintenance);
    on<AddMaintenanceEvent>(_onAddMaintenance);
  }

  void _onLoadFirearms(LoadFirearmsEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoading());

    final result = await getFirearmsUseCase(UserIdParams(userId: event.userId));

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (firearms) => emit(FirearmsLoaded(firearms: firearms)),
    );
  }

  void _onLoadAmmunition(LoadAmmunitionEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoading());

    final result = await getAmmunitionUseCase(UserIdParams(userId: event.userId));

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (ammunition) => emit(AmmunitionLoaded(ammunition: ammunition)),
    );
  }

  void _onLoadGear(LoadGearEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoading());

    final result = await getGearUseCase(UserIdParams(userId: event.userId));

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (gear) => emit(GearLoaded(gear: gear)),
    );
  }

  void _onLoadTools(LoadToolsEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoading());

    final result = await getToolsUseCase(UserIdParams(userId: event.userId));

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (tools) => emit(ToolsLoaded(tools: tools)),
    );
  }

  void _onLoadLoadouts(LoadLoadoutsEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoading());

    final result = await getLoadoutsUseCase(UserIdParams(userId: event.userId));

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (loadouts) => emit(LoadoutsLoaded(loadouts: loadouts)),
    );
  }

  void _onAddFirearm(AddFirearmEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoadingAction());

    final result = await addFirearmUseCase(
      AddFirearmParams(userId: event.userId, firearm: event.firearm),
    );

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (_) {
        emit(const ArmoryActionSuccess(message: 'Firearm added successfully!'));
        // Reload firearms list
        add(LoadFirearmsEvent(userId: event.userId));
      },
    );
  }

  void _onAddAmmunition(AddAmmunitionEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoadingAction());

    final result = await addAmmunitionUseCase(
      AddAmmunitionParams(userId: event.userId, ammunition: event.ammunition),
    );

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (_) {
        emit(const ArmoryActionSuccess(message: 'Ammunition added successfully!'));
        // Reload ammunition list
        add(LoadAmmunitionEvent(userId: event.userId));
      },
    );
  }

  void _onAddGear(AddGearEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoadingAction());

    final result = await addGearUseCase(
      AddGearParams(userId: event.userId, gear: event.gear),
    );

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (_) {
        emit(const ArmoryActionSuccess(message: 'Gear added successfully!'));
        // Reload gear list
        add(LoadGearEvent(userId: event.userId));
      },
    );
  }

  void _onAddTool(AddToolEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoadingAction());

    final result = await addToolUseCase(
      AddToolParams(userId: event.userId, tool: event.tool),
    );

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (_) {
        emit(const ArmoryActionSuccess(message: 'Tool added successfully!'));
        // Reload tools list
        add(LoadToolsEvent(userId: event.userId));
      },
    );
  }

  void _onAddLoadout(AddLoadoutEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoadingAction());

    final result = await addLoadoutUseCase(
      AddLoadoutParams(userId: event.userId, loadout: event.loadout),
    );

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (_) {
        emit(const ArmoryActionSuccess(message: 'Loadout added successfully!'));
        // Reload loadouts list
        add(LoadLoadoutsEvent(userId: event.userId));
      },
    );
  }

  void _onLoadDropdownOptions(LoadDropdownOptionsEvent event, Emitter<ArmoryState> emit) async {
    final result = await getDropdownOptionsUseCase(
      DropdownParams(
        type: event.type,
        filterValue: event.filterValue, // Add this
      ),
    );

    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (options) => emit(DropdownOptionsLoaded(options: options)),
    );
  }

  void _onLoadMaintenance(LoadMaintenanceEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoading());
    final result = await getMaintenanceUseCase(UserIdParams(userId: event.userId));
    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (maintenance) => emit(MaintenanceLoaded(maintenance: maintenance)),
    );
  }

  void _onAddMaintenance(AddMaintenanceEvent event, Emitter<ArmoryState> emit) async {
    emit(const ArmoryLoadingAction());
    final result = await addMaintenanceUseCase(
      AddMaintenanceParams(userId: event.userId, maintenance: event.maintenance),
    );
    result.fold(
          (failure) => emit(ArmoryError(message: failure.toString())),
          (_) {
        emit(const ArmoryActionSuccess(message: 'Maintenance log added successfully!'));
        add(LoadMaintenanceEvent(userId: event.userId));
      },
    );
  }
}