import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/usecases/logout_usecase.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
  });

  group('LogoutUsecase', () {
    test('call returns Right true when logout succeeds', () async {
      final usecase = LogoutUsecase(authRepository: mockAuthRepository);

      when(() => mockAuthRepository.logout()).thenAnswer((_) async => const Right(true));

      final result = await usecase.call();

      expect(result, const Right(true));
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('call returns Left Failure when repository logout fails', () async {
      final usecase = LogoutUsecase(authRepository: mockAuthRepository);
      const tFailure = ApiFailure(message: 'Logout failed', statusCode: 500);

      when(() => mockAuthRepository.logout()).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase.call();

      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('call invokes repository logout exactly once per call', () async {
      final usecase = LogoutUsecase(authRepository: mockAuthRepository);
      when(() => mockAuthRepository.logout()).thenAnswer((_) async => const Right(true));

      await usecase.call();
      await usecase.call();

      verify(() => mockAuthRepository.logout()).called(2);
    });
  });
}
