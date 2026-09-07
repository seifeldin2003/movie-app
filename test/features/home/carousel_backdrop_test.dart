import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/home/presentation/widgets/carousel_backdrop.dart';
import 'package:movie_app/features/movie_details/presentation/widgets/details_hero.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A record carrying all three artwork URLs, so the widget has to choose.
  const movie = Movie(
    id: 1,
    title: 'Avengers: Infinity War',
    year: 2018,
    posterUrl: 'https://example.test/medium-cover.jpg',
    largePosterUrl: 'https://example.test/large-cover.jpg',
    backgroundUrl: 'https://example.test/background.jpg',
  );

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(theme: AppTheme.dark, home: child),
      ),
    );
    await tester.pump();
  }

  String? sourceOf(WidgetTester tester) =>
      tester.widget<PosterImage>(find.byType(PosterImage).first).source;

  group('full-height artwork uses the poster, never background_image', () {
    // The bug this pins: YTS names one field `background_image`, which sounds
    // like the backdrop source and is not. It is a 896x375 letterbox banner
    // (ratio 2.39) and both of these boxes are tall — 430x645 on Home. Cover
    // has to scale that roughly four times to fill the box and shows a narrow
    // strip of the middle, so the screen reads as a smear rather than
    // artwork. `large_cover_image` is 500x750, the same 0.67 ratio as the box.

    testWidgets('Home backdrop', (tester) async {
      await pump(tester, const CarouselBackdrop(movie: movie, height: 645));

      expect(sourceOf(tester), movie.largePosterUrl);
      expect(sourceOf(tester), isNot(movie.backgroundUrl));
    });

    testWidgets('Movie Details hero', (tester) async {
      await pump(tester, const SizedBox(height: 460, child: DetailsHero(movie: movie)));

      expect(sourceOf(tester), movie.largePosterUrl);
      expect(sourceOf(tester), isNot(movie.backgroundUrl));
    });

    testWidgets('falls back to the medium poster when there is no large one', (
      tester,
    ) async {
      const noLarge = Movie(
        id: 2,
        title: 'No Large Cover',
        posterUrl: 'https://example.test/medium-cover.jpg',
        backgroundUrl: 'https://example.test/background.jpg',
      );
      await pump(tester, const CarouselBackdrop(movie: noLarge, height: 645));

      // Still the poster, still not the banner.
      expect(sourceOf(tester), noLarge.posterUrl);
    });
  });
}
