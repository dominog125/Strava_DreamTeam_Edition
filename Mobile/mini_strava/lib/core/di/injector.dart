import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository_fake.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/profile/data/repositories/profile_repository_fake.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/save_profile_usecase.dart';


final sl = GetIt.instance;

/// Clean Architecture DI
/// NOTE: Na razie bez API -> używamy Fake repo.
/// TODO(API): podmień AuthRepositoryFake na AuthRepositoryImpl i dodaj ApiClient/RemoteDataSource.
void setupInjector() {
  // ✅ zabezpieczenie przed rejestracją 2x (hot restart itp.)
  if (sl.isRegistered<AuthRepository>()) return;
  // --- PROFILE (fake) ---
  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryFake());
    sl.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(sl<ProfileRepository>()));
    sl.registerLazySingleton<SaveProfileUseCase>(() => SaveProfileUseCase(sl<ProfileRepository>()));
  }


  // --- DATA (fake) ---
  // TODO(API): tutaj w przyszłości będzie AuthRepositoryImpl(...)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryFake());

  // --- DOMAIN ---
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
}
