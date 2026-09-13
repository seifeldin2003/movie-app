import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_genres.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/movies/domain/entities/movie.dart';
import 'package:movie_app/core/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/core/network/network_status.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/genre_chip.dart';
import 'package:movie_app/features/layout/browse/presentation/bloc/browse/browse_bloc.dart';
import 'package:movie_app/features/layout/browse/presentation/screens/browse_tab.dart';
import 'package:movie_app/features/layout/home/presentation/bloc/home/home_bloc.dart';
import 'package:movie_app/features/layout/home/presentation/widgets/genre_section.dart';
import 'package:movie_app/features/layout/presentation/screens/layout_screen.dart';
import 'package:movie_app/features/layout/search/presentation/bloc/search/search_bloc.dart';

import '../../helpers/fake_movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const catalogue = [
    Movie(id: 1, title: 'Salt Flats', year: 2017),
    Movie(id: 2, title: 'Under the Wire', year: 2024),
  ];

  late FakeMovieRepository repository;

  Future<void> pumpLayout(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    repository = FakeMovieRepository(movies: catalogue);

    getIt.registerLazySingleton<MovieRepository>(() => repository);
    getIt.registerLazySingleton<NetworkStatus>(() => NetworkStatus());
    getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<MovieRepository>()));
    getIt.registerFactory<SearchBloc>(
      () => SearchBloc(getIt<MovieRepository>()),
    );
    getIt.registerFactory<BrowseBloc>(
      () => BrowseBloc(getIt<MovieRepository>()),
    );
    // ⚠️ No ProfileBloc on purpose. Profile is never opened in these tests and
    // the shell builds tabs lazily, so registering it would only assert that
    // the laziness is broken.
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(theme: AppTheme.dark, home: const LayoutScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  /// The genre the selected chip is showing, read off the widget rather than
  /// the Bloc — this is what the user can actually see.
  ///
  /// ⚠️ Only reliable while the chip row has not been scrolled: it is a lazy
  /// horizontal ListView, so a chip scrolled out of range is not in the tree
  /// at all. Use [browseGenre] once the row has moved.
  String selectedChip(WidgetTester tester) {
    return tester
        .widgetList<GenreChip>(find.byType(GenreChip))
        .firstWhere((chip) => chip.isSelected)
        .label;
  }

  /// Taps the "See More" on a given genre row.
  ///
  /// ⚠️ `ensureVisible` first. The second row's button sits below the fold at
  /// 430x932, so a plain tap lands outside the render tree and does nothing —
  /// and a missed tap only warns, it does not fail, so the test would go on to
  /// assert against a screen that never changed.
  Future<void> tapSeeMore(WidgetTester tester, GenreSection section) async {
    final button = find.descendant(
      of: find.byWidget(section),
      matching: find.text(AppStrings.seeMore),
    );
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();
    await tester.pump();
  }

  /// The genre Browse is actually on — the state every chip renders from.
  String browseGenre(WidgetTester tester) {
    return tester
        .widget<BrowseTab>(find.byType(BrowseTab))
        .bloc!
        .state
        .selectedGenre;
  }

  group('LayoutScreen', () {
    testWidgets('does not build Browse until it is opened', (tester) async {
      await pumpLayout(tester);

      // The laziness the shell is built around: only Home's requests have run.
      expect(find.byType(BrowseTab), findsNothing);
      expect(repository.genres, AppGenres.homeRows);
    });

    testWidgets('See More opens Browse on that row\'s genre', (tester) async {
      await pumpLayout(tester);

      // Second row, so the assertion cannot pass on Browse's default genre.
      final section = tester
          .widgetList<GenreSection>(find.byType(GenreSection))
          .last;
      expect(section.title, isNot(AppGenres.defaultGenre));

      await tapSeeMore(tester, section);

      expect(find.byType(BrowseTab), findsOneWidget);
      expect(selectedChip(tester), section.title);
      expect(repository.genres.last, section.title);
    });

    testWidgets('See More overrides a genre already chosen in Browse', (
      tester,
    ) async {
      // ⚠️ The case the whole design turns on. Once Browse has been visited,
      // IndexedStack keeps it alive, so a genre passed down as a constructor
      // argument would never be dispatched — nothing about it looks changed
      // from the shell's point of view.
      await pumpLayout(tester);

      // Open Browse from the nav bar and pick a different genre by hand.
      await tester.tap(find.byIcon(Icons.explore_outlined));
      await tester.pump();
      await tester.pump();

      // ⚠️ The chip row is a lazy horizontal ListView and only the first few
      // chips are laid out at 430pt, so a plain tap on this one lands on empty
      // space and silently does nothing.
      const picked = 'Animation';
      final chip = find.widgetWithText(GenreChip, picked);
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pump();
      await tester.pump();
      expect(browseGenre(tester), picked);

      // Back to Home, then See More on a row. `home_outlined` because Browse
      // is the selected tab at this point, so Home is showing its inactive
      // icon — `Icons.home` is the active one and is not in the tree.
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pump();

      final section = tester
          .widgetList<GenreSection>(find.byType(GenreSection))
          .last;
      await tapSeeMore(tester, section);

      // On the Bloc rather than the chip: the row is still scrolled to where
      // "Animation" was, so the newly selected chip is not laid out.
      expect(browseGenre(tester), section.title);
      expect(browseGenre(tester), isNot(picked));
      expect(repository.genres.last, section.title);
    });
  });
}
