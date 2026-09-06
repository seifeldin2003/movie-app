import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:movie_app/features/auth/presentation/bloc/register/register_event.dart';
import 'package:movie_app/features/auth/presentation/bloc/register/register_state.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? userToReturn;
  String? errorToThrow;

  @override
  AppUser? get currentUser => userToReturn;

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return userToReturn!;
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
  late MockAuthRepository mockAuthRepository;
  late RegisterBloc registerBloc;

  const testUser = AppUser(
    uid: '123',
    name: 'Test User',
    email: 'test@example.com',
    phoneNumber: '+1234567890',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerBloc = RegisterBloc(mockAuthRepository);
  });

  tearDown(() {
    registerBloc.close();
  });

  test('initial state is RegisterInitial', () {
    expect(registerBloc.state, const RegisterInitial());
  });

  test('emits [RegisterLoading, RegisterSuccess] on successful registration', () async {
    mockAuthRepository.userToReturn = testUser;

    final expectedStates = [
      const RegisterLoading(),
      const RegisterSuccess(testUser),
    ];

    expectLater(registerBloc.stream, emitsInOrder(expectedStates));

    registerBloc.add(
      const RegisterSubmitted(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        phoneNumber: '+1234567890',
      ),
    );
  });

  test('emits [RegisterLoading, RegisterFailure] when registration fails', () async {
    mockAuthRepository.errorToThrow = 'Email already in use';

    final expectedStates = [
      const RegisterLoading(),
      const RegisterFailure('Email already in use'),
    ];

    expectLater(registerBloc.stream, emitsInOrder(expectedStates));

    registerBloc.add(
      const RegisterSubmitted(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        phoneNumber: '+1234567890',
      ),
    );
  });
}
