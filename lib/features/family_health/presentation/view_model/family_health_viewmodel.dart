import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/usecases/add_family_member_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/create_family_group_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/create_family_invite_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/get_my_family_group_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/join_family_invite_usecase.dart';
import 'package:vaidya/features/family_health/domain/usecases/update_family_member_relation_usecase.dart';
import 'package:vaidya/features/family_health/presentation/state/family_health_state.dart';

final familyHealthViewModelProvider =
    NotifierProvider<FamilyHealthViewModel, FamilyHealthState>(
      FamilyHealthViewModel.new,
    );

class FamilyHealthViewModel extends Notifier<FamilyHealthState> {
  late final GetMyFamilyGroupUsecase _getMyFamilyGroupUsecase;
  late final GetMyFamilyGroupSummaryUsecase _getMyFamilyGroupSummaryUsecase;
  late final CreateFamilyGroupUsecase _createFamilyGroupUsecase;
  late final CreateFamilyInviteUsecase _createFamilyInviteUsecase;
  late final AddFamilyMemberUsecase _addFamilyMemberUsecase;
  late final UpdateFamilyMemberRelationUsecase
  _updateFamilyMemberRelationUsecase;
  late final JoinFamilyInviteUsecase _joinFamilyInviteUsecase;

  @override
  FamilyHealthState build() {
    _getMyFamilyGroupUsecase = ref.read(getMyFamilyGroupUsecaseProvider);
    _getMyFamilyGroupSummaryUsecase = ref.read(
      getMyFamilyGroupSummaryUsecaseProvider,
    );
    _createFamilyGroupUsecase = ref.read(createFamilyGroupUsecaseProvider);
    _createFamilyInviteUsecase = ref.read(createFamilyInviteUsecaseProvider);
    _addFamilyMemberUsecase = ref.read(addFamilyMemberUsecaseProvider);
    _updateFamilyMemberRelationUsecase = ref.read(
      updateFamilyMemberRelationUsecaseProvider,
    );
    _joinFamilyInviteUsecase = ref.read(joinFamilyInviteUsecaseProvider);
    return const FamilyHealthState();
  }

  Future<void> load({bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == FamilyHealthStatus.initial
          ? FamilyHealthStatus.loading
          : FamilyHealthStatus.loaded,
      clearError: true,
    );

    final groupResult = await _getMyFamilyGroupUsecase();
    final summaryResult = await _getMyFamilyGroupSummaryUsecase();

    groupResult.fold(
      (failure) => state = state.copyWith(
        status: FamilyHealthStatus.error,
        errorMessage: failure.message,
      ),
      (group) {
        summaryResult.fold(
          (_) => state = state.copyWith(
            status: FamilyHealthStatus.loaded,
            group: group,
            clearError: true,
          ),
          (summary) => state = state.copyWith(
            status: FamilyHealthStatus.loaded,
            group: group,
            summary: summary,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<bool> createGroup(Map<String, dynamic> payload) {
    return _runGroupMutation(
      () =>
          _createFamilyGroupUsecase(CreateFamilyGroupParams(payload: payload)),
      'Family group created successfully',
    );
  }

  Future<bool> createInvite(
    String groupId, {
    Map<String, dynamic> payload = const {},
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _createFamilyInviteUsecase(
      CreateFamilyInviteParams(groupId: groupId, payload: payload),
    );

    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (invite) {
      ok = true;
      state = state.copyWith(latestInvite: invite);
    });

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to create invite link',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Invite link created successfully',
      clearError: true,
    );
    return true;
  }

  Future<bool> addMember(String groupId, Map<String, dynamic> payload) {
    return _runGroupMutation(
      () => _addFamilyMemberUsecase(
        AddFamilyMemberParams(groupId: groupId, payload: payload),
      ),
      'Family member added successfully',
    );
  }

  Future<bool> updateMemberRelation(
    String groupId,
    String memberId,
    Map<String, dynamic> payload,
  ) {
    return _runGroupMutation(
      () => _updateFamilyMemberRelationUsecase(
        UpdateFamilyMemberRelationParams(
          groupId: groupId,
          memberId: memberId,
          payload: payload,
        ),
      ),
      'Family member relation updated successfully',
    );
  }

  Future<bool> joinWithInvite(
    String token, {
    Map<String, dynamic> payload = const {},
  }) {
    return _runGroupMutation(
      () => _joinFamilyInviteUsecase(
        JoinFamilyInviteParams(token: token, payload: payload),
      ),
      'Joined family group successfully',
    );
  }

  Future<bool> _runGroupMutation(
    Future<Either<Failure, FamilyGroupEntity>> Function() run,
    String successMessage,
  ) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
      clearInvite: true,
    );

    final result = await run();

    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (group) {
      ok = true;
      state = state.copyWith(group: group);
    });

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Operation failed',
      );
      return false;
    }

    await load(forceLoading: false);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: successMessage,
      clearError: true,
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
