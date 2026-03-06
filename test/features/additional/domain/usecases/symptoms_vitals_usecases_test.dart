import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:vaidya/features/symptoms/domain/repositories/symptoms_repository.dart';
import 'package:vaidya/features/symptoms/domain/usecases/create_symptom_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/delete_symptom_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/get_symptoms_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/update_symptom_usecase.dart';
import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';
import 'package:vaidya/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:vaidya/features/vitals/domain/usecases/create_vital_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/delete_vital_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/get_vitals_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/update_vital_usecase.dart';

class MockSymptomsRepository extends Mock implements ISymptomsRepository {}

class MockVitalsRepository extends Mock implements IVitalsRepository {}

void main() {
  late MockSymptomsRepository mockSymptomsRepository;
  late MockVitalsRepository mockVitalsRepository;

  const tSymptom = SymptomEntity(
    id: 'sym-1',
    data: {'name': 'Headache', 'severity': 'mild'},
  );
  const tSymptomsSummary = SymptomsSummaryEntity(
    data: {'total': 3, 'active': 1},
  );
  const tVital = VitalEntity(
    id: 'vital-1',
    data: {'heartRate': 80, 'bp': '110/78'},
  );
  const tVitalsSummary = VitalsSummaryEntity(
    data: {'avgHeartRate': 79, 'latestBp': '110/78'},
  );

  setUp(() {
    mockSymptomsRepository = MockSymptomsRepository();
    mockVitalsRepository = MockVitalsRepository();
  });

  group('Symptoms and Vitals Usecase Unit Tests', () {
    test('1) GetSymptomsUsecase returns repository symptoms list', () async {
      final usecase = GetSymptomsUsecase(repository: mockSymptomsRepository);
      when(
        () => mockSymptomsRepository.getSymptoms(),
      ).thenAnswer((_) async => const Right([tSymptom]));

      final result = await usecase();

      expect(result, const Right([tSymptom]));
      verify(() => mockSymptomsRepository.getSymptoms()).called(1);
    });

    test('2) GetSymptomsSummaryUsecase returns repository summary', () async {
      final usecase = GetSymptomsSummaryUsecase(
        repository: mockSymptomsRepository,
      );
      when(
        () => mockSymptomsRepository.getSymptomsSummary(),
      ).thenAnswer((_) async => const Right(tSymptomsSummary));

      final result = await usecase();

      expect(result, const Right(tSymptomsSummary));
      verify(() => mockSymptomsRepository.getSymptomsSummary()).called(1);
    });

    test('3) CreateSymptomUsecase forwards payload to repository', () async {
      final usecase = CreateSymptomUsecase(repository: mockSymptomsRepository);
      const payload = {'name': 'Cough', 'severity': 'moderate'};
      when(
        () => mockSymptomsRepository.createSymptom(payload),
      ).thenAnswer((_) async => const Right(tSymptom));

      final result = await usecase(payload);

      expect(result, const Right(tSymptom));
      verify(() => mockSymptomsRepository.createSymptom(payload)).called(1);
    });

    test('4) UpdateSymptomUsecase forwards id and payload', () async {
      final usecase = UpdateSymptomUsecase(repository: mockSymptomsRepository);
      const params = UpdateSymptomParams(
        id: 'sym-1',
        payload: {'severity': 'severe'},
      );
      when(
        () => mockSymptomsRepository.updateSymptom('sym-1', {
          'severity': 'severe',
        }),
      ).thenAnswer((_) async => const Right(tSymptom));

      final result = await usecase(params);

      expect(result, const Right(tSymptom));
      verify(
        () => mockSymptomsRepository.updateSymptom('sym-1', {
          'severity': 'severe',
        }),
      ).called(1);
    });

    test('5) DeleteSymptomUsecase forwards id to repository', () async {
      final usecase = DeleteSymptomUsecase(repository: mockSymptomsRepository);
      const params = DeleteSymptomParams(id: 'sym-1');
      when(
        () => mockSymptomsRepository.deleteSymptom('sym-1'),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(params);

      expect(result, const Right(true));
      verify(() => mockSymptomsRepository.deleteSymptom('sym-1')).called(1);
    });

    test('6) GetVitalsUsecase returns repository vitals list', () async {
      final usecase = GetVitalsUsecase(repository: mockVitalsRepository);
      when(
        () => mockVitalsRepository.getVitals(),
      ).thenAnswer((_) async => const Right([tVital]));

      final result = await usecase();

      expect(result, const Right([tVital]));
      verify(() => mockVitalsRepository.getVitals()).called(1);
    });

    test('7) GetVitalsSummaryUsecase returns repository summary', () async {
      final usecase = GetVitalsSummaryUsecase(repository: mockVitalsRepository);
      when(
        () => mockVitalsRepository.getVitalsSummary(),
      ).thenAnswer((_) async => const Right(tVitalsSummary));

      final result = await usecase();

      expect(result, const Right(tVitalsSummary));
      verify(() => mockVitalsRepository.getVitalsSummary()).called(1);
    });

    test('8) CreateVitalUsecase forwards payload to repository', () async {
      final usecase = CreateVitalUsecase(repository: mockVitalsRepository);
      const payload = {'heartRate': 82, 'bloodSugar': 118};
      when(
        () => mockVitalsRepository.createVital(payload),
      ).thenAnswer((_) async => const Right(tVital));

      final result = await usecase(payload);

      expect(result, const Right(tVital));
      verify(() => mockVitalsRepository.createVital(payload)).called(1);
    });

    test('9) UpdateVitalUsecase forwards id and payload', () async {
      final usecase = UpdateVitalUsecase(repository: mockVitalsRepository);
      const params = UpdateVitalParams(
        id: 'vital-1',
        payload: {'heartRate': 76},
      );
      when(
        () => mockVitalsRepository.updateVital('vital-1', {'heartRate': 76}),
      ).thenAnswer((_) async => const Right(tVital));

      final result = await usecase(params);

      expect(result, const Right(tVital));
      verify(
        () => mockVitalsRepository.updateVital('vital-1', {'heartRate': 76}),
      ).called(1);
    });

    test('10) DeleteVitalUsecase forwards id to repository', () async {
      final usecase = DeleteVitalUsecase(repository: mockVitalsRepository);
      const params = DeleteVitalParams(id: 'vital-1');
      when(
        () => mockVitalsRepository.deleteVital('vital-1'),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(params);

      expect(result, const Right(true));
      verify(() => mockVitalsRepository.deleteVital('vital-1')).called(1);
    });
  });
}
