import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/movie_grid.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/search/presentation/bloc/search/search_bloc.dart';
import 'package:movie_app/features/search/presentation/screens/search_tab.dart';

import '../../helpers/fake_movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const results = [
    Movie(id: 1, title: 'Inception', year: 2010),
    Movie(id: 2, title: 'Interstellar', year: 2014),
  ];

  /// Past the screen's 400ms debounce, with room for the Bloc to answer.
  const pastDebounce = Duration(milliseconds: 600);

  // Covers what the simulator cannot: its keyboard is set to Arabic, so typed
  // ASCII never reaches the field.
  Future<void> pumpSearch(
    WidgetTester tester,
    FakeMovieRepository repository,
  ) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    getIt.registerLazySingleton<MovieRepository>(() => repository);
    getIt.registerFactory<SearchBloc>(
      () => SearchBloc(getIt<MovieRepository>()),
    );
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(theme: AppTheme.dark, home: const SearchTab()),
      ),
    );
    await tester.pump();
  }

  /// Types [query] and waits out the debounce.
  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextFormField), query);
    await tester.pump();
    await tester.pump(pastDebounce);
    await tester.pump();
  }

  group('SearchTab', () {
    testWidgets('starts on the prompt, not an empty grid', (tester) async {
      await pumpSearch(tester, FakeMovieRepository(movies: results));

      expect(find.text(AppStrings.searchEmpty), findsOneWidget);
      expect(find.byType(MovieGrid), findsNothing);
    });

    testWidgets('a match shows the grid', (tester) async {
      await pumpSearch(tester, FakeMovieRepository(movies: results));
      await search(tester, 'inception');

      expect(find.byType(MovieGrid), findsOneWidget);
      expect(find.text(AppStrings.searchEmpty), findsNothing);
    });

    testWidgets('no match says so instead of showing nothing', (tester) async {
      // The API answers 200 with the `movies` key absent, which the model
      // turns into an empty list — a successful search, not a failure.
      await pumpSearch(tester, FakeMovieRepository(movies: const []));
      await search(tester, 'zzzzz');

      expect(find.text(AppStrings.searchNoResults), findsOneWidget);
      expect(find.byType(MovieGrid), findsNothing);
    });

    testWidgets('whitespace alone is not a search', (tester) async {
      final repository = FakeMovieRepository(movies: results);
      await pumpSearch(tester, repository);
      await search(tester, '   ');

      // Trimming matters: an untrimmed blank query would ask the API for the
      // unfiltered catalogue and present it as search results.
      expect(find.text(AppStrings.searchEmpty), findsOneWidget);
      expect(find.byType(MovieGrid), findsNothing);
    });

    testWidgets('emptying the box returns to the prompt', (tester) async {
      await pumpSearch(tester, FakeMovieRepository(movies: results));
      await search(tester, 'inception');
      expect(find.byType(MovieGrid), findsOneWidget);

      await search(tester, '');

      // "nothing typed" and "found nothing" read differently — the query on
      // the state is what tells them apart.
      expect(find.text(AppStrings.searchEmpty), findsOneWidget);
      expect(find.text(AppStrings.searchNoResults), findsNothing);
    });

    testWidgets('typing fast sends one request, not one per letter', (
      tester,
    ) async {
      final repository = FakeMovieRepository(movies: results);
      await pumpSearch(tester, repository);

      // Each keystroke restarts the timer, so only the last one survives.
      for (final query in ['i', 'in', 'inc', 'ince']) {
        await tester.enterText(find.byType(TextFormField), query);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(pastDebounce);
      await tester.pump();

      expect(repository.queries, ['ince']);
    });

    testWidgets('ranks results by downloads, not the API default', (
      tester,
    ) async {
      // Regression guard. Unsorted, YTS led "avengers" with The Toxic Avenger
      // and "batman" with Batman: Knightfall Part 1 — the film you searched
      // for was not on screen at all, which read as search being broken.
      final repository = FakeMovieRepository(movies: results);
      await pumpSearch(tester, repository);
      await search(tester, 'avengers');

      expect(repository.sortBys, ['download_count']);
    });

    testWidgets('a failed search offers a retry', (tester) async {
      await pumpSearch(
        tester,
        FakeMovieRepository(moviesError: 'No internet connection.'),
      );
      await search(tester, 'inception');

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('No internet connection.'), findsOneWidget);
    });
  });
}
