import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_genres.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/genre_chip.dart';
import 'package:movie_app/core/widgets/movie_grid.dart';
import 'package:movie_app/features/browse/presentation/bloc/browse/browse_bloc.dart';
import 'package:movie_app/features/browse/presentation/screens/browse_tab.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

import '../../helpers/fake_movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const catalogue = [
    Movie(id: 1, title: 'Salt Flats', year: 2017),
    Movie(id: 2, title: 'Under the Wire', year: 2024),
  ];

  Future<void> pumpBrowse(
    WidgetTester tester,
    FakeMovieRepository repository,
  ) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    getIt.registerLazySingleton<MovieRepository>(() => repository);
    getIt.registerFactory<BrowseBloc>(
      () => BrowseBloc(getIt<MovieRepository>()),
    );
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(theme: AppTheme.dark, home: const BrowseTab()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  group('BrowseTab', () {
    testWidgets('opens on the default genre and asks the API for it', (
      tester,
    ) async {
      final repository = FakeMovieRepository(movies: catalogue);
      await pumpBrowse(tester, repository);

      expect(repository.genres, [AppGenres.defaultGenre]);
      expect(find.byType(MovieGrid), findsOneWidget);
    });

    testWidgets('tapping a chip fetches that genre', (tester) async {
      final repository = FakeMovieRepository(movies: catalogue);
      await pumpBrowse(tester, repository);

      // 'Adventure' on purpose: the chip row is a lazy ListView and the chips
      // are wide, so only the first three are ever built at this width.
      // Reaching for a chip further along finds nothing and the tap silently
      // does nothing — which is exactly how this test failed first time.
      await tester.tap(find.widgetWithText(GenreChip, 'Adventure'));
      await tester.pump();
      await tester.pump();

      expect(repository.genres, [AppGenres.defaultGenre, 'Adventure']);
    });

    testWidgets('the chip highlights immediately, before the load finishes', (
      tester,
    ) async {
      // Waiting for the response to move the selection makes every tap feel
      // broken.
      final repository = FakeMovieRepository(
        movies: catalogue,
        delay: const Duration(milliseconds: 200),
      );
      await pumpBrowse(tester, repository);
      await tester.pump(const Duration(milliseconds: 300));

      // 'Adventure', not a chip further along the row. The chips are wide
      // enough that only about two and a half fit a 430pt screen, so the
      // third one's *centre* is off-screen and `tap` silently misses it.
      await tester.tap(find.widgetWithText(GenreChip, 'Adventure'));
      // Two frames, because a Bloc handler runs off the event stream rather
      // than inline with `add`. Neither of these advances the clock, so the
      // 200ms request is still in flight — which is the point.
      await tester.pump();
      await tester.pump();

      final chip = tester.widget<GenreChip>(
        find.widgetWithText(GenreChip, 'Adventure'),
      );
      expect(chip.isSelected, isTrue);

      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('a failed genre offers a retry', (tester) async {
      await pumpBrowse(
        tester,
        FakeMovieRepository(moviesError: 'No internet connection.'),
      );

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('No internet connection.'), findsOneWidget);
    });
  });
}
