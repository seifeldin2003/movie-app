import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_genres.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/loading_view.dart';
import 'package:movie_app/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:movie_app/features/home/presentation/screens/home_tab.dart';
import 'package:movie_app/features/home/presentation/widgets/genre_section.dart';
import 'package:movie_app/features/home/presentation/widgets/movie_carousel.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

import '../../helpers/fake_movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const catalogue = [
    Movie(id: 1, title: 'Avengers: Infinity War', year: 2018, rating: 8.4),
    Movie(id: 2, title: 'Black Panther', year: 2018, rating: 7.3),
    Movie(id: 3, title: 'Thor: Ragnarok', year: 2017, rating: 7.9),
  ];

  Future<void> pumpHome(
    WidgetTester tester,
    FakeMovieRepository repository,
  ) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    getIt.registerLazySingleton<MovieRepository>(() => repository);
    getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<MovieRepository>()));
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(theme: AppTheme.dark, home: const HomeTab()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  group('HomeTab', () {
    testWidgets('shows the carousel and a row per genre once loaded', (
      tester,
    ) async {
      await pumpHome(tester, FakeMovieRepository(movies: catalogue));

      expect(find.byType(MovieCarousel), findsOneWidget);
      expect(find.byType(GenreSection), findsNWidgets(AppGenres.homeRows.length));
    });

    testWidgets('asks for a downloads-sorted feed and one call per row', (
      tester,
    ) async {
      // Sorting by rating alone returns obscure records with a couple of
      // votes; the carousel needs films people recognise, with backdrops.
      final repository = FakeMovieRepository(movies: catalogue);
      await pumpHome(tester, repository);

      expect(repository.genres, AppGenres.homeRows);
      expect(repository.sortBys, ['download_count']);
      expect(repository.minimumRatings, [7]);
    });

    testWidgets('spins before anything has arrived', (tester) async {
      await pumpHome(
        tester,
        FakeMovieRepository(
          movies: catalogue,
          delay: const Duration(milliseconds: 200),
        ),
      );

      // The carousel drives the backdrop, so there is genuinely nothing to
      // draw until it has content.
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(MovieCarousel), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('a failed feed offers a retry', (tester) async {
      final repository = FakeMovieRepository(
        moviesError: 'No internet connection.',
      );
      await pumpHome(tester, repository);

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('No internet connection.'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      // Asked again rather than sitting on the error. One feed call plus one
      // per genre row, twice over.
      expect(repository.sortBys, hasLength(2));
    });
  });
}
