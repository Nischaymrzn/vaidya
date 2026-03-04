import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/usecases/create_medical_record_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/delete_medical_record_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/get_medical_record_by_id_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/get_medical_records_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/scan_medical_image_usecase.dart';
import 'package:vaidya/features/records/domain/usecases/update_medical_record_usecase.dart';
import 'package:vaidya/features/records/presentation/state/records_state.dart';

final recordsViewModelProvider =
    NotifierProvider<RecordsViewModel, RecordsState>(RecordsViewModel.new);

class RecordsViewModel extends Notifier<RecordsState> {
  late final GetMedicalRecordsUsecase _getMedicalRecordsUsecase;
  late final GetMedicalRecordByIdUsecase _getMedicalRecordByIdUsecase;
  late final CreateMedicalRecordUsecase _createMedicalRecordUsecase;
  late final UpdateMedicalRecordUsecase _updateMedicalRecordUsecase;
  late final DeleteMedicalRecordUsecase _deleteMedicalRecordUsecase;
  late final ScanMedicalImageUsecase _scanMedicalImageUsecase;

  @override
  RecordsState build() {
    _getMedicalRecordsUsecase = ref.read(getMedicalRecordsUsecaseProvider);
    _getMedicalRecordByIdUsecase = ref.read(
      getMedicalRecordByIdUsecaseProvider,
    );
    _createMedicalRecordUsecase = ref.read(createMedicalRecordUsecaseProvider);
    _updateMedicalRecordUsecase = ref.read(updateMedicalRecordUsecaseProvider);
    _deleteMedicalRecordUsecase = ref.read(deleteMedicalRecordUsecaseProvider);
    _scanMedicalImageUsecase = ref.read(scanMedicalImageUsecaseProvider);
    return const RecordsState();
  }

  Future<void> loadRecords({int? page, bool forceLoading = false}) async {
    final targetPage = page ?? state.page;
    final shouldLoad =
        forceLoading ||
        state.status == RecordsStatus.initial ||
        state.records.isEmpty;

    state = state.copyWith(
      status: shouldLoad ? RecordsStatus.loading : RecordsStatus.loaded,
      page: targetPage,
      clearError: true,
    );

    final result = await _getMedicalRecordsUsecase(
      GetMedicalRecordsParams(page: targetPage, limit: state.limit),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: RecordsStatus.error,
          errorMessage: failure.message,
        );
      },
      (data) {
        state = state.copyWith(
          status: RecordsStatus.loaded,
          records: data.records,
          pagination: data.pagination,
          page: data.pagination.page,
          clearError: true,
        );
      },
    );
  }

  Future<void> getRecordById(String id) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _getMedicalRecordByIdUsecase(
      GetMedicalRecordByIdParams(id: id),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (record) => state = state.copyWith(
        isSubmitting: false,
        selectedRecord: record,
        clearError: true,
      ),
    );
  }

  Future<bool> createRecord(MedicalRecordUpsertEntity payload) async {
    // Primary write flow: persist all typed health data through medical-record API.
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _createMedicalRecordUsecase(payload);
    bool success = false;
    String? failureMessage;

    result.fold(
      (failure) => failureMessage = failure.message,
      (_) => success = true,
    );

    if (!success) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: failureMessage ?? 'Failed to create record',
      );
      return false;
    }

    await loadRecords(page: 1, forceLoading: true);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Record added successfully.',
      clearError: true,
    );
    return true;
  }

  Future<bool> updateRecord(
    String id,
    MedicalRecordUpsertEntity payload,
  ) async {
    // Primary write flow: update medical-record and let server sync linked items.
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _updateMedicalRecordUsecase(
      UpdateMedicalRecordParams(id: id, payload: payload),
    );

    bool success = false;
    String? failureMessage;
    result.fold(
      (failure) => failureMessage = failure.message,
      (_) => success = true,
    );

    if (!success) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: failureMessage ?? 'Failed to update record',
      );
      return false;
    }

    await loadRecords(page: state.page, forceLoading: true);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Record updated successfully.',
      clearError: true,
    );
    return true;
  }

  Future<bool> deleteRecord(String id) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _deleteMedicalRecordUsecase(
      DeleteMedicalRecordParams(id: id),
    );

    bool success = false;
    String? failureMessage;
    result.fold(
      (failure) => failureMessage = failure.message,
      (_) => success = true,
    );

    if (!success) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: failureMessage ?? 'Failed to delete record',
      );
      return false;
    }

    await loadRecords(page: state.page, forceLoading: true);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Record deleted successfully.',
      clearError: true,
    );
    return true;
  }

  Future<AiScanResultEntity?> scanImage(String imagePath) async {
    state = state.copyWith(
      isScanning: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _scanMedicalImageUsecase(
      ScanMedicalImageParams(imagePath: imagePath),
    );

    AiScanResultEntity? data;
    String? failureMessage;
    result.fold(
      (failure) => failureMessage = failure.message,
      (scan) => data = scan,
    );

    if (data == null) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: failureMessage ?? 'Failed to scan document',
      );
      return null;
    }

    state = state.copyWith(
      isScanning: false,
      actionMessage: 'Scan completed. Review details before saving.',
      clearError: true,
    );
    return data;
  }

  void setActiveTab(RecordsTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setSearchTerm(String value) {
    state = state.copyWith(searchTerm: value, documentsPage: 1);
  }

  void setSortBy(String value) {
    state = state.copyWith(sortBy: value);
  }

  void setCategoryFilter(String value) {
    state = state.copyWith(categoryFilter: value);
  }

  void setStatusFilter(String value) {
    state = state.copyWith(statusFilter: value);
  }

  void setProviderFilter(String value) {
    state = state.copyWith(providerFilter: value);
  }

  void setDateFilter(String value) {
    state = state.copyWith(dateFilter: value);
  }

  void clearMessages() {
    state = state.copyWith(
      clearError: true,
      clearActionMessage: true,
      clearSelectedRecord: true,
    );
  }

  void setDocumentsPage(int page) {
    if (page < 1) return;
    state = state.copyWith(documentsPage: page);
  }
}
