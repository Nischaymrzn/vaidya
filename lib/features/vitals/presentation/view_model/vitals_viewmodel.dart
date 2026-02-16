import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/vitals/domain/usecases/create_vital_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/delete_vital_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/get_vitals_usecase.dart';
import 'package:vaidya/features/vitals/domain/usecases/update_vital_usecase.dart';
import 'package:vaidya/features/vitals/presentation/state/vitals_state.dart';

final vitalsViewModelProvider = NotifierProvider<VitalsViewModel, VitalsState>(VitalsViewModel.new);

class VitalsViewModel extends Notifier<VitalsState> {
  late final GetVitalsUsecase _getUsecase;
  late final GetVitalsSummaryUsecase _getSummaryUsecase;
  late final CreateVitalUsecase _createUsecase;
  late final UpdateVitalUsecase _updateUsecase;
  late final DeleteVitalUsecase _deleteUsecase;

  @override
  VitalsState build() {
    _getUsecase = ref.read(getVitalsUsecaseProvider);
    _getSummaryUsecase = ref.read(getVitalsSummaryUsecaseProvider);
    _createUsecase = ref.read(createVitalUsecaseProvider);
    _updateUsecase = ref.read(updateVitalUsecaseProvider);
    _deleteUsecase = ref.read(deleteVitalUsecaseProvider);
    return const VitalsState();
  }

  Future<void> load({bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == VitalsStatus.initial
          ? VitalsStatus.loading
          : VitalsStatus.loaded,
      clearError: true,
    );

    final itemsResult = await _getUsecase();
    final summaryResult = await _getSummaryUsecase();

    itemsResult.fold(
      (failure) => state = state.copyWith(status: VitalsStatus.error, errorMessage: failure.message),
      (items) {
        summaryResult.fold(
          (_) => state = state.copyWith(status: VitalsStatus.loaded, items: items, clearError: true),
          (summary) => state = state.copyWith(status: VitalsStatus.loaded, items: items, summary: summary, clearError: true),
        );
      },
    );
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearActionMessage: true);
    final result = await _createUsecase(payload);
    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(isSubmitting: false, errorMessage: message ?? 'Failed to create item');
      return false;
    }

    await load(forceLoading: false);
    state = state.copyWith(isSubmitting: false, actionMessage: 'Created successfully', clearError: true);
    return true;
  }

  Future<bool> update(String id, Map<String, dynamic> payload) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearActionMessage: true);
    final result = await _updateUsecase(UpdateVitalParams(id: id, payload: payload));
    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(isSubmitting: false, errorMessage: message ?? 'Failed to update item');
      return false;
    }

    await load(forceLoading: false);
    state = state.copyWith(isSubmitting: false, actionMessage: 'Updated successfully', clearError: true);
    return true;
  }

  Future<bool> remove(String id) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearActionMessage: true);
    final result = await _deleteUsecase(DeleteVitalParams(id: id));
    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(isSubmitting: false, errorMessage: message ?? 'Failed to delete item');
      return false;
    }

    await load(forceLoading: false);
    state = state.copyWith(isSubmitting: false, actionMessage: 'Deleted successfully', clearError: true);
    return true;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
