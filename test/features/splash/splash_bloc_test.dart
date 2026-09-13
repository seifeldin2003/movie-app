import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/network/api_endpoints.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/core/movies/domain/entities/movie.dart';
import 'package:movie_app/features/splash/presentation/bloc/splash/splash_bloc.dart';
import 'package:movie_app/features/splash/presentation/bloc/splash/splash_event.dart';
import 'package:movie_app/features/splash/presentation/bloc/splash/splash_state.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_movie_repository.dart';

void main() {
  // ⚠️ Without this a plain `test` has no Flutter binding, so HTTP is not
  // mocked and a mistake here would hit the real API.
  TestWidgetsFlutterBinding.ensureInitialized();

  const movies = [Movie(id: 1, title: 'Iron Man 3', imdbCode: 'tt1300854')];

  test('becomes ready once the catalogue lands', () async {
    final bloc = SplashBloc(
      FakeMovieRepository(movies: movies),
      FakeAuthRepository(),
    );
    addTearDown(bloc.close);

    bloc.add(const SplashStarted());
    final state = await bloc.stream.firstWhere((s) => s.isReady);

    expect(state.isReady, isTrue);
    expect(state.isSignedIn, isFalse);
  });

  test('reports a restored session so the app skips onboarding', () async {
    final bloc = SplashBloc(
      FakeMovieRepository(movies: movies),
      FakeAuthRepository(
        signedIn: const AppUser(uid: 'abc', name: 'Seif'),
      ),
    );
    addTearDown(bloc.close);

    bloc.add(const SplashStarted());
    final state = await bloc.stream.firstWhere((s) => s.isReady);

    expect(state.isSignedIn, isTrue);
  });

  test('asks for exactly what the Home carousel asks for', () async {
    // ⚠️ The whole point of the prewarm. `MovieRepositoryImpl` caches on a key
    // built from these arguments, so if they ever stop matching
    // `HomeBloc._loadFeatured` the request still succeeds — it just stops
    // being useful, silently, and the spinner comes back.
    final repository = FakeMovieRepository(movies: movies);
    final bloc = SplashBloc(repository, FakeAuthRepository());
    addTearDown(bloc.close);

    bloc.add(const SplashStarted());
    await bloc.stream.firstWhere((s) => s.isReady);

    expect(repository.sortBys, [ApiEndpoints.sortByDownloads]);
    expect(repository.minimumRatings, [ApiEndpoints.homeMinimumRating]);
  });

  test('a failed request still lets the app in', () async {
    // Offline is not a reason to strand someone on the splash screen. Home
    // runs the same request again and owns reporting the failure.
    final bloc = SplashBloc(
      FakeMovieRepository(moviesError: 'No internet connection.'),
      FakeAuthRepository(),
    );
    addTearDown(bloc.close);

    bloc.add(const SplashStarted());

    await expectLater(
      bloc.stream.firstWhere((s) => s.isReady),
      completion(isA<SplashState>()),
    );
  });

  test(
    'a request that never answers still lets the app in',
    () async {
      // The case the cap exists for: a captive portal that accepts the socket
      // and never replies. Without the timeout the splash lasts as long as the
      // worst network in the room.
      final bloc = SplashBloc(
        FakeMovieRepository(movies: movies, delay: const Duration(minutes: 5)),
        FakeAuthRepository(),
      );
      addTearDown(bloc.close);

      bloc.add(const SplashStarted());

      await expectLater(
        bloc.stream.firstWhere((s) => s.isReady),
        completion(isA<SplashState>()),
      );
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
