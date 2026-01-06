import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

import '../network/network_info.dart';

// AUTH
import '../../features/auth/data/repositories/auth_repository_fake.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';

// PROFILE
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/save_profile_usecase.dart';

// ACTIVITY (Hive)
import '../../features/activity/data/models/activity_model.dart';
import '../../features/activity/data/datasources/activity_local_data_source.dart';
import '../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../features/activity/domain/repositories/activity_repository.dart';
import '../../features/activity/domain/usecases/save_activity_usecase.dart';

final sl = GetIt.instance;

void setupInjector(SharedPreferences prefs) {
  if (sl.isRegistered<SharedPreferences>()) return;

  // CORE
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // AUTH (fake)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryFake());
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

  // PROFILE (local)
  sl.registerLazySingleton<ProfileLocalDataSource>(
        () => ProfileLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(sl<ProfileLocalDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton<SaveProfileUseCase>(() => SaveProfileUseCase(sl()));

  // ACTIVITY (Hive)  ✅ tu był problem
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

  sl.registerLazySingleton<SaveActivityUseCase>(
        () => SaveActivityUseCase(sl<ActivityRepository>()),
  );
}
