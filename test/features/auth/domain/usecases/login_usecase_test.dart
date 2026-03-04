import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/usecases/login_usecase.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockIAuthRepository mockAuthRepository;

  const tAuthEntity = AuthEntity(
    userId: 'user-1',
    name: 'Test User',
    email: 'test@example.com',
    number: '1234567890',
    role: 'user',
  );

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
  });

  group('LoginUsecase', () {
    test('call with email and password returns Right AuthEntity when login succeeds', () async {
      final usecase = LoginUsecase(authRepository: mockAuthRepository);
      const params = LoginUsecaseParams(email: 'test@example.com', password: 'password123');

      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase.call(params);

      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.login('test@example.com', 'password123')).called(1);
    });

    test('call returns Left ApiFailure when repository login fails', () async {
      final usecase = LoginUsecase(authRepository: mockAuthRepository);
      const params = LoginUsecaseParams(email: 'bad@example.com', password: 'wrong');
      const tFailure = ApiFailure(message: 'Invalid credentials', statusCode: 401);

      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await usecase.call(params);

      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.login('bad@example.com', 'wrong')).called(1);
    });

    test('call forwards exact email and password to repository', () async {
      final usecase = LoginUsecase(authRepository: mockAuthRepository);
      const params = LoginUsecaseParams(
        email: 'exact@test.com',
        password: 'exactPassword',
      );

      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      await usecase.call(params);

      verify(() => mockAuthRepository.login('exact@test.com', 'exactPassword')).called(1);
    });
  });

  group('LoginUsecaseParams', () {
    test('props contain email and password', () {
      const params = LoginUsecaseParams(email: 'a@b.com', password: 'pwd');
      expect(params.props, ['a@b.com', 'pwd']);
    });

    test('equality works for same email and password', () {
      const a = LoginUsecaseParams(email: 'x@y.com', password: 'same');
      const b = LoginUsecaseParams(email: 'x@y.com', password: 'same');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
