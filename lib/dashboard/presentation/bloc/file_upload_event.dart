// lib/home_feature/presentation/bloc/file_upload_event.dart
import 'package:equatable/equatable.dart';

abstract class FileUploadEvent extends Equatable {
  const FileUploadEvent();

  @override
  List<Object> get props => [];
}

class UploadFirearmFileEvent extends FileUploadEvent {
  final String filePath;

  const UploadFirearmFileEvent({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class UploadAmmunitionFileEvent extends FileUploadEvent {
  final String filePath;

  const UploadAmmunitionFileEvent({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class ResetStateEvent extends FileUploadEvent {
  const ResetStateEvent();
}