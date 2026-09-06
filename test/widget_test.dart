import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/app.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/home/presentation/widgets/movie_carousel.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  // The Figma frames are 430x932; the default test window is 800 wide, which
  // would lay the screens out nothing like a phone.
  void usePhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// Splash asks the repository whether a session was restored, so DI has to
  /// be stood up — with a fake, never the real Firebase-backed one.
  void useAuth({AppUser? signedIn}) {
    getIt.registerLazySingleton<AuthRepository>(
      () => FakeAuthRepository(signedIn: signedIn),
    );
    addTearDown(getIt.reset);
  }

  /// Splash animates the credit line in (2s), then holds (2s) before replacing
  /// itself. Stepping through both beats — rather than one big pump — is what
  /// lets the animation complete and schedule the hold timer. Landing just
  /// past each boundary matters: exactly on it can leave the completion
  /// listener to the following frame.
  Future<void> advancePastSplash(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();
  }

  testWidgets('splash shows the supervisor credit', (tester) async {
    usePhoneSurface(tester);
    useAuth();

    await tester.pumpWidget(const MovieApp());

    expect(find.text(AppStrings.supervisedBy), findsOneWidget);

    // Drain the animation and hold timer so none is left pending.
    await advancePastSplash(tester);
  });

  testWidgets('a signed-out user goes to onboarding', (tester) async {
    usePhoneSurface(tester);
    useAuth();

    await tester.pumpWidget(const MovieApp());
    await advancePastSplash(tester);

    expect(find.text(AppStrings.onboardingIntroTitle), findsOneWidget);
    expect(find.text(AppStrings.exploreNow), findsOneWidget);
  });

  testWidgets('a restored session skips straight to the app', (tester) async {
    usePhoneSurface(tester);
    useAuth(signedIn: const AppUser(uid: 'abc123', name: 'Seif'));

    await tester.pumpWidget(const MovieApp());
    await advancePastSplash(tester);

    // The shell, not the sign-in flow.
    expect(find.byType(MovieCarousel), findsOneWidget);
    expect(find.text(AppStrings.onboardingIntroTitle), findsNothing);
  });

  testWidgets('onboarding pages forward to the next slide', (tester) async {
    usePhoneSurface(tester);
    useAuth();

    await tester.pumpWidget(const MovieApp());
    await advancePastSplash(tester);

    await tester.tap(find.text(AppStrings.exploreNow));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.onboardingDiscoverTitle), findsOneWidget);
    expect(find.text(AppStrings.back), findsOneWidget);
  });
}
