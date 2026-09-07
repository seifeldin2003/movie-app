import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/routes/app_route_names.dart';
import 'package:movie_app/core/routes/app_router.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/loading_view.dart';
import 'package:movie_app/features/movie_details/presentation/bloc/movie_details/movie_details_bloc.dart';
import 'package:movie_app/features/movie_details/presentation/screens/movie_details_screen.dart';
import 'package:movie_app/features/movie_details/presentation/widgets/cast_row.dart';
import 'package:movie_app/features/movie_details/presentation/widgets/genre_tag.dart';
import 'package:movie_app/features/movies/domain/entities/cast_member.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/history/domain/repositories/history_repository.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';

import '../../helpers/fake_history_repository.dart';
import '../../helpers/fake_movie_repository.dart';
import '../../helpers/fake_watchlist_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const movie = Movie(
    id: 1,
    title: 'The Long Road',
    imdbCode: 'tt0000001',
    year: 2019,
    rating: 8.2,
    genres: ['Action', 'Drama'],
  );

  const suggestion = Movie(id: 2, title: 'Northern Lights', year: 2021);

  /// A fully populated record — cast, stills and a summary.
  const loaded = MovieDetails(
    movie: movie,
    descriptionFull: 'A quiet story that turns loud.',
    runtimeMinutes: 118,
    mpaRating: 'PG-13',
    likeCount: 79,
    cast: [
      CastMember(name: 'Hayley Atwell', characterName: 'Captain Carter'),
      CastMember(name: 'Elizabeth Olsen', characterName: 'Wanda Maximoff'),
    ],
    screenshots: [
      'https://example.test/shot1.jpg',
      'https://example.test/shot2.jpg',
    ],
  );

  /// The shape YTS returns without `with_cast` / `with_images`: a record with
  /// most of it missing.
  const bare = MovieDetails(movie: Movie(id: 99, title: 'Bare Record'));

  const fourGenres = MovieDetails(
    movie: Movie(
      id: 98,
      title: 'Four Genres',
      genres: ['Action', 'Drama', 'Sci-Fi', 'Horror'],
    ),
  );

  /// Registers the three repositories this screen needs and the Bloc that
  /// reads them, the way `setupInjector` does in the app.
  void register(
    FakeMovieRepository repository, {
    FakeWatchlistRepository? watchlist,
    FakeHistoryRepository? history,
  }) {
    getIt.registerLazySingleton<MovieRepository>(() => repository);
    getIt.registerLazySingleton<WatchlistRepository>(
      () => watchlist ?? FakeWatchlistRepository(),
    );
    getIt.registerLazySingleton<HistoryRepository>(
      () => history ?? FakeHistoryRepository(),
    );
    getIt.registerFactory<MovieDetailsBloc>(
      () => MovieDetailsBloc(
        getIt<MovieRepository>(),
        getIt<WatchlistRepository>(),
        getIt<HistoryRepository>(),
      ),
    );
    addTearDown(getIt.reset);
  }

  Future<void> pumpDetails(
    WidgetTester tester, {
    required Movie subject,
    required FakeMovieRepository repository,
    FakeWatchlistRepository? watchlist,
    FakeHistoryRepository? history,
  }) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    register(repository, watchlist: watchlist, history: history);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(
          theme: AppTheme.dark,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: MovieDetailsScreen(movie: subject),
        ),
      ),
    );
    // Two frames: one to mount and fire the event, one to paint the state the
    // Bloc emitted. Not `pumpAndSettle` — a CircularProgressIndicator never
    // settles, so it would time out on any screen still showing one.
    await tester.pump();
    await tester.pump();
  }

  /// Drags to the bottom of the page.
  ///
  /// The page is a `CustomScrollView`, so anything below the fold is not built
  /// yet and has to be scrolled into range first. Dragging a fixed amount
  /// rather than using `scrollUntilVisible`, which needs its target to resolve
  /// to exactly one widget — awkward here, where the interesting assertions
  /// are about there being several (four genre tags, two cast rows).
  ///
  /// `.first` picks the page's own scrollable: the Similar grid is a second
  /// one, and the drag would otherwise be ambiguous.
  Future<void> scrollToBottom(WidgetTester tester) async {
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 8; i++) {
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pump();
    }
  }

  group('MovieDetailsScreen', () {
    testWidgets('opens on the title, year and Watch button', (tester) async {
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
      );

      // Two copies on purpose: the hero caption and the app bar title cross-
      // fade against each other as the page scrolls, so both are always in the
      // tree and only their opacity differs. Expanded, the caption is the
      // visible one.
      expect(find.text(movie.title), findsNWidgets(2));
      expect(find.text('2019'), findsOneWidget);
      // The hero is sized so this is reachable without scrolling.
      expect(find.text(AppStrings.watch), findsOneWidget);
    });

    testWidgets('asks the repository for the movie that was tapped', (
      tester,
    ) async {
      final repository = FakeMovieRepository(details: loaded);
      await pumpDetails(tester, subject: movie, repository: repository);

      expect(repository.detailsRequests, [movie.id]);
      expect(repository.similarRequests, [movie.id]);
    });

    testWidgets('shows the artwork while the record is still loading', (
      tester,
    ) async {
      // The whole reason the hero is not behind the spinner: the poster and
      // title arrive with the tap, so making the user wait for them would be
      // slower for nothing.
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(
          details: loaded,
          delay: const Duration(milliseconds: 200),
        ),
      );

      expect(find.byType(LoadingView), findsWidgets);
      expect(find.text(movie.title), findsNWidgets(2));
      // Nothing below the fold has been built yet.
      expect(find.text(AppStrings.watch), findsNothing);

      // Let the delayed call land so the timer does not outlive the test.
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('the first badge is the heart and the like count', (
      tester,
    ) async {
      // Regression guard: this slot used to show a shield and the age rating.
      // Figma node 53:77 is a heart, and `like_count` rides along on the same
      // details response.
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('79'), findsOneWidget);

      // The age rating has no slot in the design, so it must not appear even
      // though the record carries one.
      expect(find.text('PG-13'), findsNothing);
      expect(find.byIcon(Icons.shield_outlined), findsNothing);
    });

    testWidgets('a record with no likes drops that badge rather than showing 0', (
      tester,
    ) async {
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(
          details: const MovieDetails(movie: movie, runtimeMinutes: 118),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('shows Screen Shots as the first section', (tester) async {
      // Regression guard: an earlier version hid this section whenever a
      // record had no stills, which quietly removed it from the whole screen.
      //
      // Only presence is asserted, not the position of later sections. The
      // page is a lazily-built sliver list, so two headings this far apart are
      // never in the tree at the same time and comparing their coordinates is
      // not meaningful — the ordering lives in the build method instead.
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
      );

      expect(find.text(AppStrings.screenShots), findsOneWidget);
    });

    testWidgets('genre tags are fixed width, three to a row', (tester) async {
      await pumpDetails(
        tester,
        subject: fourGenres.movie,
        repository: FakeMovieRepository(details: fourGenres),
      );
      await scrollToBottom(tester);

      final tags = find.byType(GenreTag);
      expect(tags, findsNWidgets(4));

      // Sized rather than hugging their text, so the columns line up.
      expect(tester.getSize(tags.first).width, closeTo(GenreTag.width, 1));

      // The fourth wraps onto a second row.
      final firstRow = tester.getTopLeft(tags.first).dy;
      expect(tester.getTopLeft(tags.at(2)).dy, firstRow);
      expect(tester.getTopLeft(tags.at(3)).dy, greaterThan(firstRow));
    });

    testWidgets('drops the Genres section when there are none', (tester) async {
      // A heading with nothing under it reads as a bug.
      await pumpDetails(
        tester,
        subject: bare.movie,
        repository: FakeMovieRepository(details: bare),
      );
      await scrollToBottom(tester);

      expect(find.text(AppStrings.genres), findsNothing);
      expect(find.byType(GenreTag), findsNothing);
    });

    testWidgets('still renders cast rows without portraits', (tester) async {
      // YTS omits cast images far more often than not, so the row has to
      // stand on its own.
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
      );
      await scrollToBottom(tester);

      expect(find.byType(CastRow), findsWidgets);
    });

    testWidgets('the watchlist control saves the movie', (tester) async {
      final watchlist = FakeWatchlistRepository();
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
        watchlist: watchlist,
      );

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
      expect(await watchlist.load(), hasLength(1));
    });

    testWidgets('an already-saved movie opens with the bookmark filled', (
      tester,
    ) async {
      // Read from the store rather than defaulting to unsaved — otherwise
      // reopening a saved movie offers to save it again.
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
        watchlist: FakeWatchlistRepository(saved: const [movie]),
      );

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('a failed save puts the bookmark back', (tester) async {
      // Leaving it filled would tell the user the movie is saved when it is
      // not, and they would only find out when Profile came back empty.
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
        watchlist: FakeWatchlistRepository(error: 'No internet connection.'),
      );

      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsNothing);

      // And it says why. Rolling back *silently* is what made a Firestore
      // permission-denied look like the bookmark simply refusing to stay
      // pressed, with nothing for the user to go on.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No internet connection.'), findsOneWidget);
    });

    testWidgets('a movie still loads when history cannot be written', (
      tester,
    ) async {
      // The regression this pins. History used to be awaited on the line
      // *before* the loads:
      //
      //     await _history.record(movie);   // could not fail in memory
      //     await Future.wait([...]);       // never ran if it threw
      //
      // Safe while history was in memory. Against Firestore it is not —
      // offline or permission-denied throws — and the whole screen would
      // have failed to load because a bookkeeping write did.
      final history = FakeHistoryRepository()
        ..recordError = 'You do not have permission to do that.';

      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
        history: history,
      );

      expect(find.text(AppStrings.watch), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
      // And it stays quiet about it: recording a view is not something the
      // user asked for, so a snack bar over a movie that loaded fine is noise.
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('opening a movie records it in history', (tester) async {
      // Opening the screen is what counts as watching — the Watch button does
      // not play anything yet.
      final history = FakeHistoryRepository();
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
        history: history,
      );

      expect(history.viewed.map((m) => m.id), [movie.id]);
    });

    testWidgets('the back control survives scrolling', (tester) async {
      // The whole reason for the pinned app bar: in the design these float on
      // the artwork and disappear with it.
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(details: loaded),
      );
      await scrollToBottom(tester);

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });
  });

  group('MovieDetailsScreen failure paths', () {
    testWidgets('a failed record shows the message and retries', (
      tester,
    ) async {
      final repository = FakeMovieRepository(
        detailsError: 'No internet connection.',
      );
      await pumpDetails(tester, subject: movie, repository: repository);

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('No internet connection.'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      // Asked again rather than sitting on the error.
      expect(repository.detailsRequests, [movie.id, movie.id]);
    });

    testWidgets('failed suggestions do not take the page down', (tester) async {
      // Two independent statuses earn their keep here: the movie loaded, so
      // the page stands. Only the Similar section drops out.
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(
          details: loaded,
          similarError: 'No internet connection.',
        ),
      );

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text(AppStrings.watch), findsOneWidget);
      expect(find.text(AppStrings.similar), findsNothing);
    });

    testWidgets('suggestions render when they arrive', (tester) async {
      await pumpDetails(
        tester,
        subject: movie,
        repository: FakeMovieRepository(
          details: loaded,
          similar: const [suggestion],
        ),
      );
      await scrollToBottom(tester);

      expect(find.text(AppStrings.similar), findsWidgets);
    });
  });

  group('AppRouter', () {
    test('movieDetails without a Movie argument falls back, not crashes', () {
      // A caller passing the wrong type should land on the unknown-route
      // screen rather than throwing on a cast.
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(
          name: AppRouteNames.movieDetails,
          arguments: 'not a movie',
        ),
      );

      expect(route, isA<MaterialPageRoute<dynamic>>());
    });
  });
}
