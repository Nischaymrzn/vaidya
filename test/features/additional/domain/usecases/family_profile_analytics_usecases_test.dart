import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/analytics/domain/entities/analytics_summary_entity.dart';
import 'package:vaidya/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:vaidya/features/analytics/domain/usecases/get_analytics_summary_usecase.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/repositories/family_health_repository.dart';
import 'package:vaidya/features/family_health/domain/usecases/add_family_member_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/create_family_group_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/create_family_invite_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/get_my_family_group_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/join_family_invite_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/update_family_member_relation_usecase.dart';
import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/profile_repository.dart';
import 'package:vaidya/features/profile/domain/usecases/get_profile_payment_status_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/get_profile_user_usecase.dart';

class MockFamilyHealthRepository extends Mock
    implements IFamilyHealthRepository {}

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockAnalyticsRepository extends Mock implements IAnalyticsRepository {}

void main() {
  late MockFamilyHealthRepository mockFamilyRepository;
  late MockProfileRepository mockProfileRepository;
  late MockAnalyticsRepository mockAnalyticsRepository;

  const tFamilyGroup = FamilyGroupEntity(
    id: 'group-1',
    data: {'name': 'Family Alpha'},
  );
  const tFamilySummary = FamilyGroupSummaryEntity(data: {'members': 3});
  const tFamilyInvite = FamilyInviteEntity(
    token: 'invite-token-1',
    data: {'link': 'https://demo.link'},
  );
  const tProfileUser = ProfileUserEntity(
    id: 'user-1',
    data: {'name': 'Nischay'},
  );
  const tAnalyticsSummary = AnalyticsSummaryEntity(data: {'encounters': 12});
  const tFailure = ApiFailure(message: 'Request failed', statusCode: 500);

  setUp(() {
    mockFamilyRepository = MockFamilyHealthRepository();
    mockProfileRepository = MockProfileRepository();
    mockAnalyticsRepository = MockAnalyticsRepository();
  });

  group('Family/Profile/Analytics Usecase Unit Tests', () {
    test('1) GetMyFamilyGroupUsecase returns repository group', () async {
      final usecase = GetMyFamilyGroupUsecase(repository: mockFamilyRepository);
      when(
        () => mockFamilyRepository.getMyGroup(),
      ).thenAnswer((_) async => const Right(tFamilyGroup));

      final result = await usecase();

      expect(result, const Right(tFamilyGroup));
      verify(() => mockFamilyRepository.getMyGroup()).called(1);
    });

    test(
      '2) GetMyFamilyGroupSummaryUsecase returns repository summary',
      () async {
        final usecase = GetMyFamilyGroupSummaryUsecase(
          repository: mockFamilyRepository,
        );
        when(
          () => mockFamilyRepository.getMyGroupSummary(),
        ).thenAnswer((_) async => const Right(tFamilySummary));

        final result = await usecase();

        expect(result, const Right(tFamilySummary));
        verify(() => mockFamilyRepository.getMyGroupSummary()).called(1);
      },
    );

    test(
      '3) CreateFamilyGroupUsecase forwards payload to repository',
      () async {
        final usecase = CreateFamilyGroupUsecase(
          repository: mockFamilyRepository,
        );
        final payload = {'name': 'New Family'};
        when(
          () => mockFamilyRepository.createGroup(payload),
        ).thenAnswer((_) async => const Right(tFamilyGroup));

        final result = await usecase(CreateFamilyGroupParams(payload: payload));

        expect(result, const Right(tFamilyGroup));
        verify(() => mockFamilyRepository.createGroup(payload)).called(1);
      },
    );

    test('4) CreateFamilyInviteUsecase forwards groupId and payload', () async {
      final usecase = CreateFamilyInviteUsecase(
        repository: mockFamilyRepository,
      );
      final payload = {'expiresInHours': 24};
      when(
        () => mockFamilyRepository.createInvite('group-1', payload),
      ).thenAnswer((_) async => const Right(tFamilyInvite));

      final result = await usecase(
        CreateFamilyInviteParams(groupId: 'group-1', payload: payload),
      );

      expect(result, const Right(tFamilyInvite));
      verify(
        () => mockFamilyRepository.createInvite('group-1', payload),
      ).called(1);
    });

    test('5) AddFamilyMemberUsecase forwards groupId and payload', () async {
      final usecase = AddFamilyMemberUsecase(repository: mockFamilyRepository);
      final payload = {'email': 'member@example.com'};
      when(
        () => mockFamilyRepository.addMember('group-1', payload),
      ).thenAnswer((_) async => const Right(tFamilyGroup));

      final result = await usecase(
        AddFamilyMemberParams(groupId: 'group-1', payload: payload),
      );

      expect(result, const Right(tFamilyGroup));
      verify(
        () => mockFamilyRepository.addMember('group-1', payload),
      ).called(1);
    });

    test(
      '6) UpdateFamilyMemberRelationUsecase forwards group/member/payload',
      () async {
        final usecase = UpdateFamilyMemberRelationUsecase(
          repository: mockFamilyRepository,
        );
        final payload = {'relation': 'brother'};
        when(
          () => mockFamilyRepository.updateMemberRelation(
            'group-1',
            'member-1',
            payload,
          ),
        ).thenAnswer((_) async => const Right(tFamilyGroup));

        final result = await usecase(
          UpdateFamilyMemberRelationParams(
            groupId: 'group-1',
            memberId: 'member-1',
            payload: payload,
          ),
        );

        expect(result, const Right(tFamilyGroup));
        verify(
          () => mockFamilyRepository.updateMemberRelation(
            'group-1',
            'member-1',
            payload,
          ),
        ).called(1);
      },
    );

    test('7) JoinFamilyInviteUsecase forwards token and payload', () async {
      final usecase = JoinFamilyInviteUsecase(repository: mockFamilyRepository);
      final payload = {'displayName': 'User 1'};
      when(
        () => mockFamilyRepository.joinWithInvite('token-abc', payload),
      ).thenAnswer((_) async => const Right(tFamilyGroup));

      final result = await usecase(
        JoinFamilyInviteParams(token: 'token-abc', payload: payload),
      );

      expect(result, const Right(tFamilyGroup));
      verify(
        () => mockFamilyRepository.joinWithInvite('token-abc', payload),
      ).called(1);
    });

    test('8) GetProfileUserUsecase forwards id and returns user', () async {
      final usecase = GetProfileUserUsecase(repository: mockProfileRepository);
      when(
        () => mockProfileRepository.getUserById('user-1'),
      ).thenAnswer((_) async => const Right(tProfileUser));

      final result = await usecase(const GetProfileUserParams(id: 'user-1'));

      expect(result, const Right(tProfileUser));
      verify(() => mockProfileRepository.getUserById('user-1')).called(1);
    });

    test(
      '9) GetProfilePaymentStatusUsecase returns failure from repository',
      () async {
        final usecase = GetProfilePaymentStatusUsecase(
          repository: mockProfileRepository,
        );
        when(
          () => mockProfileRepository.getPaymentStatus(),
        ).thenAnswer((_) async => const Left(tFailure));

        final result = await usecase();

        expect(result, const Left(tFailure));
        verify(() => mockProfileRepository.getPaymentStatus()).called(1);
      },
    );

    test(
      '10) GetAnalyticsSummaryUsecase forwards months to repository',
      () async {
        final usecase = GetAnalyticsSummaryUsecase(
          repository: mockAnalyticsRepository,
        );
        when(
          () => mockAnalyticsRepository.getSummary(months: 6),
        ).thenAnswer((_) async => const Right(tAnalyticsSummary));

        final result = await usecase(
          const GetAnalyticsSummaryParams(months: 6),
        );

        expect(result, const Right(tAnalyticsSummary));
        verify(() => mockAnalyticsRepository.getSummary(months: 6)).called(1);
      },
    );
  });
}
