import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/dashboard/data/repositories/notifications_repository.dart';
import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/notifications_repository.dart';

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>((ref) {
  return GetNotificationsUsecase(repository: ref.read(notificationsRepositoryProvider));
});

class GetNotificationsParams {
  final int page;
  final int limit;
  final bool unreadOnly;

  const GetNotificationsParams({
    this.page = 1,
    this.limit = 20,
    this.unreadOnly = false,
  });
}

class GetNotificationsUsecase
    implements UsecaseWithParams<NotificationsResultEntity, GetNotificationsParams> {
  final INotificationsRepository _repository;

  const GetNotificationsUsecase({required INotificationsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, NotificationsResultEntity>> call(
    GetNotificationsParams params,
  ) {
    return _repository.getNotifications(
      page: params.page,
      limit: params.limit,
      unreadOnly: params.unreadOnly,
    );
  }
}
