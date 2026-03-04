import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/usecases/register_usecase.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockIAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(const AuthEntity(name: '', email: ''));
  });

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
  });

  group('RegisterUsecase', () {
    test('call with params returns Right true when register succeeds', () async {
      final usecase = RegisterUsecase(authRepository: mockAuthRepository);
      const params = RegisterUsecaseParams(
        fullName: 'New User',
        email: 'new@example.com',
        password: 'password123',
      );

      when(() => mockAuthRepository.register(any())).thenAnswer((_) async => const Right(true));

      final result = await usecase.call(params);

      expect(result, const Right(true));
      verify(() => mockAuthRepository.register(any())).called(1);
    });

    test('call returns Left ApiFailure when repository register fails', () async {
      final usecase = RegisterUsecase(authRepository: mockAuthRepository);
      const params = RegisterUsecaseParams(
        fullName: 'New User',
        email: 'taken@example.com',
        password: 'password123',
      );
      const tFailure = ApiFailure(message: 'Email already in use', statusCode: 409);

      when(() => mockAuthRepository.register(any())).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase.call(params);

      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.register(any())).called(1);
    });

    test('call builds AuthEntity with fullName as name and forwards to repository', () async {
      AuthEntity? capturedEntity;
      when(() => mockAuthRepository.register(any())).thenAnswer((invocation) async {
        capturedEntity = invocation.positionalArguments.first as AuthEntity;
        return const Right(true);
      });

      final usecase = RegisterUsecase(authRepository: mockAuthRepository);
      const params = RegisterUsecaseParams(
        fullName: 'Dr. Jane Doe',
        email: 'jane@example.com',
        password: 'secret',
      );

      await usecase.call(params);

      expect(capturedEntity, isNotNull);
      expect(capturedEntity!.name, 'Dr. Jane Doe');
      expect(capturedEntity!.email, 'jane@example.com');
      expect(capturedEntity!.password, 'secret');
      expect(capturedEntity!.userId, isNull);
      expect(capturedEntity!.role, isNull);
      expect(capturedEntity!.number, isNull);
    });

    test('call builds AuthEntity with optional role and number when provided', () async {
      AuthEntity? capturedEntity;
      when(() => mockAuthRepository.register(any())).thenAnswer((invocation) async {
        capturedEntity = invocation.positionalArguments.first as AuthEntity;
        return const Right(true);
      });

      final usecase = RegisterUsecase(authRepository: mockAuthRepository);
      const params = RegisterUsecaseParams(
        fullName: 'Admin User',
        email: 'admin@example.com',
        role: 'admin',
        password: 'admin123',
        number: '9998887777',
      );

      await usecase.call(params);

      expect(capturedEntity, isNotNull);
      expect(capturedEntity!.name, 'Admin User');
      expect(capturedEntity!.email, 'admin@example.com');
      expect(capturedEntity!.role, 'admin');
      expect(capturedEntity!.number, '9998887777');
    });
  });

  group('RegisterUsecaseParams', () {
    test('props contain fullName, email, role, password, number', () {
      const params = RegisterUsecaseParams(
        fullName: 'A',
        email: 'a@b.com',
        password: 'p',
        role: 'r',
        number: '1',
      );
      expect(params.props, ['A', 'a@b.com', 'r', 'p', '1']);
    });

    test('equality works for same values', () {
      const a = RegisterUsecaseParams(fullName: 'X', email: 'x@y.com', password: 'p');
      const b = RegisterUsecaseParams(fullName: 'X', email: 'x@y.com', password: 'p');
      expect(a, equals(b));
    });
  });
}
