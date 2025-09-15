// Updated injection_container.dart
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

// Admin Dashboard imports
import 'admin_dashboard/data/datasources/file_upload_remote_datasource.dart';
import 'admin_dashboard/data/repositories/file_upload_repository_impl.dart';
import 'admin_dashboard/domain/repositories/file_upload_repository.dart';
import 'admin_dashboard/domain/usecases/upload_ammunition_usecase.dart';
import 'admin_dashboard/domain/usecases/upload_firearm_usecase.dart';
import 'admin_dashboard/domain/usecases/get_firearms_usecase.dart';
import 'admin_dashboard/domain/usecases/get_ammunitions_usecase.dart';
import 'admin_dashboard/presentation/bloc/file_upload_bloc.dart';

// User Dashboard imports
import 'user_dashboard/data/datasources/armory_remote_datasource.dart';
import 'user_dashboard/data/repositories/armory_repository_impl.dart';
import 'user_dashboard/domain/repositories/armory_repository.dart';
import 'user_dashboard/domain/usecases/get_firearms_usecase.dart' as user_firearms;
import 'user_dashboard/domain/usecases/add_firearm_usecase.dart';
import 'user_dashboard/domain/usecases/get_ammunition_usecase.dart' as user_ammo;
import 'user_dashboard/domain/usecases/add_ammunition_usecase.dart' as user_add_ammo;
import 'user_dashboard/domain/usecases/get_gear_usecase.dart';
import 'user_dashboard/domain/usecases/add_gear_usecase.dart';
import 'user_dashboard/domain/usecases/get_tools_usecase.dart';
import 'user_dashboard/domain/usecases/add_tool_usecase.dart';
import 'user_dashboard/domain/usecases/get_loadouts_usecase.dart';
import 'user_dashboard/domain/usecases/add_loadout_usecase.dart';
import 'user_dashboard/domain/usecases/get_dropdown_options_usecase.dart';
import 'user_dashboard/presentation/bloc/armory_bloc.dart';

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

  // BLoC - Admin Dashboard
  sl.registerFactory(
        () => FileUploadBloc(
      uploadFirearmUseCase: sl(),
      uploadAmmunitionUseCase: sl(),
      getFirearmsUseCase: sl(),
      getAmmunitionsUseCase: sl(),
    ),
  );

  // BLoC - User Dashboard (Armory)
  sl.registerFactory(
        () => ArmoryBloc(
      getFirearmsUseCase: sl<user_firearms.GetFirearmsUseCase>(),
      addFirearmUseCase: sl(),
      getAmmunitionUseCase: sl<user_ammo.GetAmmunitionUseCase>(),
      addAmmunitionUseCase: sl<user_add_ammo.AddAmmunitionUseCase>(),
      getGearUseCase: sl(),
      addGearUseCase: sl(),
      getToolsUseCase: sl(),
      addToolUseCase: sl(),
      getLoadoutsUseCase: sl(),
      addLoadoutUseCase: sl(),
      getDropdownOptionsUseCase: sl(),
    ),
  );

  // Use cases - Authentication
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Use cases - Admin Dashboard
  sl.registerLazySingleton(() => UploadFirearmUseCase(sl()));
  sl.registerLazySingleton(() => UploadAmmunitionUseCase(sl()));
  sl.registerLazySingleton(() => GetFirearmsUseCase(sl()));
  sl.registerLazySingleton(() => GetAmmunitionsUseCase(sl()));

  // Use cases - User Dashboard
  sl.registerLazySingleton(() => user_firearms.GetFirearmsUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => AddFirearmUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => user_ammo.GetAmmunitionUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => user_add_ammo.AddAmmunitionUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => GetGearUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => AddGearUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => GetToolsUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => AddToolUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => GetLoadoutsUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => AddLoadoutUseCase(sl<ArmoryRepository>()));
  sl.registerLazySingleton(() => GetDropdownOptionsUseCase(sl<ArmoryRepository>()));

  // Repository - Authentication
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Repository - Admin Dashboard
  sl.registerLazySingleton<FileUploadRepository>(
        () => FileUploadRepositoryImpl(remoteDataSource: sl()),
  );

  // Repository - User Dashboard
  sl.registerLazySingleton<ArmoryRepository>(
        () => ArmoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources - Authentication
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  // Data sources - Admin Dashboard
  sl.registerLazySingleton<FileUploadRemoteDataSource>(
        () => FileUploadRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // Data sources - User Dashboard
  sl.registerLazySingleton<ArmoryRemoteDataSource>(
        () => ArmoryRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}