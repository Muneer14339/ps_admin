// lib/core/permissions/presentation/bloc/permission_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/permission_status.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object> get props => [];
}

class RequestStoragePermissionEvent extends PermissionEvent {
  const RequestStoragePermissionEvent();
}

class OpenAppSettingsEvent extends PermissionEvent {
  const OpenAppSettingsEvent();
}

class ResetPermissionStateEvent extends PermissionEvent {
  const ResetPermissionStateEvent();
}


