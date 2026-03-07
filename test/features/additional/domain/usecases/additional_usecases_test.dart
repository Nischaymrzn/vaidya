import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/usecases/is_google_login_configured_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_with_google_token_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';
import 'package:vaidya/features/dashboard/domain/entities/user_data_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:vaidya/features/dashboard/domain/repositories/notifications_repository.dart';
import 'package:vaidya/features/dashboard/domain/repositories/user_data_repository.dart';
import 'package:vaidya/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:vaidya/features/dashboard/domain/usecases/get_notifications_usecase.dart';
import 'package:vaidya/features/dashboard/domain/usecases/get_user_data_usecase.dart';
import 'package:vaidya/features/dashboard/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:vaidya/features/dashboard/domain/usecases/mark_notification_read_usecase.dart';
import 'package:vaidya/features/dashboard/domain/usecases/update_user_data_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockDashboardRepository extends Mock implements IDashboardRepository {}

class MockNotificationsRepository extends Mock
    implements INotificationsRepository {}

class MockUserDataRepository extends Mock implements IUserDataRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockDashboardRepository mockDashboardRepository;
  late MockNotificationsRepository mockNotificationsRepository;
  late MockUserDataRepository mockUserDataRepository;

  const tAuthEntity = AuthEntity(
    userId: 'user-1',
    name: 'Tester',
    email: 'tester@vaidya.ai',
    number: '9800000000',
    role: 'user',
  );
  const tSummary = DashboardSummaryEntity.empty();
  const tNotification = NotificationEntity(
    id: 'n-1',
    data: {'title': 'Test', 'message': 'Hello', 'read': false},
  );
  const tNotificationsResult = NotificationsResultEntity.empty();
  const tUserData = UserDataEntity(id: 'u-1', data: {'name': 'Tester'});

  setUpAll(() {
    registerFallbackValue(
      const LoginWithGoogleTokenUsecaseParams(token: 'token'),
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockDashboardRepository = MockDashboardRepository();
    mockNotificationsRepository = MockNotificationsRepository();
    mockUserDataRepository = MockUserDataRepository();
  });

  group('Additional Usecase Unit Tests', () {
    test('1) IsGoogleLoginConfiguredUsecase forwards and returns repository result', () async {
      final usecase = IsGoogleLoginConfiguredUsecase(
        authRepository: mockAuthRepository,
      );
      when(
        () => mockAuthRepository.isGoogleLoginConfigured(),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase();

      expect(result, const Right(true));
      verify(() => mockAuthRepository.isGoogleLoginConfigured()).called(1);
    });

    test('2) LoginWithGoogleTokenUsecase forwards token to repository', () async {
      final usecase = LoginWithGoogleTokenUsecase(
        authRepository: mockAuthRepository,
      );
      const params = LoginWithGoogleTokenUsecaseParams(token: 'abc123');
      when(
        () => mockAuthRepository.loginWithGoogleToken('abc123'),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase(params);

      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.loginWithGoogleToken('abc123')).called(1);
    });

    test('3) LoginWithGoogleUsecase returns repository value', () async {
      final usecase = LoginWithGoogleUsecase(authRepository: mockAuthRepository);
      when(
        () => mockAuthRepository.loginWithGoogle(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final result = await usecase();

      expect(result, const Right(tAuthEntity));
      verify(() => mockAuthRepository.loginWithGoogle()).called(1);
    });

    test('4) RequestPasswordResetUsecase forwards email correctly', () async {
      final usecase = RequestPasswordResetUsecase(
        authRepository: mockAuthRepository,
      );
      const params = RequestPasswordResetUsecaseParams(
        email: 'demo@vaidya.ai',
      );
      when(
        () => mockAuthRepository.requestPasswordReset('demo@vaidya.ai'),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(params);

      expect(result, const Right(true));
      verify(() => mockAuthRepository.requestPasswordReset('demo@vaidya.ai'))
          .called(1);
    });

    test('5) GetDashboardSummaryUsecase returns dashboard summary', () async {
      final usecase = GetDashboardSummaryUsecase(
        dashboardRepository: mockDashboardRepository,
      );
      when(
        () => mockDashboardRepository.getDashboardSummary(),
      ).thenAnswer((_) async => const Right(tSummary));

      final result = await usecase();

      expect(result, const Right(tSummary));
      verify(() => mockDashboardRepository.getDashboardSummary()).called(1);
    });

    test('6) GetNotificationsUsecase passes page/limit/unreadOnly params', () async {
      const params = GetNotificationsParams(page: 2, limit: 10, unreadOnly: true);
      final usecase = GetNotificationsUsecase(
        repository: mockNotificationsRepository,
      );
      when(
        () => mockNotificationsRepository.getNotifications(
          page: 2,
          limit: 10,
          unreadOnly: true,
        ),
      ).thenAnswer((_) async => const Right(tNotificationsResult));

      final result = await usecase(params);

      expect(result, const Right(tNotificationsResult));
      verify(
        () => mockNotificationsRepository.getNotifications(
          page: 2,
          limit: 10,
          unreadOnly: true,
        ),
      ).called(1);
    });

    test('7) GetUserDataUsecase returns user data', () async {
      final usecase = GetUserDataUsecase(repository: mockUserDataRepository);
      when(
        () => mockUserDataRepository.getUserData(),
      ).thenAnswer((_) async => const Right(tUserData));

      final result = await usecase();

      expect(result, const Right(tUserData));
      verify(() => mockUserDataRepository.getUserData()).called(1);
    });

    test('8) MarkNotificationReadUsecase forwards notification id', () async {
      const params = MarkNotificationReadParams(id: 'n-1');
      final usecase = MarkNotificationReadUsecase(
        repository: mockNotificationsRepository,
      );
      when(
        () => mockNotificationsRepository.markRead('n-1'),
      ).thenAnswer((_) async => const Right(tNotification));

      final result = await usecase(params);

      expect(result, const Right(tNotification));
      verify(() => mockNotificationsRepository.markRead('n-1')).called(1);
    });

    test('9) MarkAllNotificationsReadUsecase marks all as read', () async {
      final usecase = MarkAllNotificationsReadUsecase(
        repository: mockNotificationsRepository,
      );
      when(
        () => mockNotificationsRepository.markAllRead(),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase();

      expect(result, const Right(true));
      verify(() => mockNotificationsRepository.markAllRead()).called(1);
    });

    test('10) UpdateUserDataUsecase forwards payload and returns updated entity', () async {
      const params = UpdateUserDataParams(payload: {'name': 'Updated'});
      final usecase = UpdateUserDataUsecase(repository: mockUserDataRepository);
      when(
        () => mockUserDataRepository.updateUserData({'name': 'Updated'}),
      ).thenAnswer((_) async => const Right(tUserData));

      final result = await usecase(params);

      expect(result, const Right(tUserData));
      verify(() => mockUserDataRepository.updateUserData({'name': 'Updated'}))
          .called(1);
    });

  });
}
