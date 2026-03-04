import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/dashboard/data/repositories/notifications_repository.dart';
import 'package:vaidya/features/dashboard/domain/repositories/notifications_repository.dart';

final markAllNotificationsReadUsecaseProvider = Provider<MarkAllNotificationsReadUsecase>((ref) {
  return MarkAllNotificationsReadUsecase(repository: ref.read(notificationsRepositoryProvider));
});

class MarkAllNotificationsReadUsecase implements UsecaseWithoutParams<bool> {
  final INotificationsRepository _repository;

  const MarkAllNotificationsReadUsecase({required INotificationsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call() {
    return _repository.markAllRead();
  }
}
