import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/register/register_bloc.dart';
import '../../features/profile/presentation/bloc/update_profile/update_profile_bloc.dart';

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

  // Blocs — a fresh instance per screen, so a reopened screen starts from
  // its initial state instead of inheriting the last one.
  getIt.registerFactory<RegisterBloc>(
    () => RegisterBloc(getIt<AuthRepository>()),
  );
  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt<AuthRepository>()));
  getIt.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(getIt<AuthRepository>()),
  );
  getIt.registerFactory<UpdateProfileBloc>(
    () => UpdateProfileBloc(getIt<AuthRepository>()),
  );
}
