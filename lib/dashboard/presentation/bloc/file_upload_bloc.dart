// lib/home_feature/presentation/bloc/file_upload_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/usecases/upload_firearm_usecase.dart';
import '../../domain/usecases/upload_ammunition_usecase.dart';
import 'file_upload_event.dart';
import 'file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final UploadFirearmUseCase uploadFirearmUseCase;
  final UploadAmmunitionUseCase uploadAmmunitionUseCase;

  FileUploadBloc({
    required this.uploadFirearmUseCase,
    required this.uploadAmmunitionUseCase,
  }) : super(const FileUploadInitial()) {
    on<UploadFirearmFileEvent>(_onUploadFirearmFile);
    on<UploadAmmunitionFileEvent>(_onUploadAmmunitionFile);
    on<ResetStateEvent>(_onResetState);
  }

  void _onUploadFirearmFile(
      UploadFirearmFileEvent event,
      Emitter<FileUploadState> emit,
      ) async {
    emit(const FileUploadLoading());

    final result = await uploadFirearmUseCase(
      UploadFirearmParams(filePath: event.filePath),
    );

    result.fold(
          (failure) => emit(FileUploadError(message: failure.toString())),
          (_) => emit(const FileUploadSuccess(message: 'Firearms uploaded successfully!')),
    );
  }

  void _onUploadAmmunitionFile(
      UploadAmmunitionFileEvent event,
      Emitter<FileUploadState> emit,
      ) async {
    emit(const FileUploadLoading());

    final result = await uploadAmmunitionUseCase(
      UploadAmmunitionParams(filePath: event.filePath),
    );

    result.fold(
          (failure) => emit(FileUploadError(message: failure.toString())),
          (_) => emit(const FileUploadSuccess(message: 'Ammunition uploaded successfully!')),
    );
  }

  void _onResetState(
      ResetStateEvent event,
      Emitter<FileUploadState> emit,
      ) {
    emit(const FileUploadInitial());
  }
}
