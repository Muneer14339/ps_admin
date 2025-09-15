// lib/dashboard/presentation/bloc/file_upload_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/firearm.dart';
import '../../domain/entities/ammunition.dart';

abstract class FileUploadState extends Equatable {
  const FileUploadState();

  @override
  List<Object> get props => [];
}

class FileUploadInitial extends FileUploadState {
  const FileUploadInitial();
}

class FileUploadLoading extends FileUploadState {
  const FileUploadLoading();
}

class FileValidated extends FileUploadState {
  final String message;
  final int recordCount;

  const FileValidated({
    required this.message,
    required this.recordCount,
  });

  @override
  List<Object> get props => [message, recordCount];
}

class FileUploadSuccess extends FileUploadState {
  final String message;

  const FileUploadSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class FileUploadError extends FileUploadState {
  final String message;

  const FileUploadError({required this.message});

  @override
  List<Object> get props => [message];
}

class FirearmsLoaded extends FileUploadState {
  final List<Firearm> firearms;

  const FirearmsLoaded({required this.firearms});

  @override
  List<Object> get props => [firearms];
}

class AmmunitionsLoaded extends FileUploadState {
  final List<Ammunition> ammunitions;

  const AmmunitionsLoaded({required this.ammunitions});

  @override
  List<Object> get props => [ammunitions];
}