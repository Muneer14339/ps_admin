// lib/home_feature/presentation/bloc/file_upload_state.dart
import 'package:equatable/equatable.dart';

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