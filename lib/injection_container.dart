// lib/injection_container.dart (updated)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// Authentication imports
import 'authentication/data/datasources/auth_remote_datasource.dart';
import 'authentication/data/repositories/auth_repository_impl.dart';
import 'authentication/domain/repositories/auth_repository.dart';
import 'authentication/domain/usecases/get_current_user_usecase.dart';
import 'authentication/domain/usecases/login_usecase.dart';
import 'authentication/domain/usecases/logout_usecase.dart';
import 'authentication/domain/usecases/signup_usecase.dart';
import 'authentication/presentation/bloc/login_bloc/auth_bloc.dart';
import 'authentication/presentation/bloc/signup_bloc/signup_bloc.dart';

// Dashboard imports
import 'admin_dashboard/data/datasources/file_upload_remote_datasource.dart';
import 'admin_dashboard/data/repositories/file_upload_repository_impl.dart';
import 'admin_dashboard/domain/repositories/file_upload_repository.dart';
import 'admin_dashboard/domain/usecases/upload_ammunition_usecase.dart';
import 'admin_dashboard/domain/usecases/upload_firearm_usecase.dart';
import 'admin_dashboard/domain/usecases/get_firearms_usecase.dart';
import 'admin_dashboard/domain/usecases/get_ammunitions_usecase.dart';
import 'admin_dashboard/presentation/bloc/file_upload_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC - Authentication
  sl.registerFactory(
        () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerFactory(
        () => SignupBloc(
      signupUseCase: sl(),
    ),
  );

  // BLoC - Dashboard
  sl.registerFactory(
        () => FileUploadBloc(
      uploadFirearmUseCase: sl(),
      uploadAmmunitionUseCase: sl(),
      getFirearmsUseCase: sl(),
      getAmmunitionsUseCase: sl(),
    ),
  );

  // Use cases - Authentication
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Use cases - Dashboard
  sl.registerLazySingleton(() => UploadFirearmUseCase(sl()));
  sl.registerLazySingleton(() => UploadAmmunitionUseCase(sl()));
  sl.registerLazySingleton(() => GetFirearmsUseCase(sl()));
  sl.registerLazySingleton(() => GetAmmunitionsUseCase(sl()));

  // Repository - Authentication
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Repository - Dashboard
  sl.registerLazySingleton<FileUploadRepository>(
        () => FileUploadRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources - Authentication
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  // Data sources - Dashboard
  sl.registerLazySingleton<FileUploadRemoteDataSource>(
        () => FileUploadRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}