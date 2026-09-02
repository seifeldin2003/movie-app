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

  testWidgets('splash shows the supervisor credit', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(const MovieApp());

    expect(find.text(AppStrings.supervisedBy), findsOneWidget);

    // Let the 3s splash timer fire so no timer is left pending.
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('splash advances to onboarding', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(const MovieApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.onboardingIntroTitle), findsOneWidget);
    expect(find.text(AppStrings.exploreNow), findsOneWidget);
  });

  testWidgets('onboarding pages forward to the next slide', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(const MovieApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.exploreNow));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.onboardingDiscoverTitle), findsOneWidget);
    expect(find.text(AppStrings.back), findsOneWidget);
  });
}
