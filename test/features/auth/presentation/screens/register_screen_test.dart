import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:movie_app/features/auth/presentation/screens/register_screen.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  AppUser? get currentUser => null;

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    return const AppUser(
      uid: 'fake_uid',
      name: 'Fake User',
      email: 'fake@example.com',
    );
  }

  @override
  Future<AppUser> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> loginWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> updateProfile({String? name, String? photoUrl}) {
    throw UnimplementedError();
  }
}

void main() {
  setUp(() {
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
    }
    if (!getIt.isRegistered<RegisterBloc>()) {
      getIt.registerFactory(() => RegisterBloc(getIt<AuthRepository>()));
    }
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (_, child) => const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  testWidgets('RegisterScreen renders title, avatars, and fields', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.register), findsWidgets);
    expect(find.text(AppStrings.avatar), findsOneWidget);
    expect(find.text(AppStrings.name), findsOneWidget);
    expect(find.text(AppStrings.email), findsOneWidget);
    expect(find.text(AppStrings.password), findsOneWidget);
    expect(find.text(AppStrings.confirmPassword), findsOneWidget);
    expect(find.text(AppStrings.phoneNumber), findsOneWidget);
    expect(find.text(AppStrings.createAccount), findsOneWidget);
    expect(find.textContaining(AppStrings.login), findsOneWidget);
  });

  testWidgets('shows validation errors when fields are empty and submitted', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.createAccount));
    await tester.tap(find.text(AppStrings.createAccount));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.fieldRequired), findsWidgets);
  });
}
