import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/profile/data/datasources/avatar_photo_picker.dart';
import 'package:movie_app/features/profile/domain/entities/user_profile.dart';
import 'package:movie_app/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:movie_app/features/profile/presentation/bloc/update_profile/update_profile_bloc.dart';
import 'package:movie_app/features/profile/presentation/bloc/update_profile/update_profile_event.dart';
import 'package:movie_app/features/profile/presentation/bloc/update_profile/update_profile_state.dart';
import 'package:movie_app/features/profile/presentation/screens/update_profile_screen.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_user_profile_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = AppUser(uid: 'abc123', name: 'Seif', email: 'seif@test.com');
  const renamed = AppUser(uid: 'abc123', name: 'Seifeldin');

  UpdateProfileBloc buildBloc({
    AuthRepository? auth,
    UserProfileRepository? profiles,
    AvatarPhotoPicker? picker,
  }) => UpdateProfileBloc(
    auth ?? FakeAuthRepository(signedIn: user),
    profiles ?? FakeUserProfileRepository(),
    picker ?? FakeAvatarPhotoPicker(),
  );

  /// Lets the Bloc drain its handlers before assertions.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('UpdateProfileBloc', () {
    test('start loads the auth user and the stored profile', () async {
      final bloc = buildBloc(
        profiles: FakeUserProfileRepository(
          stored: const UserProfile(
            uid: 'abc123',
            avatarId: 'avatar_4',
            phoneNumber: '0100',
          ),
        ),
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();

      expect(bloc.state.user?.name, 'Seif');
      expect(bloc.state.profile?.avatarId, 'avatar_4');
      expect(bloc.state.profile?.phoneNumber, '0100');
    });

    test('a user with no document still gets an empty profile', () async {
      // The normal state straight after sign-up — must not read as an error.
      final bloc = buildBloc(profiles: FakeUserProfileRepository());
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();

      expect(bloc.state.profile, isNotNull);
      expect(bloc.state.profile?.avatarId, isNull);
      expect(bloc.state.status, isNot(UpdateProfileStatus.failure));
    });

    test('picking an avatar stages it and drops any uploaded photo', () async {
      final bloc = buildBloc(
        profiles: FakeUserProfileRepository(
          stored: const UserProfile(uid: 'abc123', photoBase64: 'QUJD'),
        ),
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();
      expect(bloc.state.profile?.hasUploadedPhoto, isTrue);

      bloc.add(const UpdateProfileAvatarSelected('avatar_7'));
      await settle();

      // Without clearing the photo the tap would look like it did nothing,
      // since an uploaded photo outranks the illustration.
      expect(bloc.state.profile?.avatarId, 'avatar_7');
      expect(bloc.state.profile?.hasUploadedPhoto, isFalse);
    });

    test('uploading stages the encoded photo', () async {
      final bloc = buildBloc(picker: FakeAvatarPhotoPicker(encoded: 'QUJD'));
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();

      bloc.add(const UpdateProfilePhotoUploadRequested());
      await settle();

      expect(bloc.state.profile?.photoBase64, 'QUJD');
    });

    test('dismissing the gallery is not a failure', () async {
      // Same rule as the Google picker: a cancel must not raise a red bar.
      final bloc = buildBloc(picker: FakeAvatarPhotoPicker());
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();

      bloc.add(const UpdateProfilePhotoUploadRequested());
      await settle();

      expect(bloc.state.status, isNot(UpdateProfileStatus.failure));
      expect(bloc.state.profile?.hasUploadedPhoto, isFalse);
    });

    test('an oversized photo surfaces the message', () async {
      final bloc = buildBloc(
        picker: FakeAvatarPhotoPicker(error: AppStrings.photoTooLarge),
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();

      bloc.add(const UpdateProfilePhotoUploadRequested());
      await settle();

      expect(bloc.state.status, UpdateProfileStatus.failure);
      expect(bloc.state.message, AppStrings.photoTooLarge);
    });

    test('removing the photo falls back to the illustration', () async {
      final bloc = buildBloc(
        profiles: FakeUserProfileRepository(
          stored: const UserProfile(
            uid: 'abc123',
            avatarId: 'avatar_2',
            photoBase64: 'QUJD',
          ),
        ),
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();

      bloc.add(const UpdateProfilePhotoRemoved());
      await settle();

      expect(bloc.state.profile?.hasUploadedPhoto, isFalse);
      expect(bloc.state.profile?.avatarId, 'avatar_2');
    });

    test('saving writes the name to auth and the rest to Firestore', () async {
      final profiles = FakeUserProfileRepository();
      final bloc = buildBloc(
        auth: FakeAuthRepository(signedIn: user, user: renamed),
        profiles: profiles,
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();
      bloc.add(const UpdateProfileAvatarSelected('avatar_5'));
      await settle();

      bloc.add(
        const UpdateProfileSubmitted(name: 'Seifeldin', phoneNumber: '0111'),
      );
      await settle();

      expect(bloc.state.status, UpdateProfileStatus.saved);
      expect(bloc.state.user?.name, 'Seifeldin');
      // The avatar and phone go to Firestore, since Auth can hold neither.
      expect(profiles.saved?.avatarId, 'avatar_5');
      expect(profiles.saved?.phoneNumber, '0111');
    });

    test('saving keeps the user on screen while it is in flight', () async {
      final bloc = buildBloc(
        auth: FakeAuthRepository(signedIn: user, user: renamed),
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();

      final states = <UpdateProfileState>[];
      bloc.stream.listen(states.add);

      bloc.add(const UpdateProfileSubmitted(name: 'Seifeldin'));
      await settle();

      // The loading emit must carry the user forward, or the form blanks out
      // mid-save. That is why the state is one class with a status.
      expect(states.first.isLoading, isTrue);
      expect(states.first.user, isNotNull);
      expect(states.last.status, UpdateProfileStatus.saved);
    });

    test('a stale error does not survive the next action', () async {
      final bloc = buildBloc(
        auth: FakeAuthRepository(signedIn: user, error: 'Something broke.'),
      );
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileSubmitted(name: 'X'));
      await settle();
      expect(bloc.state.message, isNull, reason: 'no user loaded yet');

      bloc.add(const UpdateProfileStarted());
      await settle();
      bloc.add(const UpdateProfileSubmitted(name: 'X'));
      await settle();
      expect(bloc.state.message, 'Something broke.');

      // copyWith deliberately drops `message` unless a new one is passed.
      bloc.add(const UpdateProfileAvatarSelected('avatar_3'));
      await settle();
      expect(bloc.state.message, isNull);
    });

    test('deleting the account ends in the deleted status', () async {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileDeleteRequested());
      await settle();

      expect(bloc.state.status, UpdateProfileStatus.deleted);
    });

    test('reset password uses the signed-in address', () async {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      bloc.add(const UpdateProfileStarted());
      await settle();

      bloc.add(const UpdateProfilePasswordResetRequested());
      await settle();

      expect(bloc.state.status, UpdateProfileStatus.passwordResetSent);
    });
  });

  group('UpdateProfileScreen', () {
    // Nothing linked to this screen until Profile's Edit button landed, so
    // without a test its DI wiring would have stayed unexercised.
    testWidgets('resolves its Bloc and pre-fills the signed-in name', (
      tester,
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
      getIt.registerLazySingleton<AvatarPhotoPicker>(
        FakeAvatarPhotoPicker.new,
      );
      getIt.registerFactory<UpdateProfileBloc>(
        () => UpdateProfileBloc(
          getIt<AuthRepository>(),
          getIt<UserProfileRepository>(),
          getIt<AvatarPhotoPicker>(),
        ),
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
