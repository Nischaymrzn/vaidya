import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/records/data/datasources/records_datasource.dart';
import 'package:vaidya/features/records/data/models/medical_record_api_model.dart';
import 'package:vaidya/features/records/data/models/medical_record_hive_model.dart';
import 'package:vaidya/features/records/data/models/record_support_api_model.dart';

final recordsLocalDataSourceProvider = Provider<IRecordsLocalDataSource>((ref) {
  return RecordsLocalDataSource(
    saveService: ref.read(featureCacheServiceProvider),
  );
});

class RecordsLocalDataSource implements IRecordsLocalDataSource {
  final FeatureCacheService _cacheService;

  const RecordsLocalDataSource({required FeatureCacheService saveService})
    : _cacheService = saveService;

  static const String _medicalRecordsKey = 'records_medical_records';
  static const String _medicationsKey = 'records_medications';
  static const String _allergiesKey = 'records_allergies';
  static const String _immunizationsKey = 'records_immunizations';
  static const String _pendingMedicalRecordOpsKey =
      'records_pending_medical_record_ops';

  @override
  Future<void> saveMedicalRecords(MedicalRecordsResultApiModel result) {
    final hiveModel = MedicalRecordsResultHiveModel.fromApiModel(result);
    return _cacheService.writeMap(
      _medicalRecordsKey,
      hiveModel.toResponseJson(),
    );
  }

  @override
  Future<MedicalRecordsResultApiModel?> getMedicalRecords() async {
    final cached = await _cacheService.readMap(_medicalRecordsKey);
    if (cached == null) return null;
    final hiveModel = MedicalRecordsResultHiveModel.fromResponse(cached);
    return hiveModel.toApiModel();
  }

  @override
  Future<MedicalRecordApiModel?> getMedicalRecordById(String id) async {
    final cached = await getMedicalRecords();
    if (cached == null) return null;

    for (final record in cached.records) {
      if (_sameId(record.id, id)) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<MedicalRecordApiModel> upsertMedicalRecord(
    MedicalRecordApiModel record,
  ) async {
    final cached = await getMedicalRecords() ?? _emptyMedicalRecordsResult();
    final updatedRecords = List<MedicalRecordApiModel>.from(cached.records);
    final index = updatedRecords.indexWhere(
      (item) => _sameId(item.id, record.id),
    );

    if (index >= 0) {
      updatedRecords[index] = record;
    } else {
      updatedRecords.insert(0, record);
    }

    final updated = MedicalRecordsResultApiModel(
      records: updatedRecords,
      pagination: _recalculatePagination(
        cached.pagination,
        updatedRecords.length,
      ),
    );
    await saveMedicalRecords(updated);
    return record;
  }

  @override
  Future<bool> removeMedicalRecordById(String id) async {
    final cached = await getMedicalRecords();
    if (cached == null) return false;

    final beforeCount = cached.records.length;
    final updatedRecords = cached.records
        .where((item) => !_sameId(item.id, id))
        .toList(growable: false);
    if (beforeCount == updatedRecords.length) {
      return false;
    }

    final updated = MedicalRecordsResultApiModel(
      records: updatedRecords,
      pagination: _recalculatePagination(
        cached.pagination,
        updatedRecords.length,
      ),
    );
    await saveMedicalRecords(updated);
    return true;
  }

  @override
  Future<void> saveMedications(List<MedicationApiModel> medications) {
    return _cacheService.writeList(
      _medicationsKey,
      medications.map((item) => item.toJson()).toList(growable: false),
    );
  }

  @override
  Future<List<MedicationApiModel>> getMedications() async {
    final cached = await _cacheService.readList(_medicationsKey);
    return cached.map(MedicationApiModel.fromJson).toList(growable: false);
  }

  @override
  Future<MedicationApiModel?> getMedicationById(String id) async {
    final cached = await getMedications();
    for (final medication in cached) {
      if (_sameId(medication.id, id)) {
        return medication;
      }
    }
    return null;
  }

  @override
  Future<MedicationApiModel> upsertMedication(
    MedicationApiModel medication,
  ) async {
    final cached = await getMedications();
    final updated = List<MedicationApiModel>.from(cached);
    final index = updated.indexWhere((item) => _sameId(item.id, medication.id));

    if (index >= 0) {
      updated[index] = medication;
    } else {
      updated.insert(0, medication);
    }

    await saveMedications(updated);
    return medication;
  }

  @override
  Future<bool> removeMedicationById(String id) async {
    final cached = await getMedications();
    final updated = cached
        .where((item) => !_sameId(item.id, id))
        .toList(growable: false);
    if (updated.length == cached.length) {
      return false;
    }
    await saveMedications(updated);
    return true;
  }

  @override
  Future<void> saveAllergies(List<AllergyApiModel> allergies) {
    return _cacheService.writeList(
      _allergiesKey,
      allergies.map((item) => item.toJson()).toList(growable: false),
    );
  }

  @override
  Future<List<AllergyApiModel>> getAllergies() async {
    final cached = await _cacheService.readList(_allergiesKey);
    return cached.map(AllergyApiModel.fromJson).toList(growable: false);
  }

  @override
  Future<AllergyApiModel?> getAllergyById(String id) async {
    final cached = await getAllergies();
    for (final allergy in cached) {
      if (_sameId(allergy.id, id)) {
        return allergy;
      }
    }
    return null;
  }

  @override
  Future<AllergyApiModel> upsertAllergy(AllergyApiModel allergy) async {
    final cached = await getAllergies();
    final updated = List<AllergyApiModel>.from(cached);
    final index = updated.indexWhere((item) => _sameId(item.id, allergy.id));

    if (index >= 0) {
      updated[index] = allergy;
    } else {
      updated.insert(0, allergy);
    }

    await saveAllergies(updated);
    return allergy;
  }

  @override
  Future<bool> removeAllergyById(String id) async {
    final cached = await getAllergies();
    final updated = cached
        .where((item) => !_sameId(item.id, id))
        .toList(growable: false);
    if (updated.length == cached.length) {
      return false;
    }
    await saveAllergies(updated);
    return true;
  }

  @override
  Future<void> saveImmunizations(List<ImmunizationApiModel> immunizations) {
    return _cacheService.writeList(
      _immunizationsKey,
      immunizations.map((item) => item.toJson()).toList(growable: false),
    );
  }

  @override
  Future<List<ImmunizationApiModel>> getImmunizations() async {
    final cached = await _cacheService.readList(_immunizationsKey);
    return cached.map(ImmunizationApiModel.fromJson).toList(growable: false);
  }

  @override
  Future<ImmunizationApiModel?> getImmunizationById(String id) async {
    final cached = await getImmunizations();
    for (final immunization in cached) {
      if (_sameId(immunization.id, id)) {
        return immunization;
      }
    }
    return null;
  }

  @override
  Future<ImmunizationApiModel> upsertImmunization(
    ImmunizationApiModel immunization,
  ) async {
    final cached = await getImmunizations();
    final updated = List<ImmunizationApiModel>.from(cached);
    final index = updated.indexWhere(
      (item) => _sameId(item.id, immunization.id),
    );

    if (index >= 0) {
      updated[index] = immunization;
    } else {
      updated.insert(0, immunization);
    }

    await saveImmunizations(updated);
    return immunization;
  }

  @override
  Future<bool> removeImmunizationById(String id) async {
    final cached = await getImmunizations();
    final updated = cached
        .where((item) => !_sameId(item.id, id))
        .toList(growable: false);
    if (updated.length == cached.length) {
      return false;
    }
    await saveImmunizations(updated);
    return true;
  }

  @override
  Future<void> enqueuePendingMedicalRecordOperation(
    Map<String, dynamic> operation,
  ) async {
    final operations = List<Map<String, dynamic>>.from(
      await getPendingMedicalRecordOperations(),
    );
    operations.add(Map<String, dynamic>.from(operation));
    await savePendingMedicalRecordOperations(operations);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingMedicalRecordOperations() async {
    final cached = await _cacheService.readList(_pendingMedicalRecordOpsKey);
    return cached
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: true);
  }

  @override
  Future<void> savePendingMedicalRecordOperations(
    List<Map<String, dynamic>> operations,
  ) {
    return _cacheService.writeList(_pendingMedicalRecordOpsKey, operations);
  }

  @override
  Future<void> clearPendingMedicalRecordOperations() {
    return _cacheService.remove(_pendingMedicalRecordOpsKey);
  }

  bool _sameId(String lhs, String rhs) {
    return lhs.trim() == rhs.trim();
  }

  MedicalRecordsResultApiModel _emptyMedicalRecordsResult() {
    return MedicalRecordsResultApiModel(
      records: const <MedicalRecordApiModel>[],
      pagination: MedicalRecordsPaginationApiModel(
        total: 0,
        page: 1,
        limit: 20,
        totalPages: 1,
        hasNext: false,
        hasPrev: false,
      ),
    );
  }

  MedicalRecordsPaginationApiModel _recalculatePagination(
    MedicalRecordsPaginationApiModel current,
    int total,
  ) {
    final limit = current.limit <= 0 ? 20 : current.limit;
    final page = current.page <= 0 ? 1 : current.page;
    final totalPages = total == 0 ? 1 : (total / limit).ceil();
    return MedicalRecordsPaginationApiModel(
      total: total,
      page: page > totalPages ? totalPages : page,
      limit: limit,
      totalPages: totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1,
    );
  }
}
