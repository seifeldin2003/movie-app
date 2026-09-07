import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/core/widgets/popcorn_empty_art.dart';
import 'package:movie_app/core/widgets/popcorn_scene_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpArt(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppTheme.designSize,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: const Scaffold(
              body: EmptyView(message: 'Search for a movie to get started.'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('PopcornEmptyArt', () {
    testWidgets('EmptyView draws the scene rather than an image', (
      tester,
    ) async {
      // The illustration is painted, not loaded: the old `empty_state.png` was
      // a single flat raster, so its kernels and cup could never move
      // independently.
      await pumpArt(tester);

      expect(find.byType(PopcornEmptyArt), findsOneWidget);
      expect(find.text('Search for a movie to get started.'), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      // Leave the loop in a known place rather than trailing a live ticker.
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('keeps animating — it is a loop, not a one-shot', (
      tester,
    ) async {
      await pumpArt(tester);
      await tester.pump(const Duration(milliseconds: 400));

      // A running controller keeps asking for the next frame. Asserting on
      // that rather than on `pumpAndSettle` timing out: the timeout escapes
      // asynchronously after the test finishes, so it cannot be caught.
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('holds still when the OS asks for reduced motion', (
      tester,
    ) async {
      // Accessibility: the picture still draws, it just stops looping. If the
      // controller were still running, this would time out like the test above.
      await pumpArt(tester, reduceMotion: true);
      await tester.pumpAndSettle();

      // Nothing left asking for frames — the exact opposite of the test above.
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.byType(PopcornEmptyArt), findsOneWidget);
    });

    testWidgets('disposes its ticker with the screen', (tester) async {
      // A leaked AnimationController fails the test binding, so simply
      // replacing the tree and settling proves dispose ran.
      await pumpArt(tester);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });

  group('PopcornScenePainter', () {
    test('carries every kernel from the supplied components', () {
      // Eight blobs in PopcornWithPacket.tsx, on five shared `kpop-*` phases.
      expect(PopcornScenePainter.kernels, hasLength(8));
      expect(
        PopcornScenePainter.kernels.map((k) => k.phase).toSet(),
        {0.00, 0.10, 0.20, 0.30, 0.40},
      );
    });

    test('the scene keeps the components 160x200 proportions', () {
      // The widget sizes its height from this, so a wrong ratio would squash
      // the drawing rather than fail loudly.
      expect(PopcornScenePainter.scene, const Size(160, 200));
    });
  });
}
