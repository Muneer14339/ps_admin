// lib/core/permissions/presentation/bloc/permission_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../usecases/usecase.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/usecases/request_storage_permission_usecase.dart';
import '../../domain/usecases/open_app_settings_usecase.dart';
import 'permission_event.dart';
import 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final RequestStoragePermissionUseCase requestStoragePermissionUseCase;
  final OpenAppSettingsUseCase openAppSettingsUseCase;

  PermissionBloc({
    required this.requestStoragePermissionUseCase,
    required this.openAppSettingsUseCase,
  }) : super(const PermissionInitial()) {
    on<RequestStoragePermissionEvent>(_onRequestStoragePermission);
    on<OpenAppSettingsEvent>(_onOpenAppSettings);
    on<ResetPermissionStateEvent>(_onResetPermissionState);
  }

  void _onRequestStoragePermission(
      RequestStoragePermissionEvent event,
      Emitter<PermissionState> emit,
      ) async {
    emit(const PermissionLoading());

    final result = await requestStoragePermissionUseCase(const NoParams());

    result.fold(
          (failure) => emit(PermissionError(message: failure.toString())),
          (status) {
        switch (status.result) {
          case PermissionResult.granted:
            emit(const PermissionGranted());
            break;
          case PermissionResult.denied:
            emit(const PermissionDenied());
            break;
          case PermissionResult.permanentlyDenied:
            emit(const PermissionPermanentlyDenied());
            break;
          case PermissionResult.restricted:
            emit(const PermissionError(message: 'Permission restricted by system'));
            break;
        }
      },
    );
  }

  void _onOpenAppSettings(
      OpenAppSettingsEvent event,
      Emitter<PermissionState> emit,
      ) async {
    final result = await openAppSettingsUseCase(const NoParams());

    result.fold(
          (failure) => emit(PermissionError(message: failure.toString())),
          (_) {
        // After opening settings, reset state so user can try again
        emit(const PermissionInitial());
      },
    );
  }

  void _onResetPermissionState(
      ResetPermissionStateEvent event,
      Emitter<PermissionState> emit,
      ) {
    emit(const PermissionInitial());
  }
}