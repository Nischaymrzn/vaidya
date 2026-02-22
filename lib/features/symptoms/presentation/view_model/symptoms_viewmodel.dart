import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/symptoms/domain/usecases/create_symptom_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/delete_symptom_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/get_symptoms_usecase.dart';
import 'package:vaidya/features/symptoms/domain/usecases/update_symptom_usecase.dart';
import 'package:vaidya/features/symptoms/presentation/state/symptoms_state.dart';

final symptomsViewModelProvider =
    NotifierProvider<SymptomsViewModel, SymptomsState>(SymptomsViewModel.new);

class SymptomsViewModel extends Notifier<SymptomsState> {
  late final GetSymptomsUsecase _getUsecase;
  late final GetSymptomsSummaryUsecase _getSummaryUsecase;
  late final CreateSymptomUsecase _createUsecase;
  late final UpdateSymptomUsecase _updateUsecase;
  late final DeleteSymptomUsecase _deleteUsecase;

  @override
  SymptomsState build() {
    _getUsecase = ref.read(getSymptomsUsecaseProvider);
    _getSummaryUsecase = ref.read(getSymptomsSummaryUsecaseProvider);
    _createUsecase = ref.read(createSymptomUsecaseProvider);
    _updateUsecase = ref.read(updateSymptomUsecaseProvider);
    _deleteUsecase = ref.read(deleteSymptomUsecaseProvider);
    return const SymptomsState();
  }

  Future<void> load({bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == SymptomsStatus.initial
          ? SymptomsStatus.loading
          : SymptomsStatus.loaded,
      clearError: true,
    );

    final itemsResult = await _getUsecase();
    final summaryResult = await _getSummaryUsecase();

    itemsResult.fold(
      (failure) => state = state.copyWith(
        status: SymptomsStatus.error,
        errorMessage: failure.message,
      ),
      (items) {
        summaryResult.fold(
          (_) => state = state.copyWith(
            status: SymptomsStatus.loaded,
            items: items,
            clearError: true,
          ),
          (summary) => state = state.copyWith(
            status: SymptomsStatus.loaded,
            items: items,
            summary: summary,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );
    final result = await _createUsecase(payload);
    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to create item',
      );
      return false;
    }

    await load(forceLoading: false);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Created successfully',
      clearError: true,
    );
    return true;
  }

  Future<bool> update(String id, Map<String, dynamic> payload) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );
    final result = await _updateUsecase(
      UpdateSymptomParams(id: id, payload: payload),
    );
    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to update item',
      );
      return false;
    }

    await load(forceLoading: false);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Updated successfully',
      clearError: true,
    );
    return true;
  }

  Future<bool> remove(String id) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );
    final result = await _deleteUsecase(DeleteSymptomParams(id: id));
    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to delete item',
      );
      return false;
    }

    await load(forceLoading: false);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Deleted successfully',
      clearError: true,
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
