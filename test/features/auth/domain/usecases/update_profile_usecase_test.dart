import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/usecases/update_profile_usecase.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockIAuthRepository mockAuthRepository;

  const tAuthEntity = AuthEntity(
    userId: 'user-1',
    name: 'Test User',
    email: 'test@example.com',
    number: 1234567890,
    role: 'user',
  );

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
  });

  group('UpdateProfileUsecase', () {
    test('call with params returns Right AuthEntity when updateProfile succeeds', () async {
      final usecase = UpdateProfileUsecase(authRepository: mockAuthRepository);
      const params = UpdateProfileUsecaseParams(
        userId: 'user-1',
        name: 'Updated Name',
        email: 'updated@example.com',
        number: 9876543210,
      );

      when(() => mockAuthRepository.updateProfile(
            any(),
            name: any(named: 'name'),
            email: any(named: 'email'),
            number: any(named: 'number'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase.call(params);

      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.updateProfile(
            'user-1',
            name: 'Updated Name',
            email: 'updated@example.com',
            number: 9876543210,
            imagePath: null,
          )).called(1);
    });

    test('call returns Left ApiFailure when updateProfile fails', () async {
      final usecase = UpdateProfileUsecase(authRepository: mockAuthRepository);
      const params = UpdateProfileUsecaseParams(userId: 'user-1', name: 'New Name');
      const tFailure = ApiFailure(message: 'Update failed', statusCode: 400);

      when(() => mockAuthRepository.updateProfile(
            any(),
            name: any(named: 'name'),
            email: any(named: 'email'),
            number: any(named: 'number'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase.call(params);

      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.updateProfile(
            'user-1',
            name: 'New Name',
            email: null,
            number: null,
            imagePath: null,
          )).called(1);
    });

    test('call forwards only name when other optional params are null', () async {
      final usecase = UpdateProfileUsecase(authRepository: mockAuthRepository);
      const params = UpdateProfileUsecaseParams(
        userId: 'user-42',
        name: 'Name Only',
      );

      when(() => mockAuthRepository.updateProfile(
            any(),
            name: any(named: 'name'),
            email: any(named: 'email'),
            number: any(named: 'number'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => const Right(tAuthEntity));

      await usecase.call(params);

      verify(() => mockAuthRepository.updateProfile(
            'user-42',
            name: 'Name Only',
            email: null,
            number: null,
            imagePath: null,
          )).called(1);
    });

    test('call forwards imagePath when provided', () async {
      final usecase = UpdateProfileUsecase(authRepository: mockAuthRepository);
      const params = UpdateProfileUsecaseParams(
        userId: 'user-1',
        imagePath: '/path/to/avatar.jpg',
      );

      when(() => mockAuthRepository.updateProfile(
            any(),
            name: any(named: 'name'),
            email: any(named: 'email'),
            number: any(named: 'number'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => const Right(tAuthEntity));

      await usecase.call(params);

      verify(() => mockAuthRepository.updateProfile(
            'user-1',
            name: null,
            email: null,
            number: null,
            imagePath: '/path/to/avatar.jpg',
          )).called(1);
    });

    test('call forwards all optional params when provided', () async {
      final usecase = UpdateProfileUsecase(authRepository: mockAuthRepository);
      const params = UpdateProfileUsecaseParams(
        userId: 'user-99',
        name: 'Full Name',
        email: 'full@example.com',
        number: 1112223333,
        imagePath: 'assets/photo.png',
      );

      when(() => mockAuthRepository.updateProfile(
            any(),
            name: any(named: 'name'),
            email: any(named: 'email'),
            number: any(named: 'number'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => const Right(tAuthEntity));

      await usecase.call(params);

      verify(() => mockAuthRepository.updateProfile(
            'user-99',
            name: 'Full Name',
            email: 'full@example.com',
            number: 1112223333,
            imagePath: 'assets/photo.png',
          )).called(1);
    });
  });

  group('UpdateProfileUsecaseParams', () {
    test('props contain userId, name, email, number, imagePath', () {
      const params = UpdateProfileUsecaseParams(
        userId: 'id',
        name: 'n',
        email: 'e',
        number: 1,
        imagePath: 'path',
      );
      expect(params.props, ['id', 'n', 'e', 1, 'path']);
    });

    test('equality works for same values', () {
      const a = UpdateProfileUsecaseParams(userId: 'u', name: 'n');
      const b = UpdateProfileUsecaseParams(userId: 'u', name: 'n');
      expect(a, equals(b));
    });
  });
}
