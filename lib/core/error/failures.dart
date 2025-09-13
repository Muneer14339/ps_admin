// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

class AuthFailure extends Failure {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

class FileFailure extends Failure {
  final String message;
  const FileFailure(this.message);
  @override
  List<Object> get props => [message];
}

class PermissionFailure extends Failure {
  final String message;
  const PermissionFailure(this.message);
  @override
  List<Object> get props => [message];
}