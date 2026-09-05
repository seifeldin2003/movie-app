import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/app.dart';
import 'package:movie_app/core/constants/app_strings.dart';

void main() {
  // The Figma frames are 430x932; the default test window is 800 wide, which
  // would lay the screens out nothing like a phone.
  void usePhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// Splash animates the credit line in (2s), then holds (2s) before replacing
  /// itself with Onboarding. Stepping through both beats — rather than one big
  /// pump — is what lets the animation complete and schedule the hold timer.
  Future<void> advancePastSplash(WidgetTester tester) async {
    await tester.pump();
    // Land just past each boundary — pumping exactly onto it can leave the
    // completion listener to the following frame.
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();
  }

  testWidgets('splash shows the supervisor credit', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(const MovieApp());

    expect(find.text(AppStrings.supervisedBy), findsOneWidget);

    // Drain the animation and hold timer so none is left pending.
    await advancePastSplash(tester);
  });

  testWidgets('splash advances to onboarding', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(const MovieApp());
    await advancePastSplash(tester);

    expect(find.text(AppStrings.onboardingIntroTitle), findsOneWidget);
    expect(find.text(AppStrings.exploreNow), findsOneWidget);
  });

  testWidgets('onboarding pages forward to the next slide', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(const MovieApp());
    await advancePastSplash(tester);

    await tester.tap(find.text(AppStrings.exploreNow));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.onboardingDiscoverTitle), findsOneWidget);
    expect(find.text(AppStrings.back), findsOneWidget);
  });
}
