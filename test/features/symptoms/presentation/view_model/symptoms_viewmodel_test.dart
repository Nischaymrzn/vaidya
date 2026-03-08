import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:vaidya/features/symptoms/domain/usecases/create_symptom_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/delete_symptom_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/get_symptoms_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/update_symptom_usecase.dart';
import 'package:vaidya/features/symptoms/presentation/state/symptoms_state.dart';
import 'package:vaidya/features/symptoms/presentation/view_model/symptoms_viewmodel.dart';

class MockGetSymptomsUsecase extends Mock implements GetSymptomsUsecase {}

class MockGetSymptomsSummaryUsecase extends Mock
    implements GetSymptomsSummaryUsecase {}

class MockCreateSymptomUsecase extends Mock implements CreateSymptomUsecase {}

class MockUpdateSymptomUsecase extends Mock implements UpdateSymptomUsecase {}

class MockDeleteSymptomUsecase extends Mock implements DeleteSymptomUsecase {}

void main() {
  late MockGetSymptomsUsecase mockGetSymptomsUsecase;
  late MockGetSymptomsSummaryUsecase mockGetSymptomsSummaryUsecase;
  late MockCreateSymptomUsecase mockCreateSymptomUsecase;
  late MockUpdateSymptomUsecase mockUpdateSymptomUsecase;
  late MockDeleteSymptomUsecase mockDeleteSymptomUsecase;
  late ProviderContainer container;

  const tSymptom = SymptomEntity(id: 'sym-1', data: {'name': 'Headache'});
  const tSummary = SymptomsSummaryEntity(data: {'total': 4, 'ongoing': 2});

  setUpAll(() {
    registerFallbackValue(
      const UpdateSymptomParams(id: 'fallback', payload: <String, dynamic>{}),
    );
    registerFallbackValue(const DeleteSymptomParams(id: 'fallback'));
  });

  setUp(() {
    mockGetSymptomsUsecase = MockGetSymptomsUsecase();
    mockGetSymptomsSummaryUsecase = MockGetSymptomsSummaryUsecase();
    mockCreateSymptomUsecase = MockCreateSymptomUsecase();
    mockUpdateSymptomUsecase = MockUpdateSymptomUsecase();
    mockDeleteSymptomUsecase = MockDeleteSymptomUsecase();

    container = ProviderContainer(
      overrides: [
        getSymptomsUsecaseProvider.overrideWith(
          (ref) => mockGetSymptomsUsecase,
        ),
        getSymptomsSummaryUsecaseProvider.overrideWith(
          (ref) => mockGetSymptomsSummaryUsecase,
        ),
        createSymptomUsecaseProvider.overrideWith(
          (ref) => mockCreateSymptomUsecase,
        ),
        updateSymptomUsecaseProvider.overrideWith(
          (ref) => mockUpdateSymptomUsecase,
        ),
        deleteSymptomUsecaseProvider.overrideWith(
          (ref) => mockDeleteSymptomUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SymptomsViewModel', () {
    test('1) build initializes default state', () {
      final state = container.read(symptomsViewModelProvider);

      expect(state.status, SymptomsStatus.initial);
      expect(state.items, isEmpty);
      expect(state.summary, const SymptomsSummaryEntity());
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.actionMessage, isNull);
    });

    test('2) load sets loaded state with items and summary', () async {
      when(
        () => mockGetSymptomsUsecase(),
      ).thenAnswer((_) async => const Right([tSymptom]));
      when(
        () => mockGetSymptomsSummaryUsecase(),
      ).thenAnswer((_) async => const Right(tSummary));

      await container.read(symptomsViewModelProvider.notifier).load();
      final state = container.read(symptomsViewModelProvider);

      expect(state.status, SymptomsStatus.loaded);
      expect(state.items, const [tSymptom]);
      expect(state.summary, tSummary);
      verify(() => mockGetSymptomsUsecase()).called(1);
      verify(() => mockGetSymptomsSummaryUsecase()).called(1);
    });

    test('3) load sets error when items fetch fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch symptoms');
      when(
        () => mockGetSymptomsUsecase(),
      ).thenAnswer((_) async => const Left(failure));
      when(
        () => mockGetSymptomsSummaryUsecase(),
      ).thenAnswer((_) async => const Right(tSummary));

      await container.read(symptomsViewModelProvider.notifier).load();
      final state = container.read(symptomsViewModelProvider);

      expect(state.status, SymptomsStatus.error);
      expect(state.errorMessage, 'Failed to fetch symptoms');
      expect(state.items, isEmpty);
    });

    test('4) create success reloads list and sets action message', () async {
      when(
        () => mockCreateSymptomUsecase(any()),
      ).thenAnswer((_) async => const Right(tSymptom));
      when(
        () => mockGetSymptomsUsecase(),
      ).thenAnswer((_) async => const Right([tSymptom]));
      when(
        () => mockGetSymptomsSummaryUsecase(),
      ).thenAnswer((_) async => const Right(tSummary));

      final result = await container
          .read(symptomsViewModelProvider.notifier)
          .create({'name': 'Headache'});
      final state = container.read(symptomsViewModelProvider);

      expect(result, isTrue);
      expect(state.status, SymptomsStatus.loaded);
      expect(state.actionMessage, 'Created successfully');
      expect(state.isSubmitting, isFalse);
      verify(() => mockCreateSymptomUsecase({'name': 'Headache'})).called(1);
    });

    test('5) remove failure returns false and sets error message', () async {
      const failure = ApiFailure(message: 'Delete failed');
      when(
        () => mockDeleteSymptomUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await container
          .read(symptomsViewModelProvider.notifier)
          .remove('sym-1');
      final state = container.read(symptomsViewModelProvider);

      expect(result, isFalse);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, 'Delete failed');
      expect(state.actionMessage, isNull);
    });
  });
}
