import 'package:get_it/get_it.dart';

import '../network/api_client.dart';

import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/register/register_bloc.dart';
import '../../features/profile/data/datasources/avatar_photo_picker.dart';
import '../../features/profile/data/datasources/firestore_user_datasource.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/profile/domain/repositories/user_profile_repository.dart';
import '../../features/browse/presentation/bloc/browse/browse_bloc.dart';
import '../../features/history/data/datasources/firestore_history_datasource.dart';
import '../../features/history/data/repositories/firestore_history_repository.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/home/presentation/bloc/home/home_bloc.dart';
import '../../features/movie_details/presentation/bloc/movie_details/movie_details_bloc.dart';
import '../../features/movies/data/datasources/movie_local_datasource.dart';
import '../../features/movies/data/datasources/movie_remote_datasource.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/profile/presentation/bloc/profile/profile_bloc.dart';
import '../../features/profile/presentation/bloc/update_profile/update_profile_bloc.dart';
import '../../features/search/presentation/bloc/search/search_bloc.dart';
import '../../features/watchlist/data/datasources/firestore_watchlist_datasource.dart';
import '../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../features/watchlist/domain/repositories/watchlist_repository.dart';

final GetIt getIt = GetIt.instance;

/// Registers everything the app needs, once, from `main()`.
///
/// ⚠️ SHARED FILE — add only your own registration line.
/// Blocs are registered as `factory` (a fresh one per screen);
/// repositories and data sources as `lazySingleton` (one shared instance).
Future<void> setupInjector() async {
  // Network — one Dio for the whole app. Nothing above the data layer
  // imports Dio; data sources take this instead.
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Data sources
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(),
  );
  getIt.registerLazySingleton<FirestoreUserDataSource>(
    () => FirestoreUserDataSource(),
  );
  getIt.registerLazySingleton<AvatarPhotoPicker>(() => AvatarPhotoPicker());
  getIt.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<MovieLocalDataSource>(
    () => const MovieLocalDataSource(),
  );
  getIt.registerLazySingleton<FirestoreWatchlistDataSource>(
    () => FirestoreWatchlistDataSource(),
  );
  getIt.registerLazySingleton<FirestoreHistoryDataSource>(
    () => FirestoreHistoryDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuthDataSource>()),
  );
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(getIt<FirestoreUserDataSource>()),
  );
  // A singleton on purpose: its in-memory cache is the reason a tab you
  // already visited paints instantly instead of showing the spinner again.
  // Registering it per-screen would throw that away on every navigation.
  getIt.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      getIt<MovieRemoteDataSource>(),
      getIt<MovieLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(
      getIt<FirestoreWatchlistDataSource>(),
      getIt<AuthRepository>(),
    ),
  );
  // Backed by one capped Firestore document, so history survives a restart
  // and expires on its own. `InMemoryHistoryRepository` is kept in the
  // codebase as the test double, not registered here.
  getIt.registerLazySingleton<HistoryRepository>(
    () => FirestoreHistoryRepository(
      getIt<FirestoreHistoryDataSource>(),
      getIt<AuthRepository>(),
    ),
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
  getIt.registerFactory<MovieDetailsBloc>(
    () => MovieDetailsBloc(
      getIt<MovieRepository>(),
      getIt<WatchlistRepository>(),
      getIt<HistoryRepository>(),
    ),
  );
  getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<MovieRepository>()));
  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(getIt<MovieRepository>()),
  );
  getIt.registerFactory<BrowseBloc>(
    () => BrowseBloc(getIt<MovieRepository>()),
  );
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getIt<AuthRepository>(),
      getIt<UserProfileRepository>(),
      getIt<WatchlistRepository>(),
      getIt<HistoryRepository>(),
    ),
  );
  getIt.registerFactory<UpdateProfileBloc>(
    () => UpdateProfileBloc(
      getIt<AuthRepository>(),
      getIt<UserProfileRepository>(),
      getIt<AvatarPhotoPicker>(),
    ),
  );
}
