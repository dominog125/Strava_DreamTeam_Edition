import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';


import '../../features/auth/data/repositories/auth_repository_fake.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';


import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/save_profile_usecase.dart';

import '../../features/activity/data/repositories/activity_repository_fake.dart';
import '../../features/activity/domain/repositories/activity_repository.dart';
import '../../features/activity/domain/usecases/save_activity_usecase.dart';


final sl = GetIt.instance;

void setupInjector(SharedPreferences prefs) {

  if (sl.isRegistered<SharedPreferences>()) return;


  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));


  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryFake());
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));


  sl.registerLazySingleton<ProfileLocalDataSource>(
        () => ProfileLocalDataSourceImpl(sl<SharedPreferences>()),
  );


  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(sl<ProfileLocalDataSource>(), sl<NetworkInfo>()),
  );

  sl.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton<SaveProfileUseCase>(() => SaveProfileUseCase(sl()));

  sl.registerLazySingleton<ActivityRepository>(() => ActivityRepositoryFake());
  sl.registerLazySingleton<SaveActivityUseCase>(() => SaveActivityUseCase(sl()));

}
