import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

final GetIt getIt = GetIt.instance;

/// Registers everything the app needs, once, from `main()`.
///
/// ⚠️ SHARED FILE — add only your own registration line.
/// Blocs are registered as `factory` (a fresh one per screen);
/// repositories and data sources as `lazySingleton` (one shared instance).
Future<void> setupInjector() async {
  // Data sources
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuthDataSource>()),
  );

  // Blocs — each Sprint 1 auth task registers its own here, e.g.
  //   getIt.registerFactory(() => LoginBloc(getIt<AuthRepository>()));
}
