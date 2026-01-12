import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

import 'package:mini_strava/core/auth/auth_session.dart';
import 'package:mini_strava/core/network/network_info.dart';

// AUTH
import 'package:mini_strava/features/auth/data/models/auth_tokens_model.dart';
import 'package:mini_strava/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mini_strava/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mini_strava/features/auth/data/datasources/auth_remote_fake_data_source.dart';
import 'package:mini_strava/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mini_strava/features/auth/domain/repositories/auth_repository.dart';
import 'package:mini_strava/features/auth/domain/usecases/login_usecase.dart';
import 'package:mini_strava/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mini_strava/features/auth/domain/usecases/get_cached_tokens_usecase.dart';

// PROFILE
import 'package:mini_strava/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:mini_strava/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mini_strava/features/profile/domain/repositories/profile_repository.dart';
import 'package:mini_strava/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:mini_strava/features/profile/domain/usecases/save_profile_usecase.dart';

// ACTIVITY (Hive)
import 'package:mini_strava/features/activity/data/models/activity_model.dart';
import 'package:mini_strava/features/activity/data/datasources/activity_local_data_source.dart';
import 'package:mini_strava/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:mini_strava/features/activity/domain/repositories/activity_repository.dart';
import 'package:mini_strava/features/activity/domain/usecases/save_activity_usecase.dart';

// ACTIVITY HISTORY (Hive / offline-first)
import 'package:mini_strava/features/activity_history/data/models/activity_history_hive_model.dart';
import 'package:mini_strava/features/activity_history/data/datasources/activity_history_local_data_source.dart';
import 'package:mini_strava/features/activity_history/data/datasources/activity_history_local_data_source_impl.dart';
import 'package:mini_strava/features/activity_history/data/repositories/activity_history_repository_impl.dart';
import 'package:mini_strava/features/activity_history/domain/repositories/activity_history_repository.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/get_activity_history_usecase.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/get_activity_details_usecase.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/add_manual_activity_usecase.dart';
import 'package:mini_strava/features/activity_history/data/datasources/activity_history_remote_fake_data_source.dart';

final sl = GetIt.instance;

void setupInjector(SharedPreferences prefs) {
  if (sl.isRegistered<SharedPreferences>()) return;

  // ---------- CORE ----------
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerSingleton<AuthSession>(AuthSession(prefs));

  // ---------- AUTH (fake) ----------
  sl.registerLazySingleton<Box<AuthTokensModel>>(
        () => Hive.box<AuthTokensModel>('auth_tokens'),
    instanceName: 'authTokensBox',
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(
      sl<Box<AuthTokensModel>>(instanceName: 'authTokensBox'),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteFakeDataSource());

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCachedTokensUseCase(sl<AuthRepository>()));

  // ---------- PROFILE (local) ----------
  sl.registerLazySingleton<ProfileLocalDataSource>(
        () => ProfileLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(
      sl<ProfileLocalDataSource>(),
      sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => SaveProfileUseCase(sl<ProfileRepository>()));

  // ---------- ACTIVITY (Hive) ----------
  sl.registerLazySingleton<Box<ActivityModel>>(
        () => Hive.box<ActivityModel>('activities'),
    instanceName: 'activitiesBox',
  );

  sl.registerLazySingleton<ActivityLocalDataSource>(
        () => ActivityLocalDataSourceImpl(
      sl<Box<ActivityModel>>(instanceName: 'activitiesBox'),
    ),
  );

  sl.registerLazySingleton<ActivityRepository>(
        () => ActivityRepositoryImpl(sl<ActivityLocalDataSource>()),
  );

  sl.registerLazySingleton(() => SaveActivityUseCase(sl<ActivityRepository>()));

// ---------- ACTIVITY HISTORY (Hive / offline-first) ----------
  sl.registerLazySingleton<Box<ActivityHistoryHiveModel>>(
        () => Hive.box<ActivityHistoryHiveModel>('activity_history'),
    instanceName: 'activityHistoryBox',
  );

  sl.registerLazySingleton<ActivityHistoryLocalDataSource>(
        () => ActivityHistoryLocalDataSourceImpl(
      sl<Box<ActivityHistoryHiveModel>>(instanceName: 'activityHistoryBox'),
    ),
  );

  sl.registerLazySingleton<ActivityHistoryRepositoryImpl>(
        () => ActivityHistoryRepositoryImpl(sl<ActivityHistoryLocalDataSource>()),
  );

  sl.registerLazySingleton<ActivityHistoryRepository>(
        () => sl<ActivityHistoryRepositoryImpl>(),
  );

  sl.registerLazySingleton(() => GetActivityHistoryUseCase(sl<ActivityHistoryRepository>()));
  sl.registerLazySingleton(() => GetActivityDetailsUseCase(sl<ActivityHistoryRepository>()));
  sl.registerLazySingleton(() => AddManualActivityUseCase(sl<ActivityHistoryRepositoryImpl>()));


  sl.registerLazySingleton<ActivityHistoryRemoteFakeDataSource>(
        () => ActivityHistoryRemoteFakeDataSource(),
  );

}
