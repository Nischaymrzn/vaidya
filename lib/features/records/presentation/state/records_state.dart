import 'package:equatable/equatable.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';

enum RecordsStatus { initial, loading, loaded, error }

enum RecordsTab { overview, documents }

class RecordsState extends Equatable {
  final RecordsStatus status;
  final RecordsTab activeTab;
  final List<MedicalRecordEntity> records;
  final MedicalRecordEntity? selectedRecord;
  final MedicalRecordsPaginationEntity pagination;
  final int page;
  final int limit;
  final int documentsPage;
  final int documentsPageSize;
  final String searchTerm;
  final String sortBy;
  final String categoryFilter;
  final String statusFilter;
  final String providerFilter;
  final String dateFilter;
  final bool isSubmitting;
  final bool isScanning;
  final bool isSupportLoading;
  final List<MedicationEntity> medications;
  final List<AllergyEntity> allergies;
  final List<ImmunizationEntity> immunizations;
  final String? errorMessage;
  final String? actionMessage;

  const RecordsState({
    this.status = RecordsStatus.initial,
    this.activeTab = RecordsTab.documents,
    this.records = const [],
    this.selectedRecord,
    this.pagination = const MedicalRecordsPaginationEntity.empty(),
    this.page = 1,
    this.limit = 100,
    this.documentsPage = 1,
    this.documentsPageSize = 10,
    this.searchTerm = '',
    this.sortBy = 'Last updated',
    this.categoryFilter = 'All',
    this.statusFilter = 'All',
    this.providerFilter = 'All',
    this.dateFilter = 'Any time',
    this.isSubmitting = false,
    this.isScanning = false,
    this.isSupportLoading = false,
    this.medications = const [],
    this.allergies = const [],
    this.immunizations = const [],
    this.errorMessage,
    this.actionMessage,
  });

  RecordsState copyWith({
    RecordsStatus? status,
    RecordsTab? activeTab,
    List<MedicalRecordEntity>? records,
    MedicalRecordEntity? selectedRecord,
    MedicalRecordsPaginationEntity? pagination,
    int? page,
    int? limit,
    int? documentsPage,
    int? documentsPageSize,
    String? searchTerm,
    String? sortBy,
    String? categoryFilter,
    String? statusFilter,
    String? providerFilter,
    String? dateFilter,
    bool? isSubmitting,
    bool? isScanning,
    bool? isSupportLoading,
    List<MedicationEntity>? medications,
    List<AllergyEntity>? allergies,
    List<ImmunizationEntity>? immunizations,
    String? errorMessage,
    String? actionMessage,
    bool clearSelectedRecord = false,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return RecordsState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      records: records ?? this.records,
      selectedRecord: clearSelectedRecord
          ? null
          : selectedRecord ?? this.selectedRecord,
      pagination: pagination ?? this.pagination,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      documentsPage: documentsPage ?? this.documentsPage,
      documentsPageSize: documentsPageSize ?? this.documentsPageSize,
      searchTerm: searchTerm ?? this.searchTerm,
      sortBy: sortBy ?? this.sortBy,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      providerFilter: providerFilter ?? this.providerFilter,
      dateFilter: dateFilter ?? this.dateFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isScanning: isScanning ?? this.isScanning,
      isSupportLoading: isSupportLoading ?? this.isSupportLoading,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      immunizations: immunizations ?? this.immunizations,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    activeTab,
    records,
    selectedRecord,
    pagination,
    page,
    limit,
    documentsPage,
    documentsPageSize,
    searchTerm,
    sortBy,
    categoryFilter,
    statusFilter,
    providerFilter,
    dateFilter,
    isSubmitting,
    isScanning,
    isSupportLoading,
    medications,
    allergies,
    immunizations,
    errorMessage,
    actionMessage,
  ];
}
