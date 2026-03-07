import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';
import 'package:vaidya/features/vitals/domain/usecases/create_vital_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/delete_vital_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/get_vitals_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/update_vital_usecase.dart';
import 'package:vaidya/features/vitals/presentation/state/vitals_state.dart';
import 'package:vaidya/features/vitals/presentation/view_model/vitals_viewmodel.dart';

class MockGetVitalsUsecase extends Mock implements GetVitalsUsecase {}

class MockGetVitalsSummaryUsecase extends Mock
    implements GetVitalsSummaryUsecase {}

class MockCreateVitalUsecase extends Mock implements CreateVitalUsecase {}

class MockUpdateVitalUsecase extends Mock implements UpdateVitalUsecase {}

class MockDeleteVitalUsecase extends Mock implements DeleteVitalUsecase {}

void main() {
  late MockGetVitalsUsecase mockGetVitalsUsecase;
  late MockGetVitalsSummaryUsecase mockGetVitalsSummaryUsecase;
  late MockCreateVitalUsecase mockCreateVitalUsecase;
  late MockUpdateVitalUsecase mockUpdateVitalUsecase;
  late MockDeleteVitalUsecase mockDeleteVitalUsecase;
  late ProviderContainer container;

  const tVital = VitalEntity(
    id: 'vital-1',
    data: {'heartRate': 82, 'bloodSugar': 118},
  );
  const tSummary = VitalsSummaryEntity(data: {'avgHeartRate': 79});

  setUpAll(() {
    registerFallbackValue(
      const UpdateVitalParams(id: 'fallback', payload: <String, dynamic>{}),
    );
    registerFallbackValue(const DeleteVitalParams(id: 'fallback'));
  });

  setUp(() {
    mockGetVitalsUsecase = MockGetVitalsUsecase();
    mockGetVitalsSummaryUsecase = MockGetVitalsSummaryUsecase();
    mockCreateVitalUsecase = MockCreateVitalUsecase();
    mockUpdateVitalUsecase = MockUpdateVitalUsecase();
    mockDeleteVitalUsecase = MockDeleteVitalUsecase();

    container = ProviderContainer(
      overrides: [
        getVitalsUsecaseProvider.overrideWith((ref) => mockGetVitalsUsecase),
        getVitalsSummaryUsecaseProvider.overrideWith(
          (ref) => mockGetVitalsSummaryUsecase,
        ),
        createVitalUsecaseProvider.overrideWith(
          (ref) => mockCreateVitalUsecase,
        ),
        updateVitalUsecaseProvider.overrideWith(
          (ref) => mockUpdateVitalUsecase,
        ),
        deleteVitalUsecaseProvider.overrideWith(
          (ref) => mockDeleteVitalUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('VitalsViewModel', () {
    test('1) build initializes default state', () {
      final state = container.read(vitalsViewModelProvider);

      expect(state.status, VitalsStatus.initial);
      expect(state.items, isEmpty);
      expect(state.summary, const VitalsSummaryEntity());
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.actionMessage, isNull);
    });

    test('2) load sets loaded state with items and summary', () async {
      when(
        () => mockGetVitalsUsecase(),
      ).thenAnswer((_) async => const Right([tVital]));
      when(
        () => mockGetVitalsSummaryUsecase(),
      ).thenAnswer((_) async => const Right(tSummary));

      await container.read(vitalsViewModelProvider.notifier).load();
      final state = container.read(vitalsViewModelProvider);

      expect(state.status, VitalsStatus.loaded);
      expect(state.items, const [tVital]);
      expect(state.summary, tSummary);
      verify(() => mockGetVitalsUsecase()).called(1);
      verify(() => mockGetVitalsSummaryUsecase()).called(1);
    });

    test('3) load sets error when items fetch fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch vitals');
      when(
        () => mockGetVitalsUsecase(),
      ).thenAnswer((_) async => const Left(failure));
      when(
        () => mockGetVitalsSummaryUsecase(),
      ).thenAnswer((_) async => const Right(tSummary));

      await container.read(vitalsViewModelProvider.notifier).load();
      final state = container.read(vitalsViewModelProvider);

      expect(state.status, VitalsStatus.error);
      expect(state.errorMessage, 'Failed to fetch vitals');
      expect(state.items, isEmpty);
    });

    test('4) update success reloads list and sets action message', () async {
      when(
        () => mockUpdateVitalUsecase(any()),
      ).thenAnswer((_) async => const Right(tVital));
      when(
        () => mockGetVitalsUsecase(),
      ).thenAnswer((_) async => const Right([tVital]));
      when(
        () => mockGetVitalsSummaryUsecase(),
      ).thenAnswer((_) async => const Right(tSummary));

      final result = await container
          .read(vitalsViewModelProvider.notifier)
          .update('vital-1', {'heartRate': 76});
      final state = container.read(vitalsViewModelProvider);

      expect(result, isTrue);
      expect(state.status, VitalsStatus.loaded);
      expect(state.actionMessage, 'Updated successfully');
      expect(state.isSubmitting, isFalse);
      verify(
        () => mockUpdateVitalUsecase(
          const UpdateVitalParams(id: 'vital-1', payload: {'heartRate': 76}),
        ),
      ).called(1);
    });

    test('5) create failure returns false and sets error message', () async {
      const failure = ApiFailure(message: 'Create failed');
      when(
        () => mockCreateVitalUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await container
          .read(vitalsViewModelProvider.notifier)
          .create({'heartRate': 84});
      final state = container.read(vitalsViewModelProvider);

      expect(result, isFalse);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, 'Create failed');
      expect(state.actionMessage, isNull);
    });
  });
}
