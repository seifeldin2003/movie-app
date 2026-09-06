import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/movie_grid.dart';
import 'package:movie_app/features/search/presentation/screens/search_tab.dart';

void main() {
  // Covers what the simulator cannot: its keyboard is set to Arabic, so typed
  // ASCII never reaches the field.
  Future<void> pumpSearch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(theme: AppTheme.dark, home: const SearchTab()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SearchTab', () {
    testWidgets('starts on the prompt, not an empty grid', (tester) async {
      await pumpSearch(tester);

      expect(find.text(AppStrings.searchEmpty), findsOneWidget);
      expect(find.byType(MovieGrid), findsNothing);
    });

    testWidgets('matching a title shows the grid', (tester) async {
      await pumpSearch(tester);

      await tester.enterText(find.byType(TextFormField), 'salt');
      await tester.pumpAndSettle();

      expect(find.byType(MovieGrid), findsOneWidget);
      expect(find.text(AppStrings.searchEmpty), findsNothing);
    });

    testWidgets('matching is case-insensitive', (tester) async {
      await pumpSearch(tester);

      await tester.enterText(find.byType(TextFormField), 'SALT');
      await tester.pumpAndSettle();

      expect(find.byType(MovieGrid), findsOneWidget);
    });

    testWidgets('no match says so instead of showing nothing', (tester) async {
      await pumpSearch(tester);

      await tester.enterText(find.byType(TextFormField), 'zzzzz');
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.searchNoResults), findsOneWidget);
      expect(find.byType(MovieGrid), findsNothing);
    });

    testWidgets('whitespace alone is not a search', (tester) async {
      await pumpSearch(tester);

      await tester.enterText(find.byType(TextFormField), '   ');
      await tester.pumpAndSettle();

      // Trimming matters: without it every movie would match a blank query.
      expect(find.text(AppStrings.searchEmpty), findsOneWidget);
    });
  });
}
