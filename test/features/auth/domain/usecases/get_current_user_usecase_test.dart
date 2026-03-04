import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/usecases/get_current_user_usecase.dart';

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

  group('GetCurrentUserUsecase', () {
    test('call returns Right AuthEntity when getCurrentUser succeeds', () async {
      final usecase = GetCurrentUserUsecase(authRepository: mockAuthRepository);

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase.call();

      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('call returns Left Failure when getCurrentUser fails', () async {
      final usecase = GetCurrentUserUsecase(authRepository: mockAuthRepository);
      const tFailure = ApiFailure(message: 'Not authenticated', statusCode: 401);

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      final result = await usecase.call();

      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('call returns Left LocalDatabaseFailure when local fetch fails', () async {
      final usecase = GetCurrentUserUsecase(authRepository: mockAuthRepository);
      const tFailure = LocalDatabaseFailure(message: 'User not found');

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      final result = await usecase.call();

      expect(result, const Left(tFailure));
    });

    test('call invokes repository getCurrentUser exactly once per call', () async {
      final usecase = GetCurrentUserUsecase(authRepository: mockAuthRepository);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(tAuthEntity));

      await usecase.call();
      await usecase.call();

      verify(() => mockAuthRepository.getCurrentUser()).called(2);
    });
  });
}
