import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/usecases/create_medical_record_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/delete_medical_record_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/get_allergies_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/get_immunizations_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/get_medical_record_by_id_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/get_medical_records_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/get_medication_by_id_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/get_medications_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/scan_medical_image_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/update_medical_record_usecase.dart';

class MockRecordsRepository extends Mock implements IRecordsRepository {}

void main() {
  late MockRecordsRepository mockRecordsRepository;

  const tRecord = MedicalRecordEntity(
    id: 'rec-1',
    userId: 'user-1',
    title: 'Blood Test',
    aiScanned: false,
    attachments: [],
  );
  const tPagination = MedicalRecordsPaginationEntity(
    total: 1,
    page: 1,
    limit: 20,
    totalPages: 1,
    hasNext: false,
    hasPrev: false,
  );
  const tRecordsResult = MedicalRecordsResultEntity(
    records: [tRecord],
    pagination: tPagination,
  );
  const tUpsert = MedicalRecordUpsertEntity(
    title: 'Updated Blood Test',
    category: 'lab',
  );
  const tScan = AiScanResultEntity(
    summary: 'Normal range detected',
    structured: {'glucose': 'normal'},
  );
  const tMedication = MedicationEntity(
    id: 'med-1',
    userId: 'user-1',
    medicineName: 'Paracetamol',
  );
  const tAllergy = AllergyEntity(
    id: 'alg-1',
    userId: 'user-1',
    allergen: 'Dust',
  );
  const tImmunization = ImmunizationEntity(
    id: 'imm-1',
    userId: 'user-1',
    vaccineName: 'Flu Shot',
  );

  setUp(() {
    mockRecordsRepository = MockRecordsRepository();
  });

  group('Records Usecase Unit Tests', () {
    test(
      '1) GetMedicalRecordsUsecase forwards page, limit and userId correctly',
      () async {
        final usecase = GetMedicalRecordsUsecase(
          recordsRepository: mockRecordsRepository,
        );
        const params = GetMedicalRecordsParams(
          page: 1,
          limit: 20,
          userId: 'user-1',
        );
        when(
          () => mockRecordsRepository.getMedicalRecords(
            page: 1,
            limit: 20,
            userId: 'user-1',
          ),
        ).thenAnswer((_) async => const Right(tRecordsResult));

        final result = await usecase(params);

        expect(result, const Right(tRecordsResult));
        verify(
          () => mockRecordsRepository.getMedicalRecords(
            page: 1,
            limit: 20,
            userId: 'user-1',
          ),
        ).called(1);
      },
    );

    test('2) GetMedicalRecordByIdUsecase forwards record id', () async {
      final usecase = GetMedicalRecordByIdUsecase(
        repository: mockRecordsRepository,
      );
      const params = GetMedicalRecordByIdParams(id: 'rec-1');
      when(
        () => mockRecordsRepository.getMedicalRecordById('rec-1'),
      ).thenAnswer((_) async => const Right(tRecord));

      final result = await usecase(params);

      expect(result, const Right(tRecord));
      verify(
        () => mockRecordsRepository.getMedicalRecordById('rec-1'),
      ).called(1);
    });

    test('3) CreateMedicalRecordUsecase forwards upsert payload', () async {
      final usecase = CreateMedicalRecordUsecase(
        recordsRepository: mockRecordsRepository,
      );
      when(
        () => mockRecordsRepository.createMedicalRecord(tUpsert),
      ).thenAnswer((_) async => const Right(tRecord));

      final result = await usecase(tUpsert);

      expect(result, const Right(tRecord));
      verify(
        () => mockRecordsRepository.createMedicalRecord(tUpsert),
      ).called(1);
    });

    test('4) UpdateMedicalRecordUsecase forwards id and payload', () async {
      final usecase = UpdateMedicalRecordUsecase(
        recordsRepository: mockRecordsRepository,
      );
      const params = UpdateMedicalRecordParams(id: 'rec-1', payload: tUpsert);
      when(
        () => mockRecordsRepository.updateMedicalRecord('rec-1', tUpsert),
      ).thenAnswer((_) async => const Right(tRecord));

      final result = await usecase(params);

      expect(result, const Right(tRecord));
      verify(
        () => mockRecordsRepository.updateMedicalRecord('rec-1', tUpsert),
      ).called(1);
    });

    test('5) DeleteMedicalRecordUsecase forwards record id', () async {
      final usecase = DeleteMedicalRecordUsecase(
        recordsRepository: mockRecordsRepository,
      );
      const params = DeleteMedicalRecordParams(id: 'rec-1');
      when(
        () => mockRecordsRepository.deleteMedicalRecord('rec-1'),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(params);

      expect(result, const Right(true));
      verify(
        () => mockRecordsRepository.deleteMedicalRecord('rec-1'),
      ).called(1);
    });

    test('6) ScanMedicalImageUsecase forwards image path', () async {
      final usecase = ScanMedicalImageUsecase(
        recordsRepository: mockRecordsRepository,
      );
      const params = ScanMedicalImageParams(imagePath: '/tmp/report.png');
      when(
        () => mockRecordsRepository.scanMedicalImage('/tmp/report.png'),
      ).thenAnswer((_) async => const Right(tScan));

      final result = await usecase(params);

      expect(result, const Right(tScan));
      verify(
        () => mockRecordsRepository.scanMedicalImage('/tmp/report.png'),
      ).called(1);
    });

    test('7) GetMedicationsUsecase forwards userId filter', () async {
      final usecase = GetMedicationsUsecase(
        recordsRepository: mockRecordsRepository,
      );
      const params = GetMedicationsParams(userId: 'user-1');
      when(
        () => mockRecordsRepository.getMedications(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([tMedication]));

      final result = await usecase(params);

      expect(result, const Right([tMedication]));
      verify(
        () => mockRecordsRepository.getMedications(userId: 'user-1'),
      ).called(1);
    });

    test('8) GetAllergiesUsecase forwards userId filter', () async {
      final usecase = GetAllergiesUsecase(
        recordsRepository: mockRecordsRepository,
      );
      const params = GetAllergiesParams(userId: 'user-1');
      when(
        () => mockRecordsRepository.getAllergies(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([tAllergy]));

      final result = await usecase(params);

      expect(result, const Right([tAllergy]));
      verify(
        () => mockRecordsRepository.getAllergies(userId: 'user-1'),
      ).called(1);
    });

    test('9) GetImmunizationsUsecase forwards userId filter', () async {
      final usecase = GetImmunizationsUsecase(
        recordsRepository: mockRecordsRepository,
      );
      const params = GetImmunizationsParams(userId: 'user-1');
      when(
        () => mockRecordsRepository.getImmunizations(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([tImmunization]));

      final result = await usecase(params);

      expect(result, const Right([tImmunization]));
      verify(
        () => mockRecordsRepository.getImmunizations(userId: 'user-1'),
      ).called(1);
    });

    test('10) GetMedicationByIdUsecase forwards medication id', () async {
      final usecase = GetMedicationByIdUsecase(
        recordsRepository: mockRecordsRepository,
      );
      const params = GetMedicationByIdParams(id: 'med-1');
      when(
        () => mockRecordsRepository.getMedicationById('med-1'),
      ).thenAnswer((_) async => const Right(tMedication));

      final result = await usecase(params);

      expect(result, const Right(tMedication));
      verify(() => mockRecordsRepository.getMedicationById('med-1')).called(1);
    });
  });
}
