import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/core/widgets/movie_grid.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/history/domain/repositories/history_repository.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:movie_app/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:movie_app/features/profile/presentation/screens/profile_tab.dart';
import 'package:movie_app/features/profile/presentation/widgets/profile_tab_bar.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_history_repository.dart';
import '../../helpers/fake_user_profile_repository.dart';
import '../../helpers/fake_watchlist_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = AppUser(uid: 'abc123', name: 'Seif', email: 'seif@test.com');

  const saved = Movie(id: 1, title: 'Avengers: Infinity War', year: 2018);
  const watched = Movie(id: 2, title: 'Black Panther', year: 2018);

  /// "History" is on screen twice — as a count in the header and as a tab —
  /// so a bare `find.text` is ambiguous and `tap` refuses it.
  Finder historyTab() => find.descendant(
    of: find.byType(ProfileTabBar),
    matching: find.text(AppStrings.history),
  );

  Future<void> pumpProfile(
    WidgetTester tester, {
    List<Movie> watchList = const [],
    List<Movie> history = const [],
  }) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    getIt.registerLazySingleton<AuthRepository>(
      () => FakeAuthRepository(signedIn: user),
    );
    getIt.registerLazySingleton<UserProfileRepository>(
      FakeUserProfileRepository.new,
    );
    getIt.registerLazySingleton<WatchlistRepository>(
      () => FakeWatchlistRepository(saved: watchList),
    );
    getIt.registerLazySingleton<HistoryRepository>(
      () => FakeHistoryRepository(viewed: history),
    );
    getIt.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getIt<AuthRepository>(),
        getIt<UserProfileRepository>(),
        getIt<WatchlistRepository>(),
        getIt<HistoryRepository>(),
      ),
    );
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(theme: AppTheme.dark, home: const ProfileTab()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  /// Mounts the tab against a watch list the test keeps a handle on, so it
  /// can push a change afterwards and see whether the screen follows.
  Future<void> pumpWith(
    WidgetTester tester,
    FakeWatchlistRepository watchlist,
  ) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    getIt.registerLazySingleton<AuthRepository>(
      () => FakeAuthRepository(signedIn: user),
    );
    getIt.registerLazySingleton<UserProfileRepository>(
      FakeUserProfileRepository.new,
    );
    getIt.registerLazySingleton<WatchlistRepository>(() => watchlist);
    getIt.registerLazySingleton<HistoryRepository>(
      () => FakeHistoryRepository(),
    );
    getIt.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getIt<AuthRepository>(),
        getIt<UserProfileRepository>(),
        getIt<WatchlistRepository>(),
        getIt<HistoryRepository>(),
      ),
    );
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(theme: AppTheme.dark, home: const ProfileTab()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  group('ProfileTab', () {
    testWidgets('shows the saved movies on the Watch List tab', (tester) async {
      await pumpProfile(tester, watchList: const [saved]);

      expect(find.text('Seif'), findsOneWidget);
      expect(find.byType(MovieGrid), findsOneWidget);
      expect(find.byType(EmptyView), findsNothing);
    });

    testWidgets('an empty watch list says so rather than showing a blank', (
      tester,
    ) async {
      await pumpProfile(tester);

      expect(find.text(AppStrings.watchListEmpty), findsOneWidget);
      expect(find.byType(MovieGrid), findsNothing);
    });

    testWidgets('the History tab shows its own list, not the watch list', (
      tester,
    ) async {
      // The two tabs read different stores; a shared status would have made
      // one show the other's contents.
      await pumpProfile(
        tester,
        watchList: const [saved],
        history: const [watched],
      );

      await tester.tap(historyTab());
      await tester.pump();

      expect(find.byType(MovieGrid), findsOneWidget);
      expect(find.byType(ProfileTabBar), findsOneWidget);
    });

    testWidgets('follows the watch list live, with no refresh event', (
      tester,
    ) async {
      // What replaced the `isActive` flag. Profile subscribes to a stream, so
      // a movie saved on Details arrives here on its own — even with this tab
      // already built and sitting behind another one. Nothing in this test
      // dispatches an event or rebuilds the widget.
      final watchlist = FakeWatchlistRepository();
      await pumpWith(tester, watchlist);

      expect(find.text(AppStrings.watchListEmpty), findsOneWidget);

      // As if the bookmark had been tapped on Movie Details.
      await watchlist.add(saved);
      await tester.pump();
      await tester.pump();

      expect(find.byType(MovieGrid), findsOneWidget);
      expect(find.text(AppStrings.watchListEmpty), findsNothing);
    });

    testWidgets('a movie removed elsewhere disappears from the grid', (
      tester,
    ) async {
      final watchlist = FakeWatchlistRepository(saved: const [saved]);
      await pumpWith(tester, watchlist);

      expect(find.byType(MovieGrid), findsOneWidget);

      await watchlist.remove(saved.id);
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.watchListEmpty), findsOneWidget);
    });

    testWidgets('an empty history says so', (tester) async {
      await pumpProfile(tester, watchList: const [saved]);

      await tester.tap(historyTab());
      await tester.pump();

      expect(find.text(AppStrings.historyEmpty), findsOneWidget);
    });
  });
}
