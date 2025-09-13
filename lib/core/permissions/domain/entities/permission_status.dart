// lib/core/permissions/domain/entities/permission_status.dart
import 'package:equatable/equatable.dart';

enum AppPermission { storage }

enum PermissionResult { granted, denied, permanentlyDenied, restricted }

class PermissionStatus extends Equatable {
  final AppPermission permission;
  final PermissionResult result;

  const PermissionStatus({
    required this.permission,
    required this.result,
  });

  @override
  List<Object> get props => [permission, result];

  bool get isGranted => result == PermissionResult.granted;
  bool get isDenied => result == PermissionResult.denied;
  bool get isPermanentlyDenied => result == PermissionResult.permanentlyDenied;
}