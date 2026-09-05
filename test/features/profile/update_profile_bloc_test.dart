import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/profile/presentation/bloc/update_profile/update_profile_bloc.dart';
import 'package:movie_app/features/profile/presentation/bloc/update_profile/update_profile_event.dart';
import 'package:movie_app/features/profile/presentation/bloc/update_profile/update_profile_state.dart';
import 'package:movie_app/features/profile/presentation/screens/update_profile_screen.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = AppUser(uid: 'abc123', name: 'Seif', email: 'seif@test.com');
  const renamed = AppUser(uid: 'abc123', name: 'Seifeldin');

  group('UpdateProfileBloc', () {
    test('start loads the signed-in user so the form can pre-fill', () async {
      final bloc = UpdateProfileBloc(FakeAuthRepository(signedIn: user));
      addTearDown(bloc.close);

      final states = <UpdateProfileState>[];
      bloc.stream.listen(states.add);

      bloc.add(const UpdateProfileStarted());
      await Future<void>.delayed(Duration.zero);

      expect(states.last.user?.name, 'Seif');
      expect(states.last.status, UpdateProfileStatus.initial);
    });

    test('saving keeps the user on screen while it is in flight', () async {
      final bloc = UpdateProfileBloc(
        FakeAuthRepository(signedIn: user, user: renamed),
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await Future<void>.delayed(Duration.zero);

      final states = <UpdateProfileState>[];
      bloc.stream.listen(states.add);

      bloc.add(const UpdateProfileSubmitted(name: 'Seifeldin'));
      await Future<void>.delayed(Duration.zero);

      // The loading emit must carry the user forward — otherwise the form
      // blanks out mid-save. This is why the state is one class with a status
      // rather than a class per phase.
      expect(states.first.isLoading, isTrue);
      expect(states.first.user, isNotNull);

      expect(states.last.status, UpdateProfileStatus.saved);
      expect(states.last.user?.name, 'Seifeldin');
    });

    test('a stale error does not survive the next action', () async {
      final bloc = UpdateProfileBloc(
        FakeAuthRepository(signedIn: user, error: 'Something broke.'),
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileSubmitted(name: 'X'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.message, 'Something broke.');

      // copyWith deliberately drops `message` unless a new one is passed.
      bloc.add(const UpdateProfileStarted());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.message, isNull);
    });

    test('deleting the account ends in the deleted status', () async {
      final bloc = UpdateProfileBloc(FakeAuthRepository(signedIn: user));
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileDeleteRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.status, UpdateProfileStatus.deleted);
    });

    test('reset password uses the signed-in address', () async {
      final bloc = UpdateProfileBloc(FakeAuthRepository(signedIn: user));
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const UpdateProfilePasswordResetRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.status, UpdateProfileStatus.passwordResetSent);
    });
  });

  group('UpdateProfileScreen', () {
    // Nothing links to this screen yet, so without a test its DI wiring would
    // stay unexercised until Phase 3 reaches the Profile tab.
    testWidgets('resolves its Bloc and pre-fills the signed-in name', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 932) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      getIt.registerLazySingleton<AuthRepository>(
        () => FakeAuthRepository(signedIn: user),
      );
      getIt.registerFactory<UpdateProfileBloc>(
        () => UpdateProfileBloc(getIt<AuthRepository>()),
      );
      addTearDown(getIt.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: AppTheme.designSize,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const UpdateProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Seif'), findsOneWidget);
      expect(find.text(AppStrings.updateData), findsOneWidget);
      expect(find.text(AppStrings.deleteAccount), findsOneWidget);
    });
  });
}
