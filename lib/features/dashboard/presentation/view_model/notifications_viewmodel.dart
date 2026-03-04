import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/dashboard/domain/usecases/get_notifications_usecase.dart';
import 'package:vaidya/features/dashboard/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:vaidya/features/dashboard/domain/usecases/mark_notification_read_usecase.dart';
import 'package:vaidya/features/dashboard/presentation/state/notifications_state.dart';

final notificationsViewModelProvider =
    NotifierProvider<NotificationsViewModel, NotificationsState>(
      NotificationsViewModel.new,
    );

class NotificationsViewModel extends Notifier<NotificationsState> {
  late final GetNotificationsUsecase _getNotificationsUsecase;
  late final MarkNotificationReadUsecase _markNotificationReadUsecase;
  late final MarkAllNotificationsReadUsecase _markAllNotificationsReadUsecase;

  @override
  NotificationsState build() {
    _getNotificationsUsecase = ref.read(getNotificationsUsecaseProvider);
    _markNotificationReadUsecase = ref.read(markNotificationReadUsecaseProvider);
    _markAllNotificationsReadUsecase =
        ref.read(markAllNotificationsReadUsecaseProvider);
    return const NotificationsState();
  }

  Future<void> load({int? page, bool forceLoading = false}) async {
    final targetPage = page ?? state.page;

    state = state.copyWith(
      status: forceLoading || state.status == NotificationsStatus.initial
          ? NotificationsStatus.loading
          : NotificationsStatus.loaded,
      page: targetPage,
      clearError: true,
    );

    final result = await _getNotificationsUsecase(
      GetNotificationsParams(
        page: targetPage,
        limit: state.limit,
        unreadOnly: state.unreadOnly,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        status: NotificationsStatus.loaded,
        items: data.notifications,
        pagination: data.pagination,
        page: data.pagination.page,
        clearError: true,
      ),
    );
  }

  Future<bool> markRead(String id) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result =
        await _markNotificationReadUsecase(MarkNotificationReadParams(id: id));

    bool ok = false;
    String? message;
    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to mark notification',
      );
      return false;
    }

    await load(page: state.page, forceLoading: false);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Notification marked as read',
      clearError: true,
    );
    return true;
  }

  Future<bool> markAllRead() async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _markAllNotificationsReadUsecase();

    bool ok = false;
    String? message;
    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to mark all notifications',
      );
      return false;
    }

    await load(page: state.page, forceLoading: false);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'All notifications marked as read',
      clearError: true,
    );
    return true;
  }

  void setUnreadOnly(bool unreadOnly) {
    state = state.copyWith(unreadOnly: unreadOnly, page: 1);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
