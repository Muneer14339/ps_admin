// lib/dashboard/presentation/bloc/file_upload_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../domain/usecases/upload_firearm_usecase.dart';
import '../../domain/usecases/upload_ammunition_usecase.dart';
import '../../domain/usecases/get_firearms_usecase.dart';
import '../../domain/usecases/get_ammunitions_usecase.dart';
import 'file_upload_event.dart';
import 'file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final UploadFirearmUseCase uploadFirearmUseCase;
  final UploadAmmunitionUseCase uploadAmmunitionUseCase;
  final GetFirearmsUseCase getFirearmsUseCase;
  final GetAmmunitionsUseCase getAmmunitionsUseCase;

  FileUploadBloc({
    required this.uploadFirearmUseCase,
    required this.uploadAmmunitionUseCase,
    required this.getFirearmsUseCase,
    required this.getAmmunitionsUseCase,
  }) : super(const FileUploadInitial()) {
    on<UploadFirearmFileEvent>(_onUploadFirearmFile);
    on<UploadAmmunitionFileEvent>(_onUploadAmmunitionFile);
    on<GetFirearmsEvent>(_onGetFirearms);
    on<GetAmmunitionsEvent>(_onGetAmmunitions);
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

  void _onGetFirearms(
      GetFirearmsEvent event,
      Emitter<FileUploadState> emit,
      ) async {
    emit(const FileUploadLoading());

    final result = await getFirearmsUseCase(const NoParams());

    result.fold(
          (failure) => emit(FileUploadError(message: failure.toString())),
          (firearms) => emit(FirearmsLoaded(firearms: firearms)),
    );
  }

  void _onGetAmmunitions(
      GetAmmunitionsEvent event,
      Emitter<FileUploadState> emit,
      ) async {
    emit(const FileUploadLoading());

    final result = await getAmmunitionsUseCase(const NoParams());

    result.fold(
          (failure) => emit(FileUploadError(message: failure.toString())),
          (ammunitions) => emit(AmmunitionsLoaded(ammunitions: ammunitions)),
    );
  }

  void _onResetState(
      ResetStateEvent event,
      Emitter<FileUploadState> emit,
      ) {
    emit(const FileUploadInitial());
  }
}