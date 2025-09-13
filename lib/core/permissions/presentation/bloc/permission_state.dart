// lib/core/permissions/presentation/bloc/permission_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/permission_status.dart';

abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object> get props => [];
}

class PermissionInitial extends PermissionState {
  const PermissionInitial();
}

class PermissionLoading extends PermissionState {
  const PermissionLoading();
}

class PermissionGranted extends PermissionState {
  const PermissionGranted();
}

class PermissionDenied extends PermissionState {
  const PermissionDenied();
}

class PermissionPermanentlyDenied extends PermissionState {
  const PermissionPermanentlyDenied();
}

class PermissionError extends PermissionState {
  final String message;

  const PermissionError({required this.message});

  @override
  List<Object> get props => [message];
}
