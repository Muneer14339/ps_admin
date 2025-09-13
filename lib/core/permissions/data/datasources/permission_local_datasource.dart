// lib/core/permissions/data/datasources/permission_local_datasource.dart
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../domain/entities/permission_status.dart';

abstract class PermissionLocalDataSource {
  Future<PermissionStatus> checkPermission(AppPermission permission);
  Future<PermissionStatus> requestPermission(AppPermission permission);
  Future<void> openAppSettings();
}

class PermissionLocalDataSourceImpl implements PermissionLocalDataSource {
  @override
  Future<PermissionStatus> checkPermission(AppPermission permission) async {
    final ph.Permission permissionHandler = _getPermissionHandler(permission);
    final ph.PermissionStatus status = await permissionHandler.status;

    return PermissionStatus(
      permission: permission,
      result: _mapPermissionResult(status),
    );
  }

  @override
  Future<PermissionStatus> requestPermission(AppPermission permission) async {
    final ph.Permission permissionHandler = _getPermissionHandler(permission);
    final ph.PermissionStatus status = await permissionHandler.request();

    return PermissionStatus(
      permission: permission,
      result: _mapPermissionResult(status),
    );
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  ph.Permission _getPermissionHandler(AppPermission permission) {
    switch (permission) {
      case AppPermission.storage:
        return ph.Permission.storage;
    }
  }

  PermissionResult _mapPermissionResult(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
      case ph.PermissionStatus.limited:
        return PermissionResult.granted;
      case ph.PermissionStatus.denied:
        return PermissionResult.denied;
      case ph.PermissionStatus.permanentlyDenied:
        return PermissionResult.permanentlyDenied;
      case ph.PermissionStatus.restricted:
        return PermissionResult.restricted;
      default:
        return PermissionResult.denied;
    }
  }
}