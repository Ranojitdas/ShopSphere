import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/auth/domain/entities/user_entity.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tUsername = 'emilys';
  const tPassword = 'emilyspass';
  const tUser = UserEntity(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://example.com/emily.png',
  );

  test('should return UserEntity when repository login succeeds', () async {
    when(
      () => mockAuthRepository.login(
        username: tUsername,
        password: tPassword,
      ),
    ).thenAnswer((_) async => const Right(tUser));

    final result = await useCase(username: tUsername, password: tPassword);

    expect(result, const Right(tUser));
    verify(
      () => mockAuthRepository.login(
        username: tUsername,
        password: tPassword,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return AuthFailure when credentials are invalid', () async {
    const tFailure = AuthFailure('Invalid credentials');
    when(
      () => mockAuthRepository.login(
        username: tUsername,
        password: 'wrongpassword',
      ),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(username: tUsername, password: 'wrongpassword');

    expect(result, const Left(tFailure));
    verify(
      () => mockAuthRepository.login(
        username: tUsername,
        password: 'wrongpassword',
      ),
    ).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
