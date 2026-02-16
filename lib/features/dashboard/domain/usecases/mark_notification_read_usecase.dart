import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/dashboard/data/repositories/notifications_repository.dart';
import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/notifications_repository.dart';

final markNotificationReadUsecaseProvider = Provider<MarkNotificationReadUsecase>((ref) {
  return MarkNotificationReadUsecase(repository: ref.read(notificationsRepositoryProvider));
});

class MarkNotificationReadParams {
  final String id;

  const MarkNotificationReadParams({required this.id});
}

class MarkNotificationReadUsecase
    implements UsecaseWithParams<NotificationEntity, MarkNotificationReadParams> {
  final INotificationsRepository _repository;

  const MarkNotificationReadUsecase({required INotificationsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, NotificationEntity>> call(MarkNotificationReadParams params) {
    return _repository.markRead(params.id);
  }
}
